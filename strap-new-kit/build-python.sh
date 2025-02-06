#!/bin/bash

#build n-1 version of python. mitigates issues w/ pre-releases
echo "Fetching the latest Python version..."
LATEST_PYTHON=$(curl -s https://www.python.org/ftp/python/ | grep -oP 'href="\K3\.[^"/]+[a-z0-9]*' | sort -V | tail -n 2 | head -n 1)
echo "The latest python version is: $LATEST_PYTHON"
sleep 5

# Function to install Python
install_python() {
    echo "Downloading & Installing Python $LATEST_PYTHON \n ..."
    PYTHON_TAR="Python-$LATEST_PYTHON.tgz"
    PYTHON_SRC_DIR="Python-$LATEST_PYTHON"
    # Check if the tarball is already cached
    if [ -f "$PYTHON_TAR" ]; then
        echo "Using cached tarball $PYTHON_TAR"
    else
        wget "https://www.python.org/ftp/python/$LATEST_PYTHON/$PYTHON_TAR"
    fi
    tar -xzf $PYTHON_TAR
    cd $PYTHON_SRC_DIR
    ./configure --enable-optimizations
    make -j$(nproc)
    sudo make altinstall
}

# Function to link Python and pip
link_python() {
    echo "Linking Python and pip binaries..."
    sudo ln -sf /usr/local/bin/python${LATEST_PYTHON%.*} /usr/local/bin/python
    sudo ln -sf /usr/local/bin/pip${LATEST_PYTHON%.*} /usr/local/bin/pip
    echo "Ensuring pip is installed..."
    python -m ensurepip
    echo "Verifying the installation..."
    python --version
    pip --version
}

# Check for --link-only argument
if [[ "$1" == "--link-only" ]]; then
    link_python
else
    install_python
    link_python
    rm -rf Python*
fi