
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
- [Where to start:](#where-to-start)
- [Running the playbooks](#running-the-playbooks)
  - [Calling adhoc modules (to test connectivity)](#calling-adhoc-modules-to-test-connectivity)
  - [To install all roles on all hosts:](#to-install-all-roles-on-all-hosts)
    - [To install all magicmirrors:](#to-install-all-magicmirrors)
  - [To install all kiosks:](#to-install-all-kiosks)
  - [To upgrade magicmirrors:](#to-upgrade-magicmirrors)
  - [To install the magic mirror only on one host](#to-install-the-magic-mirror-only-on-one-host)
  - [To delete the magic mirror only on one host](#to-delete-the-magic-mirror-only-on-one-host)
- [Appendix: Integrate two methods of installtion as mentioned in the Magic Mirror documentation:](#appendix-integrate-two-methods-of-installtion-as-mentioned-in-the-magic-mirror-documentation)
  - [Auotmate the manual installation method](#auotmate-the-manual-installation-method)
- [Use the scripted approach:](#use-the-scripted-approach)
- [Upgrade Magic Mirror:](#upgrade-magic-mirror)

<!-- /code_chunk_output -->

# Introduction
This project is an Ansible playbook that installs magicmirror(s) and kiosk mode on RPI .
It helps automate the installationa ,maintenance and magicmirror Module managment.
The kiosk mode is simply a RPI in GUI mode running chromium  in full screen and switching periodically between the opened tabs.
You could define the urls per tab and this could help as an information radiator.

It is based on the work in here: https://github.com/anlai/MagicMirror-Ansible.git

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

6) control the crontab jobs on the hosts,Examples:
  * DingDonng every hour (requires a connected speaker or HDMI Audio enabled screen)
  * Increase volume of the Audio output between 7:00 and 19:00 
  * Switch screen on only between 7:00 and 19:00
  * ..etc

# The Setup

## Design Assumptions :
* Two RPI : as descibed here: hosts.yaml
  * magicmirror-livingroom.local
  * magicmirror-workshop.local (commented out)
  * kiosk-workshop.local
* One will have a Magic Mirror installtion and another will run in KIOSK mode, where it will run a browser that iterates between differnt webpages every 15 seconds. One of those web pages is the magicmirror.
* Two Ansible Groups/Roles :
  * magicmirror : has 1 RPI (you could add more if you like)
  * kiosk       : The other RPI (you could add more if you like)

* Each installation of Magicmirror will have differnt set of modules running on each one.

## The roles:
1) common     : this will run on all RPI's
2) magicmirror: this will run on each magic mirror
3) kiosk      : this will run on each kiosk 

Group By Roles:
This allows playbooks to target machines based on role, as well as to assign role specific variables using the group variable system.

## The Tags
The playbooks utlizes the Ansible tags feature.
* if the ~/MagicMirror directory or the kiosk service file are not existing, the MM_install and K_install Tags are implecitly invoked anyway.
* if no Tags where specified, then a MM_Refresh is assumed, and just redeploying the MM Modules, files , Templates is carried out.

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
   magicmirror  # so far we have only one group: "magicmirror"
    vars.yaml
    vault.yaml
   kiosk        # a place holder
    vars.yaml
    vault.yaml
host_vars/
   magicmirror_living          # here we assign variables to magicmirror_living
    vars.yaml
    vault.yaml
    modules.yaml
    crontabs.yaml
   magicmirror_workshop        # here we assign variables to magicmirror_workshop (commented out)
    vars.yaml
    vault.yaml
    modules.yaml
    crontabs.yaml
   kiosk_workshop              # here we assign variables to kiosk_workshop
    vars.yaml
    vault.yaml

library/                  # if any custom modules, put them here (optional)
module_utils/             # if any custom module_utils to support modules, put them here (optional)
filter_plugins/           # if any custom filter plugins, put them here (optional)

site.yaml                  # master playbook
magicmirror.yaml           # playbook for webserver tier
kiosk.yaml                # playbook for dbserver tier

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
      ...
    kiosk/               # same kind of structure as "common" was above, done for the webtier role
      ...

```

# Where to start:
  Start by adjusting the following files for your needs: (also copy the .yaml.sample to .yaml)
  1) hosts.yaml : this is your inventory file, describe here the ip's of you magicmirror and kiosk hosts.
  2) /group_vars/<group_name>/vars.yaml     : this file has the variable holding the directory to install the MagiMirror
  2) /group_vars/<group_name>/vault.yaml    : a place holder
  3) /host_vars/<host_name_from the inventory file>/modules.yaml : Adjust the list of MagicMirror modules you want to install
  4) /host_vars/<host_name_from the inventory file>/vault.yaml : Adjust the secrets, like your iCal link, openweathermap API key ..etc, prefix your variables with a "vault_" prefix <code>vault_var123: mySecretStringOrObject</code>.
   Please note this file could be encrypted with <code>ansible-vault encrypt \<path>/vault.yaml </code>
  5) /host_vars/<host_name_from the inventory file>/vars.yaml : add more variables specific to this host and any variable you already added in the vault without the "vault_" prefix (just look at the examples in the file <code>var123: "{{vault_var123}}"</code>)
  6) /host_vars/<host_name_from the inventory file>/crontabs.yaml : add your list of crontab jobs here : like DingDong every hour or switch screen on between 7:00 and 19:00 or increase the Audio volumes in the same period ..etc

> Please note all these files are added to .gitignore so they are not checking into github.
# Running the playbooks

## Calling adhoc modules (to test connectivity)
* <code>ansible magicmirror -i hosts.yaml  -m ping</code>
* <code>ansible magicmirror -i hosts.yaml  -m command -a '/sbin/reboot'</code>

## To install all roles on all hosts:
> if ~/MagicMirror doesn't already exists, it will be install first. (implicit MM_install)

> if kiosk.service file is not found in its place, the K_install will be implicitly invoked.

<code>ansible-playbook site.yaml -i hosts.yaml </code>

### To install all magicmirrors:
<code>
ansible-playbook site.yaml        -i hosts.yaml --limit magicmirrors --tags "MM_install"
</code>

OR

<code>
ansible-playbook magicmirror.yaml -i hosts.yaml --limit magicmirror --tags "MM_install"
</code>

## To install all kiosks:
<code>ansible-playbook site.yaml -i hosts.yaml --limit kiosk --tags "K_install"</code>


## To upgrade magicmirrors:
<code>
ansible-playbook site.yaml -i hosts.yaml --limit magicmirrors --tags "MM_upgrade"
</code>
<pre> 
OR 
</pre>
<code>
ansible-playbook magicmirror.yaml -i hosts.yaml --tags "MM_upgrade"
</code>

## To install the magic mirror only on one host
<code>
ansible-playbook magicmirror.yaml -i hosts.yaml  --limit magicmirror-workshop.local --tags "MM_install"
</code>

## To delete the magic mirror only on one host
<code>
ansible-playbook magicmirror.yaml -i hosts.yaml  --limit magicmirror-workshop.local --tags "MM_delete"
</code>
 

> Please notice, that this delete procedure is not yet clean, it needs more work. (please be my guest in finalizing it or just reformat the SD card)

> You have to readjust the hosts.yaml file and remove that host from the "magicmirror" group

# Appendix: Integrate two methods of installtion as mentioned in the Magic Mirror documentation:

## Auotmate the manual installation method
https://docs.magicmirror.builders/getting-started/installation.html#manual-installation

# Use the scripted approach:
https://github.com/sdetweil/MagicMirror_scripts

# Upgrade Magic Mirror:
   1) https://github.com/sdetweil/MagicMirror_scripts
