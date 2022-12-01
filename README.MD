
# TOC
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [TOC](#toc)
- [Introduction](#introduction)
  - [The Setup](#the-setup)
    - [Design Assumptions :](#design-assumptions-)
    - [The roles:](#the-roles)
    - [The Tags](#the-tags)
  - [Reorganize the folders to match the best practices](#reorganize-the-folders-to-match-the-best-practices)
  - [running the playbooks](#running-the-playbooks)
    - [Calling adhoc modules (to test connectivity)](#calling-adhoc-modules-to-test-connectivity)
    - [To install all roles on all hosts:](#to-install-all-roles-on-all-hosts)
    - [to install all magicmirrors:](#to-install-all-magicmirrors)
    - [to install all kiosks:](#to-install-all-kiosks)
    - [to upgrade magicmirrors:](#to-upgrade-magicmirrors)
    - [to install the magic mirror onyl on one host](#to-install-the-magic-mirror-onyl-on-one-host)
    - [to delete the magic mirror onyl on one host](#to-delete-the-magic-mirror-onyl-on-one-host)
  - [Introduce more modular approach to be able to manage more than one magic mirror.](#introduce-more-modular-approach-to-be-able-to-manage-more-than-one-magic-mirror)
  - [integrate two methods of isnatlltions as mentioned in the Magic Mirror documentation:](#integrate-two-methods-of-isnatlltions-as-mentioned-in-the-magic-mirror-documentation)
    - [Auotmate the manual installation method](#auotmate-the-manual-installation-method)
    - [Use the scripted approach:](#use-the-scripted-approach)
  - [Upgrade Magic Mirror:](#upgrade-magic-mirror)

<!-- /code_chunk_output -->

# Introduction
This project is based on the work in here: https://github.com/anlai/MagicMirror-Ansible.git

It adds the following features:
1) Reorganize the folders to match the best practices from Ansible as mentioned here :
https://docs.ansible.com/ansible/2.8/user_guide/playbooks_best_practices.html#top-level-playbooks-are-separated-by-role

2) Introduce more modular approach to be able to manage more than one magic mirror installations.

3) integrate the two methods of installations as mentioned by the Magic Mirror documentation:
   1) https://docs.magicmirror.builders/getting-started/installation.html#manual-installation
   2) https://github.com/sdetweil/MagicMirror_scripts

4) Also provide a way to upgrade Magic Mirror as mentioned here :
   * https://github.com/sdetweil/MagicMirror_scripts

5) introduce the KIOSK role, where a RPI acts as a multi-tab-browser in kiosk mode, rotating the displayed tab every 15 seconds. one of those tabs could be displaying the MagicMirror webpage from the MagicMirror RPI.

## The Setup

### Design Assumptions :
* Two RPI : as descibed here: hosts.yaml
  * magicmirror-livingroom.local
  * magicmirror-workshop.local
* One will have a Magic Mirror installtion and another will run in KIOSK mode, where it will run a browser that iterates between differnt webpages every 15 seconds. One of those web pages is the magicmirror.
* Two Ansible Groups/Roles :
  * magicmirror : has 1 RPI (you could add more if you like)
  * kiosk       : The other RPI (you could add more if you like)

Each installation of Magicmirror will have differnt set of modules on each one.

### The roles:
1) common     : this will run on all RPI's
2) magicmirror: this will run on each magic mirror
3) kiosk      : this will run on each piHole 

Group By Roles:
This allows playbooks to target machines based on role, as well as to assign role specific variables using the group variable system.

### The Tags
the playbooks utlizes the Ansible tags feature.

Role: magicmirror
  Can be found in this file: roles\magicmirror\tasks\main.yaml
  Tags:
    - MM_install: usees installs procedure described below to install, disable screen saver : 
      - https://docs.magicmirror.builders/getting-started/installation.html#manual-installation
      - https://github.com/sdetweil/MagicMirror_scripts
    - MM_upgrade: uses the upgrade procedure described here: https://github.com/sdetweil/MagicMirror_scripts
    - MM_delete: delete Magic Mirror from the RPI (you could also just reformat the SDCARD)

Role: kiosk
  Can be found in this file: roles\kiosk\tasks\main.yaml
  Tags:
    - K_install: Installs the kiosk.
    - K_delete : Uninstalls the kiosk

## Reorganize the folders to match the best practices

The Directory Layout as follows:
```
hosts.yaml                # inventory file of magic Mirrors in the House

group_vars/
   magicmirror.yaml  # so far we have only one group: "magicmirror"
   pihole.yaml       # a place holder
host_vars/
   magicmirror_living.yaml          # here we assign variables to magicmirror_living
   magicmirror_workshop.yaml        # here we assign variables to magicmirror_workshop

library/                  # if any custom modules, put them here (optional)
module_utils/             # if any custom module_utils to support modules, put them here (optional)
filter_plugins/           # if any custom filter plugins, put them here (optional)

site.yaml                  # master playbook
magicmirror.yaml           # playbook for webserver tier
pihole.yaml                # playbook for dbserver tier

roles/
    common/               # this hierarchy represents a "role"
        tasks/            #
            main.yaml      #  <-- tasks file can include smaller files if warranted
        handlers/         #
            main.yaml      #  <-- handlers file
        templates/        #  <-- files for use with the template resource
            ntp.conf.j2   #  <------- templates end in .j2
        files/            #
            bar.txt       #  <-- files for use with the "copy" resource
            foo.sh        #  <-- script files for use with the "script" resource
        vars/             #
            main.yaml      #  <-- variables associated with this role
        defaults/         #
            main.yaml      #  <-- default lower priority variables for this role
        meta/             #
            main.yaml      #  <-- role dependencies
        library/          # roles can also include custom modules
        module_utils/     # roles can also include custom module_utils
        lookup_plugins/   # or other types of plugins, like lookup in this case

    magicmirror/         # same kind of structure as "common" was above, done for the webtier role
    kiosk/               # same kind of structure as "common" was above, done for the webtier role

```

## running the playbooks

### Calling adhoc modules (to test connectivity)
<code>ansible magicmirror -i hosts.yaml  -m ping
ansible magicmirror -i hosts.yaml  -m command -a '/sbin/reboot'
</code>

### To install all roles on all hosts:
<code>ansible-playbook site.yaml -i hosts.yaml </code>

### to install all magicmirrors:
<code>ansible-playbook site.yaml -i hosts.yaml --limit magicmirrors --tags "MM_install"</code>

OR

<code>ansible-playbook magicmirror.yaml   -i hosts.yaml   --tags "MM_install"    --limit magicmirror</code>

### to install all kiosks:
<code>ansible-playbook site.yaml -i hosts.yaml --limit kiosk --tags "K_install"</code>


### to upgrade magicmirrors:
<code>ansible-playbook site.yaml -i hosts.yaml --limit magicmirrors --tags "MM_upgrade"</code>

OR

<code>ansible-playbook magicmirror.yaml -i hosts.yaml --tags "MM_upgrade"</code>

### to install the magic mirror onyl on one host
<code>ansible-playbook magicmirror.yaml -i hosts.yaml  --limit magicmirror-workshop.local --tags "MM_install"</code>

### to delete the magic mirror onyl on one host
<code>ansible-playbook magicmirror.yaml -i hosts.yaml  --limit magicmirror-workshop.local --tags "MM_delete"</code>

Then you have to readjust the hosts.yaml file and remove that host for the "magicmirror" group

## Introduce more modular approach to be able to manage more than one magic mirror.

## integrate two methods of isnatlltions as mentioned in the Magic Mirror documentation:

### Auotmate the manual installation method
https://docs.magicmirror.builders/getting-started/installation.html#manual-installation

### Use the scripted approach:
https://github.com/sdetweil/MagicMirror_scripts

## Upgrade Magic Mirror:
   1) https://github.com/sdetweil/MagicMirror_scripts