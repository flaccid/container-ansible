# container-ansible

Container image and helm chart for ansible control node

## Usage

### Configuration

#### Example ConfigMaps

##### /etc/ansible/hosts

```
apiVersion: v1
kind: ConfigMap
data:
  hosts: |
    ubuntu_workspaces:
      u-1c6uucjay64tr.foobar.local:
metadata:
  name: ansible-hosts
  namespace: default
```

##### /etc/ansible/playbook.yaml

```
apiVersion: v1
kind: ConfigMap
data:
  playbook.yaml: |
    - name: My first play
      hosts: ubuntu_workspaces
      tasks:
        - name: Ping my hosts
          ansible.builtin.ping:
        - name: Print message
          ansible.builtin.debug:
            msg: Hello world
metadata:
  name: ansible-playbook
  namespace: default
```
