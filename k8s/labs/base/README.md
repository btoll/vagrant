## Errors

```bash
    master-0: + kubeadm init --pod-network-cidr 172.18.0.0/16 --apiserver-advertise-address 10.8.8.10    master-0: + tee /vagrant/kubeadm-init.out
    master-0: [init] Using Kubernetes version: v1.27.2
    master-0: [preflight] Running pre-flight checks
    master-0: error execution phase preflight: [preflight] Some fatal errors occurred:
    master-0:   [ERROR CRI]: container runtime is not running: output: E0520 01:52:13.158094    3559 remote_runtime.go:616] "St
atus from runtime service failed" err="rpc error: code = Unavailable desc = connection error: desc = \"transport: Error while d
ialing dial unix /var/run/containerd/containerd.sock: connect: no such file or directory\""
    master-0: time="2023-05-20T01:52:13Z" level=fatal msg="getting status of runtime: rpc error: code = Unavailable desc = conn
ection error: desc = \"transport: Error while dialing dial unix /var/run/containerd/containerd.sock: connect: no such file or d
irectory\""
    master-0: , error: exit status 1
    master-0:   [ERROR FileContent--proc-sys-net-bridge-bridge-nf-call-iptables]: /proc/sys/net/bridge/bridge-nf-call-iptables
does not exist
    master-0:   [ERROR FileContent--proc-sys-net-ipv4-ip_forward]: /proc/sys/net/ipv4/ip_forward contents are not set to 1
    master-0: [preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`
    master-0: To see the stack trace of this error execute with --v=5 or higher
```

Don't forget to have `systemd` reload the services and enable `crio` to start when rebooting.

systemctl daemon-reload
systemctl enable crio --now
See [Installing a container runtime](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-runtime).
https://kubernetes.io/docs/setup/production-environment/container-runtimes/#forwarding-ipv4-and-letting-iptables-see-bridged-traffic

---

```bash
vagrant@master-0:~$ sudo crictl --runtime-endpoint unix:///var/run/crio/crio.sock ps -a | grep kube | grep -v pause
b064e64c9fa17       25c2ecde661fc1a43c73f77464f3359f334da94d49c56474084dee00bcdc6146   44 seconds ago      Exited              kube-apiserver            5                   249bf4218bce8       kube-apiserver-master-0
1837ff9dee697       a7403c147a51687e0eb59abd270d501f243bc565f45f969ef44b71c16d043de6   5 minutes ago       Running             kube-controller-manager   0                   5760f17e38668       kube-controller-manager-master-0
847311e3e0f06       200132c1d91abbe4da0942bfc92953fa5122c8fdf6f6156cf3d60d73fbf7f881   5 minutes ago       Running             kube-scheduler            0                   dcec4f32bbbc0       kube-scheduler-master-0
```

```bash
vagrant@master-0:~$ sudo crictl --runtime-endpoint unix:///var/run/crio/crio.sock logs b064e64c9fa17
I0520 05:08:55.429333       1 server.go:555] external host was not specified, using 10.8.8.10
I0520 05:08:55.430205       1 server.go:163] Version: v1.26.5                                                                  I0520 05:08:55.430280       1 server.go:165] "Golang settings" GOGC="" GOMAXPROCS="" GOTRACEBACK=""
I0520 05:08:55.961257       1 plugins.go:158] Loaded 12 mutating admission controller(s) successfully in the following order: N
amespaceLifecycle,LimitRanger,ServiceAccount,NodeRestriction,TaintNodesByCondition,Priority,DefaultTolerationSeconds,DefaultSto
rageClass,StorageObjectInUseProtection,RuntimeClass,DefaultIngressClass,MutatingAdmissionWebhook.
I0520 05:08:55.961284       1 plugins.go:161] Loaded 12 validating admission controller(s) successfully in the following order:
 LimitRanger,ServiceAccount,PodSecurity,Priority,PersistentVolumeClaimResize,RuntimeClass,CertificateApproval,CertificateSignin
g,CertificateSubjectRestriction,ValidatingAdmissionPolicy,ValidatingAdmissionWebhook,ResourceQuota.
I0520 05:08:55.961388       1 shared_informer.go:270] Waiting for caches to sync for node_authorizer
W0520 05:08:55.964516       1 logging.go:59] [core] [Channel #1 SubChannel #2] grpc: addrConn.createTransport failed to connect to {
  "Addr": "127.0.0.1:2379",
  "ServerName": "127.0.0.1",
  "Attributes": null,
  "BalancerAttributes": null,
  "Type": 0,
  "Metadata": null
}. Err: connection error: desc = "transport: Error while dialing dial tcp 127.0.0.1:2379: connect: connection refused"
W0520 05:08:56.964748       1 logging.go:59] [core] [Channel #3 SubChannel #5] grpc: addrConn.createTransport failed to connect to {
  "Addr": "127.0.0.1:2379",
  "ServerName": "127.0.0.1",
  "Attributes": null,
  "BalancerAttributes": null,
  "Type": 0,
  "Metadata": null
}. Err: connection error: desc = "transport: Error while dialing dial tcp 127.0.0.1:2379: connect: connection refused"
```

## References

- [Installing kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
- [Creating a cluster with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)
- [Cluster Networking](https://kubernetes.io/docs/concepts/cluster-administration/networking/#how-to-implement-the-kubernetes-networking-model)
- [How to Deploy Kubernetes with the CRI-O Container Runtime](https://adamtheautomator.com/cri-o/)

