Move the `AWS` credentials into a new `~/.aws` directory in the `VM`:

```bash
$ cp /vagrant/aws_config .aws/config
$ cp /vagrant/aws_credentials .aws/credentials
```

Sign in:

```bash
$ aws configure
```

---

This is creating a cluster in `EKS` following the [Cilium install guide](https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/).

## Create the cluster

```bash
export NAME="$(whoami)-$RANDOM"
cat <<EOF >eks-config.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: ${NAME}
  region: eu-west-1

managedNodeGroups:
- name: ng-1
  desiredCapacity: 2
  privateNetworking: true
  # taint nodes so that application pods are
  # not scheduled/executed until Cilium is deployed.
  # Alternatively, see the note below.
  taints:
   - key: "node.cilium.io/agent-not-ready"
     value: "true"
     effect: "NoExecute"
EOF
eksctl create cluster -f ./eks-config.yaml
```

> It should take ~15 minutes to create the cluster in stupid `EKS`.

## Install Cilium CLI

```bash
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
```

## Install Cilium

```bash
$ cilium install --version 1.14.0
$ cilium status --wait
```

To validate that the cluster has proper network connectivity:

```bash
$ cilium connectivity test
```

## Enable Hubble

```bash
$ cilium enable hubble
$ cilium status # to verify
```

> Enabling Hubble requires the `TCP` port 4244 to be open on all nodes running Cilium.  This is required for Relay to operate correctly.

## Install Hubble Client

This enables access to the observability data collected by `Hubble`.

```bash
HUBBLE_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt)
HUBBLE_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then HUBBLE_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}
sha256sum --check hubble-linux-${HUBBLE_ARCH}.tar.gz.sha256sum
sudo tar xzvfC hubble-linux-${HUBBLE_ARCH}.tar.gz /usr/local/bin
rm hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}
```

## Validate Hubble API Access

```bash
$ cilium hubble port-forward&
[1] 8033
$ hubble status
Healthcheck (via localhost:4245): Ok
Current/Max Flows: 8,190/8,190 (100.00%)
Flows/s: 35.14
Connected Nodes: 2/2
```

Query the flow `API` and look for flows:

```bash
$ hubble observe
```

