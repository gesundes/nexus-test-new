# nexus-test
## What this code do
Ansible:
* creates AMI for OpenVPN server,
* downloads ca.crt before AMI creation,
* creates AMI for Nexus,
* applies CF template,
* generates config for VPN client.

CloudFormation:
* creates network infrastructure:
    - VPC,
    - public network,
    - two private networks,
    - internet gateway,
    - NAT gateway,
    - SGs,
    - route tables,
    - other things,
* creates EFS,
* spin ups OpenVPN instance in public network,
* spin ups Nexus instance:
    - in private network,
    - in Auto Scaling group,
    - with EFS mounted in /opt/sonatype-work,
* outputs DNS name of OpenVPN server.

## How to start the environment
Add your AWS security credentials to file **credentials.sh** and source it:
```bash
source ./credentials.sh
```

Run Ansible playbook:
```bash
ansible-playbook ./nexus-aws.yaml
```

## How to access Nexus
If you use MacOS and TunnelBlick as VPN client then after Ansible will finish it's work you can just double click on file client.ovpn in Finder to apply VPN configuration.

Please use openvpn/openvpn as username/password to login to VPN server.

After VPN connection will be established you can find internal domain name of Nexus instance in AWS web console in EC2 section and open it in your browser using port 8081.

## Drawbacks

This code isn't fully idempotent. It will try to create AMIs even they already exist.

This code assumes that base VM image contains Debian-based OS.