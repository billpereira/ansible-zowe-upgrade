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
Let's start with `ansible.cfg`