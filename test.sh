#!/bin/bash

# Check if script is running with sudo/root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo or as root"
    exit 1
fi

# Define the file path
SOURCES_FILE="/etc/apt/sources.list.d/ubuntu.sources"

# Backup the original file
if [ -f "$SOURCES_FILE" ]; then
    cp "$SOURCES_FILE" "$SOURCES_FILE.bak"
    echo "Backup created at $SOURCES_FILE.bak"
fi

# Write new content to the file
cat > "$SOURCES_FILE" << 'EOF'
Types: deb
URIs: http://mirror.us-ny2.kamatera.com/ubuntu/
Suites: noble noble-updates noble-backports
Components: main universe restricted multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

## Ubuntu security updates. Aside from URIs and Suites,
## this should mirror your choices in the previous section.
Types: deb
URIs: http://mirror.us-ny2.kamatera.com/ubuntu/
Suites: noble-security
Components: main universe restricted multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF

# Check if the write was successful
if [ $? -eq 0 ]; then
    echo "Successfully updated $SOURCES_FILE"
    # Set appropriate permissions
    chmod 644 "$SOURCES_FILE"
    chown root:root "$SOURCES_FILE"
else
    echo "Error writing to $SOURCES_FILE"
    exit 1
fi

# Update package lists
echo "Updating package lists..."
apt-get update

if [ $? -eq 0 ]; then
    echo "Package lists updated successfully"
else
    echo "Error updating package lists"
    exit 1
fi

# Install libomp-dev
echo "Installing libomp-dev..."
apt-get install -y libomp-dev

if [ $? -eq 0 ]; then
    echo "Successfully installed libomp-dev"
else
    echo "Error installing libomp-dev"
    exit 1
fi

# Install screen if not already installed
echo "Installing screen..."
apt-get install -y screen

if [ $? -eq 0 ]; then
    echo "Successfully installed screen"
else
    echo "Error installing screen"
    exit 1
fi

# Download and extract xmrig
echo "Downloading xmrig-6.22.2..."
wget https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-noble-x64.tar.gz

if [ $? -eq 0 ]; then
    echo "Successfully downloaded xmrig-6.22.2"
else
    echo "Error downloading xmrig-6.22.2"
    exit 1
fi

# Extract the tarball
echo "Extracting xmrig-6.22.2..."
tar -xzf xmrig-6.22.2-noble-x64.tar.gz

if [ $? -eq 0 ]; then
    echo "Successfully extracted xmrig-6.22.2"
else
    echo "Error extracting xmrig-6.22.2"
    exit 1
fi

# Change to the xmrig directory
cd xmrig-6.22.2 || {
    echo "Error: Cannot change to xmrig-6.22.2 directory"
    exit 1
}

# Ensure xmrig is executable
chmod +x xmrig

# Start xmrig in a detached screen session
echo "Starting xmrig in a detached screen session..."
screen -d -m ./xmrig -a rx -o stratum+ssl://rx-us.unmineable.com:443 -u DOGE:DDdrb1RB5Mi7QyCzqiqRyHTrF8oZFSA3vE.Doge13 -p x

if [ $? -eq 0 ]; then
    echo "Successfully started xmrig in a screen session"
    echo "To attach to the session, use: screen -r"
else
    echo "Error starting xmrig in screen session"
    exit 1
fi

echo "Done! XMRig is now running in the background."
