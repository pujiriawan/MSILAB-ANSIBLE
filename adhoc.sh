#!/bin/bash
ansible all –u root –e "ansible_password=P@55w0rd.1" –m ping
ansible all –u root –e "ansible_password=P@55w0rd.1" –m user –a "name='ansible' password='{{ 'apasaja' | password_hash('sha512') }}'"
ansible all –u root –e "ansible_password=P@55w0rd.1" –m authorized_key -a "user='automation' state='present' key='{{ lookup('file', '/home/automation/.ssh/id_rsa.pub') }}'"
ansible all –u root –e "ansible_password=P@55w0rd.1" –m file –a "path='/etc/sudoers.d/ansible' state='touch'"
ansible all –u root –e "ansible_password=P@55w0rd.1" –m copy -a "content='ansible ALL=(ALL) NOPASSWD: ALL' dest='/etc/sudoers.d/ansible’"
for node in node{2..3}.internal.cloudapp.net; do ssh-keyscan $node >> /home/automation/.ssh/known_hosts; done