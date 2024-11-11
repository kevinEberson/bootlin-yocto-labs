# bootlin-yocto-labs
Repo containing a shell script to setup the bootlin-labs work enviroment like described in [yocto-labs](https://bootlin.com/doc/training/yocto/yocto-labs.pdf). The script pulls all dependencies and checks/patches the required repos. Be aware: the script is very stupid and cannot recover from errors. If anything goes wrong, delete the download directory and try again or fix the error by hand.

The script can be run in 2 ways:

    ./setup.sh
   Or:
   

    ./setup.sh <your_custom_path>

This allows you to install the layers in the default directory, or a directory of choice.
