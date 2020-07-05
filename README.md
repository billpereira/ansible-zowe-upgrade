# Going a bit deeper on Ansible - Upgrade Zowe with playbooks

## Introduction

I've started to learn about Ansible, and was amazing how easy is to get started and to find information on internet on sites like stackoverflow for example. 
Ansible is really new for z/OS but is really popular on other platforms and we may use a lot of what is available together with the galaxy modules released by IBM for zOS.

## Prerequisites

- Linux environment or Docker
- Python and Z Open Automation Utilities on z/OS LPAR
- Zowe - As we are upgrading it.
- Basic understanding about what is Ansible - you can learn from my previous video on Ansible Basics: https://www.youtube.com/watch?v=99ISlCacneY

On this tutorial we are using docker to make easier for users from any platform to get started, so they don't need to worry about ansible installation. I cover the steps for ansible install on the link about Getting Started with ansible.

## Estimated time

You should be able to finish this tutorial in about xx minutes. To complete the playbook can be more depending on your connection.

## Steps

1 - Our folder structure and understanding the files we are using

2 - Using template, zos_encode and zos_job_submit, and conditional statements.

3 - Using copy and loop to upload our PTFs

4 - Using zos_operator to issue commands and stop our Zowe tasks

5 - Receiving and applying our PTFs


### 1 - Our folder structure and understanding the files we are using

We are keeping all configuration needed, our variables, tasks playbook all in our working directory. 
```
.
├── Dockerfile
├── README.md
├── ansible.cfg
├── data
├── group_vars
│   └── tvt5106.yml
├── inventory
│   └── hosts
├── tasks
│   ├── check_ptf.yml
│   ├── smpe.yml
│   ├── stop_zowe.yml
│   └── upload.yml
├── templates
│   ├── apply.j2
│   ├── list_ptfs.j2
│   └── receive.j2
└── zowe_upgrade.yml

5 directories, 13 files
```
#### ansible.cfg
<img src='imgs/ansible-cfg.png' />

Ansible starts looking for the configuration file in the current directory before going to `/etc/ansible`. Here i'm informing 2 groups of configuration, deaults and config for ssh connection. 
With `host_key_checking = False` i don't need to confirm the host fingerprint for evey ssh connection. For our example the `forks = 25` don't have too much influence, this is the number of parallel processes to spawn when communicating with our hosts. `retry_files_enabled = False` will tell ansible to do not create retry files, this is a kind of files where ansible include some logs about failed tasks.
The `inventory` is pointing to where we have our hosts definitions.
The `pipelining` reduces number of SSH operations and improve our performance.

#### inventory/hosts
<img src='imgs/hosts.png' />

Here we keep our inventory, we can create multiple groups of LPARs, for example dev, test, production... In this case i have the tvt5106 and it's address only.

Creating that allow me to create `tvt5106.yml` and link the variables for this group.

#### group_vars/tvt5106.yml
<img src='imgs/group-vars.png' />

Instead of keep the variables inside of our playbook, keeping them on group_vars directory allow us to have a more clean playbook, and more organized as we can even reuse that depending on our configuration across groups on our inventory.

So we start with the connection related variables, which port to connect, with which user and password.
The next group of variables, have the system related ones, where in this lpar we have python installed, what is the home directory for ZOAU and the properties for execution.(https://ansible-collections.github.io/ibm_zos_core/playbooks.html#group-vars)

Specific for our playbook, we have here the PTFs we are installing, and we are using a list(array) with the ptfs that we are going to install. As we are installing the ptfs on our smpe, for our receive and apply we need to inform the global csi and the target zone where they are going to be installed.

The last two variables, are variables i'm using to control my playbook, so in case they have been installed i don't proceed with the tasks and if the receive fail i also stop the playbook.

This completes our configuration, now let's take a look on our playbook, tasks and templates.

### 2 - Using template, zos_encode and zos_job_submit, and conditional statements.

<img src='imgs/playbook.png' />