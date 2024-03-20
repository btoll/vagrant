kind create cluster --config /vagrant/cluster_config.yaml
sed -i 's/kind-beta/beta/' ~/.kube/config
export GITHUB_TOKEN=""
flux bootstrap github --context=beta --owner=owls-nest-farm --repository=gitops --branch=master --personal --path=clusters/beta
git clone git@github.com:owls-nest-farm/gitops.git

