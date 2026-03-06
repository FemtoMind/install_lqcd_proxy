#!/bin/bash
#Insatllation script for lqcd proxy server. 
#This script will install the proxy server to a specified directory.
#Usage: ./install.sh <install_dir> <user>
#Example: ./install.sh /opt/lqcd_proxy lqcd (root or lqcd)

usage_func(){
    echo "Usage: $1 -i offline_package_dir [-v fastmcp_major_version(2|3)] [-d install_dir] [-u run_as_user]"
    echo "Default install directory /usr/local/lqcd_proxy, default run user is lqcd"
}

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    usage_func "$0"
    exit 1
fi

dir=/usr/local/lqcd_proxy
user=lqcd
offline_package_dir=N/A
fmcp_version=3

while getopts "i:d:u:v:h" opt
do
    case "$opt" in
        d)
            dir=$OPTARG
            ;;
        u)
            user=$OPTARG
            ;;
        i)
            offline_package_dir=$OPTARG
            ;;
        v)
            fmcp_version=$OPTARG
            ;;
        h)
            usage_func "$0"
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

if [ "$offline_package_dir" = "N/A" ]
then
    echo "Please specify python offline package directory."
    usage_func "$0"
    exit 1
fi    
            
echo "jlab-lqcd-mcp-proxy will be installed at $dir. The service will run as $user".
echo "This installation will be use FastMCP version $fmcp_version".

if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
else
    echo "Directory $dir already exists, remove it first."
    rm -rf "$dir"
    mkdir -p "$dir"
fi

cp -rp ./jlab-lqcd-mcp-proxy $dir/
cp -rp ./mcp_proxy.service $dir/
cp -rp $offline_package_dir $dir/proxy_packages
touch $dir/FastMCP_Version_$fmcp_version
mkdir -p $dir/logs

# create a virtual environment
uv python install --install-dir $dir/fastmcp-python 3.12
uv venv --clear $dir/fastmcp-env
source $dir/fastmcp-env/bin/activate
uv pip install --no-index --find-links=$dir/proxy_packages -r $dir/proxy_packages/requirements.txt

#link production server env
ln -s $dir/jlab-lqcd-mcp-proxy/.server_env.prod $dir/jlab-lqcd-mcp-proxy/.server_env 

# change the owner of the directory
chown -R $user:hpc "$dir"

