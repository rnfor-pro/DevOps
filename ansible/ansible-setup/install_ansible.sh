#!/bin/bash
# Update system packages and install Python 3 pip and Ansible
sudo hostnamectl set-hostname ansible-controller
sudo apt update -y
sudo apt install python3-pip -y
pip3 install ansible==9.2.0 -y

# Add ~/.local/bin to PATH if not already present
if ! [[ ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
    export PATH="$PATH:$HOME/.local/bin"
fi

# Save the PATH update script to ~/update_path.sh
cat <<EOT > ~/update_path.sh
#!/bin/bash

# Add ~/.local/bin to PATH if not already present
if ! [[ ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
    export PATH="$PATH:$HOME/.local/bin"
fi
EOT

# Make the PATH update script executable
chmod +x ~/update_path.sh

# Add reference to the PATH update script in ~/.bashrc
echo "~/update_path.sh" >> ~/.bashrc

# Run the PATH update script
~/update_path.sh

bash

########## END  ############

