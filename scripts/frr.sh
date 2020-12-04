#!/usr/bin/env bash

# possible values for FRRVER: frr-6 frr-7 frr-stable
# frr-stable will be the latest official stable release
FRRVER="frr-stable"

# # add RPM repository on CentOS 6
# curl -O https://rpm.frrouting.org/repo/$FRRVER-repo-1-0.el6.noarch.rpm
# sudo yum install -y ./$FRRVER*

# # add RPM repository on CentOS 7
curl -O https://rpm.frrouting.org/repo/$FRRVER-repo-1-0.el7.noarch.rpm
sudo yum install -y ./$FRRVER*

# add RPM repository on CentOS 8
# curl -O https://rpm.frrouting.org/repo/$FRRVER-repo-1-0.el8.noarch.rpm
# sudo yum install -y ./$FRRVER*

# install FRR
# sudo yum install -y frr frr-pythontools
