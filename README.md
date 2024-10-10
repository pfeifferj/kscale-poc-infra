PoC automation suite for IKS config benchmarking

currently deploys two IKS clusters, applies different autoscaling configs, runs benchmarks/collects metrics, and finally decomissions the clusters again.

# Running Cluster Autoscaling Load Test Experiments

<abstract>

## Prerequisites

python & podman need to be installed on the system

1.1 Clone this repository

```bash
git clone https://github.com/pfeifferj/kscale-poc-infra
```

## Build new Execution Environment

2.1 Set up venv

```bash
python -m venv kscale-venv
source kscale-venv/bin/activate
kscale-venv/bin/python -m pip install --upgrade pip
pip install -r requirements.txt
```

2.2 Build Execution Environment (optional)

```bash
cd ansible-ee
ansible-builder build -t kscale-ee --no-cache
```

2.3 Configure ansible-navigator

Create a config file to configure `ansible-navigator`, primarily the EE image.

```bash
cat <<EOF > $HOME/.ansible-navigator.yaml
ansible-navigator:
  execution-environment:
    container-engine: podman
    image: quay.io/pfeifferj/kscale-ee:latest
    pull:
      policy: missing
    container-options:
      - "--runtime=crun"
      - "--annotation='run.oci.keep_original_groups=1'"
  playbook-artifact:
    enable: False
EOF
```

Note: An overview of all available options can be found under https://ansible.readthedocs.io/projects/navigator/settings/#execution-environment-image.

2.4 Run playbooks with custom Execution Environment

```bash
ansible-navigator run <your-playbook.yml>
```

## Experiment Configuration Options

### Run specific plays

```bash
ansible-navigator run <your-playbook.yml>
```

### Toggle manual confirmation

```bash
ansible-navigator run <your-playbook.yml>
```

### Toggle IBM Cloud Load Tests

```bash
ansible-navigator run <your-playbook.yml>
```

### Toggle AWS Load Tests

```bash
ansible-navigator run <your-playbook.yml>
```
