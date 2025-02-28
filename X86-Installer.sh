#!/bin/bash


echo ""
n=" ██████╗ ██████╗ ███████╗███╗   ██╗   ██╗  ██╗██████╗   " && echo "${n::${COLUMNS:-$(tput cols)}}" # some magic to cut the end on smaller terminals
n="██╔═══██╗██╔══██╗██╔════╝████╗  ██║   ██║  ██║██╔══██╗  " && echo "${n::${COLUMNS:-$(tput cols)}}"
n="██║   ██║██████╔╝█████╗  ██╔██╗ ██║   ███████║██║  ██║  " && echo "${n::${COLUMNS:-$(tput cols)}}"
n="██║   ██║██╔═══╝ ██╔══╝  ██║╚██╗██║   ██╔══██║██║  ██║  " && echo "${n::${COLUMNS:-$(tput cols)}}"
n="╚██████╔╝██║     ███████╗██║ ╚████║██╗██║  ██║██████╔╝  " && echo "${n::${COLUMNS:-$(tput cols)}}"
n=" ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝╚═════╝   " && echo "${n::${COLUMNS:-$(tput cols)}}"
echo ""

prepareOpenHD()
{
	mkdir -p /opt/X86
	cp -rv * /opt/X86/
	current_dir=$(pwd)
	cd ..
	rm -Rf $current_dir
	apt update 
	mkdir -p /boot/openhd/
	touch /boot/openhd/x86.txt
	touch /boot/openhd/ground.txt
	git clone https://github.com/OpenHD/rtl88x2bu /usr/src/rtl88x2bu-git
	git clone https://github.com/OpenHD/rtl8812au /usr/src/rtl8812au-git
}
installShortcuts()
{
	cd /opt/X86/
	cp additionalFiles/desktop-truster.sh /etc/profile.d/desktop-truster.sh
	chmod +777 /etc/profile.d/desktop-truster.sh
	chmod a+x  /etc/profile.d/desktop-truster.sh
	chmod a+x  shortcuts/OpenHD-Air.desktop
	chmod a+x  shortcuts/OpenHD-Ground.desktop
	chmod a+x  shortcuts/QOpenHD.desktop
	rm -Rf shortcuts/MissionPlanner.desktop
	rm -Rf shortcuts/INAV.desktop
	rm -Rf shortcuts/qgroundcontrol.desktop
	rm -Rf shortcuts/QOpenHD2.desktop
	rm -Rf shortcuts/OpenHD.desktop
	rm -Rf shortcuts/nm-tray-autostart.desktop
	rm -Rf shortcuts/steamdeck.desktop
	rm -Rf shortcuts/OpenHD-ImageWriter.desktop
	for homedir in /home/*; do sudo cp shortcuts/*.desktop "$homedir"/Desktop/; done
	for homedir in /home/*; do gio set /home/$homedir/Desktop/OpenHD-Air.desktop metadata::trusted true; done
	for homedir in /home/*; do gio set /home/$homedir/Desktop/OpenHD-Ground.desktop metadata::trusted true; done
	for homedir in /home/*; do gio set /home/$homedir/Desktop/QOpenHD.desktop metadata::trusted true; done
	echo "Service and GIO ERRORS CAN BE IGNORED"
	sudo cp shortcuts/* /usr/share/applications/
	sudo cp shortcuts/OpenHD.ico /opt/
}
installRtl8812au()
{
cd /usr/src/rtl8812au-git
./dkms-install.sh
echo "Installed RTL8812AU"
}
installRtl8812bu()
{
cd /usr/src/rtl88x2bu-git
sed -i 's/PACKAGE_VERSION="@PKGVER@"/PACKAGE_VERSION="5.13.1"/g' /usr/src/rtl88x2bu-git/dkms.conf
dkms add -m rtl88x2bu -v 5.13.1
echo "Installed RTL8812BU"
}
installOpenHDRepositories()
{
apt install -y git dkms curl
curl -1sLf 'https://dl.cloudsmith.io/public/openhd/openhd-x86-evo/setup.deb.sh'	| sudo -E bash
echo "Cloned Qopenhd and Openhd github repositories"
}
installOpenHD()
{
sudo apt update
sudo apt install -y openhd qopenhd open-hd-web-ui 
systemctl disable openhd
systemctl disable qopenhd
}
cleanup()
{
rm -Rf /opt/X86
echo "Installer finished"
echo "Please reboot now"
}

#Main Setup

if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Aborting."
  exit 1
fi

installOpenHDRepositories
prepareOpenHD
installRtl8812au
installRtl8812bu
installOpenHD
installShortcuts
cleanup
