#!/bin/bash
#Build offline python package for lqcd proxy server and source code
#This script will build the python package for lqcd proxy server and
#copy it to the specified directory.
#Usage: ./build_offline_python_pkg.sh <install_dir>
#Example: ./build_offline_python_pkg.sh directory_name

usage_func()
{
    echo "Usage: $1 [-c] [-d directory]"
    echo "-c clean out old packages. -d directory contains all offline python packages."
}

# Make sure you are in the virtual environment.
if [ -z "$VIRTUAL_ENV" ]; then
    echo "Please run this script inside the virtual environment."
    exit 1
fi

clean_packages=No
dir=N/A

while getopts "d:ch" opt
do
    case "$opt" in
        c)
            clean_packages=Yes
            ;;
        d)
            dir=$OPTARG
            ;;
        h)
            usage_func "$0"
            exit 0
            ;;
        \?)
            echo "Invalid option: 0$OPTARG" >&2
            exit 1
            ;;
    esac
done

if [ "$dir" = "N/A" ]
then   
   if [ "$clean_packages" = "Yes" ]
   then
       echo "Clean out old python package and source code."
       ls -d */ | xargs rm -rf
       exit 0
   else
       usage_func "$0"
       exit 1
   fi
fi   

echo "jlab-lqcd-mcp-proxy offline packages will be installed at $dir ."
if [ "$clean_packages" = "Yes" ]
then
    echo "Clean out old python package and source code."
    ls -d */ | xargs rm -rf
fi    

# Git clone the python code
# check whether the source code is checked out
if [ ! -d ./jlab-lqcd-mcp-proxy ]
then   
    git clone git@github.com:FemtoMind/jlab-lqcd-mcp-proxy.git
fi    

if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
else
    echo "Directory $dir already exists, remove it first."
    rm -rf "$dir"
    mkdir -p "$dir"
fi

# Run this script as a regular user and inside the virtual environment.
# use uv to generate requirements.txt
uv pip freeze > requirements.txt

# Download all the packages in requirements.txt and save them to the specified directory.
pip download -r requirements.txt -d $dir

# move the requirement.txt to the install directory
mv requirements.txt $dir


