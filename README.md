# Running Cluster Autoscaling Load Test Experiments

PoC automation suite for IKS config benchmarking.

Deploys two IKS clusters, applies different autoscaling configs, runs benchmarks/collects metrics, and finally decomissions the clusters again.

To compare benchmarks, EKS clusters can be deployed and tested against too.

## Prerequisites

ansible, python & podman need to be installed on the system

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

Push ee image to container registry:

```bash
podman tag localhost/kscale-ee:latest quay.io/pfeifferj/kscale-ee:latest
podman push quay.io/pfeifferj/kscale-ee:latest
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

2.4 Set up vault for secrets

Create a vault file:

```bash
ansible-vault create secrets.yaml
```

Set required secret values:

```yaml
IBM_CLOUD_TOKEN: "redacted"
RESOURCE_GROUP_ID: "redacted"
VPC_ID: "redacted"
SUBNET_ID:
  US_SOUTH_1: "redacted"
  US_SOUTH_2: "redacted"
  US_SOUTH_3: "redacted"
```

Before executing the playbook with `ansible-navigator` export the password:

```bash
ISTCONTROL=ignorespace
 export ANSIBLE_VAULT_PASSWORD=my_password
```

2.5 Run playbooks with custom Execution Environment

```bash
ansible-navigator run ansible/playbook.yml
```

## Experiment Configuration Options

### Run specific plays

Example:

```bash
ansible-navigator run ansible/playbook.yml --ask-vault-pass --tags "setup,aws"
ansible-navigator run ansible/playbook.yml --ask-vault-pass --tags "setup,ibm_cloud"

--container-options "-v /path/on/local/machine:/path/in/container" # to send log files/metrics to host
```

### Environment Variables

```bash
# run on just one of the platforms
LOAD_TEST_TARGET=AWS
LOAD_TEST_TARGET=IBM_CLOUD

# run on both
LOAD_TEST_TARGET="IBM_CLOUD,AWS"

# run benchmarks immediately after bootstrapping and config have finished
AUTO_RUN_BENCHMARK=true

# tear down all infra immediately after benchmarks have finished
AUTO_RUN_TEARDOWN=false
```

Use `--penv` to pass the environment variables to ansible-navigator:

```bash
ansible-navigator run ansbile/playbook.yml --tags "setup,aws" --penv LOAD_TEST_TARGET --penv AUTO_RUN_TEARDOWN
```
