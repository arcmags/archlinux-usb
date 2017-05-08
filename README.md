<h2>archlinux-usb</h2>
Scripts and configuration files to go along with the <a href="http://valleycat.org/foo/arch-usb.html" target="_blank">guide</a> for creating a persistent bootable Arch Linux USB.
<br>
<br>

<h3>install_scripts/</h3>
<hr>
<h4>arch-usb_core.sh</h4>
Script that re-install the core packages installed in the <a href="http://valleycat.org/foo/arch-usb.html" target="_blank">guide</a>.
<br>

<h4>arch-usb_recommended.sh</h4>
Script to install a bunch of (my) recommended packages.  This bash script is made to be easily edited for users to quickly customize the package set they wish to install.  Additionally, the script offers the option to display a brief package description and prompt y/n for the installation of each package.
<br>

<h4>arch-usb_aur.sh</h4>
Script for installing selected packages from the <a href="https://aur.archlinux.org/" target="_blank">AUR</a>.  Again, this script offers the option to display a short package description and prompt for the installation of each package.
<br>
<br>

<h3>uwec_scripts/</h3>
<hr>
<h4>uwec-connect.sh</h4>
Script that fully automates connecting to the UWEC network and mounting various network resources.  Users will first need to edit the script, adding valid usernames and desired mount locations.
<br>

<h4>uwec-disconnect.sh</h4>
Script to disconnect from the UWEC network and unmount network resources.  Users will first need to edit the script, adding their mount locations.
<br>
<br>

<h3>html/</h3>
<hr>
A copy of the <a href="http://valleycat.org/foo/arch-usb.html" target="_blank">guide</a>.
<br>
<br>

<h3>.config/</h3>
<hr>
<h4>issue</h4>
Issue file displayed on initial tty login to Arch Linux.  Copy to /etc/issue to use.

