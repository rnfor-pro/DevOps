# Install WSL
# Windows
---

go to the search bar on your laptop and type powershell right click and select `run as administartor`

copy and paste the below commands and wait for it to get to `100%` before you paste the next one. 

```bash
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
```

```bash

dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```


```bash
wsl.exe --install
```


```bash
wsl --set-default-version 2
```

```bash
wsl --install -d Ubuntu-20.04
```

reboot your system.

Now launch visual studio code

Click on ctrl tilder (~)

Click on the drop down arrow on the right and select ubuntu wsl


## terraform install
---
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

```

```bash
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

```
```bash
sudo apt update && sudo apt install terraform
```


# mac users
```bash
brew tap hashicorp/tap
```

```bash
brew install hashicorp/tap/terraform
```
## hints
---
If you run into an error such as `zsh: command not found brew` follow the steps below to install brew

Copy and paste the following command into the terminal and then press Enter
---

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 
```

Verify Installation
```bash
brew doctor
```

