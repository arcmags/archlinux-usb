=============
archlinux-usb
=============

Scripts and configuration files to go along with the guide_ for creating a
persistent bootable Arch Linux USB.


``html/``
=========

A copy of the guide_.


``install_scripts/``
====================

``arch-usb_core.sh``
--------------------

    Script to re-install the core packages installed in the guide_.


``arch-usb_recommended.sh``
---------------------------

    Script to install a bunch of (my) recommended packages.  This bash script
    is made to be easily edited for users to quickly customize the package
    set they wish to install.  Additionally, the script offers the option
    to display a brief package description and prompt y/n for the
    installation of each package.

``arch-usb_aur.sh``
-------------------

    Script for installing selected packages from the AUR_.  Again, this
    script offers the option to display a short package description and
    prompt y/n for the installation of each package


``uwec_scripts/``
=================

``uwec-connect.sh``
-------------------

    Script that fully automates connecting to the UWEC network and mounting
    various network resources. Users will first need to edit the script,
    adding valid usernames and desired mount locations.

``uwec-disconnect.sh``
----------------------
    Script to disconnect from the UWEC network and unmount network resources.
    Users will first need to edit the script, adding their mount locations.


``.config``
===========

``issue``
---------
    Issue file displayed on initial tty login to Arch Linux.  Copy to
    ``/etc/issue`` to use.


.. _guide: http://valleycat.org/foo/arch-usb.html
.. _AUR: https://aur.archlinux.org/
