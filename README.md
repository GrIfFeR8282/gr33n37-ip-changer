
![gp](https://github.com/user-attachments/assets/b9b8d84b-3fcc-4413-bda1-24bb8e87acfa)

# Disclaimer

This tool is optimized only for Debian-based Linux distributions, I'm looking for contributors who use Arch-based/non-Debian-based distros or macOS for test and contribute to this project, feel free 
to create forks, submit pull requests and send issues.

This is a practice project for learning GitHub workflow, i do not have plans to release frequent updates.

## Installation

You can either `git clone` the repository or `curl` the Bash script.

Using `git clone`:

```shell
git clone https://github.com/GrIfFeR8282/ip-changer.git
cd ip-changer
chmod +x ip-changer.sh
```

Using `curl`:

```shell
curl -L https://github.com/GrifFeR8282/ip-changer/archive/refs/heads/main.zip -o ip-changer.zip
unzip ip-changer.zip
mv ip-changer-main ip-changer
cd ip-changer
chmod +x ip-changer.sh
```

## Usage

Run the script with root privileges:

```shell
sudo ./ip-changer.sh
```

## Parameters

The default parameters for the script are:

```shell
interval=3   # seconds between IP Changes
times=0      # number of changes; 0 means it will continue until the script stops
lolcat=1     # lolcat makes text rainbow (styling only); 1 for enabled, 0 for disabled
```

You can change these parameters by editing the `ip-changer.conf` file.
