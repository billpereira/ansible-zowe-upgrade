FROM centos:7 as demo_ansible
WORKDIR /root
RUN  yum check-update; \
   yum install -y gcc libffi-devel python3-devel openssl-devel epel-release; \
   yum install -y python3-pip python3-wheel sshpass; 
RUN  pip3 install ansible
RUN yum install -y openssh*;
RUN yum install -y initscripts;
RUN ansible-galaxy collection install ibm.ibm_zos_core:==1.1.0-beta1
# RUN ansible-galaxy collection install ibm.ibm_zos_core
# COPY ibm-ibm_zos_core-1.1.0-beta2.tar.gz .
# RUN ansible-galaxy collection install -f ibm-ibm_zos_core-1.1.0-beta2.tar.gz
# RUN mkdir -p /root/data
# COPY ZOWE.* /root/data/
COPY group_vars /root/group_vars
COPY inventory /root/inventory
COPY tasks /root/tasks
COPY data /root/data
COPY templates /root/templates
COPY ansible.cfg .
COPY zowe_upgrade.yml .
RUN service sshd restart
ENTRYPOINT /bin/bash 