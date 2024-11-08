# Ansible

## Setup

### Install Ansible
To install Ansible, run:
```bash
brew install ansible
```

### Install Dependencies
Initialize the required dependencies by running:
```bash
make init
```

### Run Connectivity Check
To check connectivity, execute:
```bash
ansible-playbook debug.yml -i hosts/test.yaml
```

> **Note:** Change the hostname in `hosts/test.yaml` based on the desired environment.
