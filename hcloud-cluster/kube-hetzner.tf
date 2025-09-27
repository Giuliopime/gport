module "kube-hetzner" {
  providers = {
    hcloud = hcloud
  }
  hcloud_token = var.hcloud_token

  # 1. For normal use, (the official version published on the Terraform Registry), use
  source = "kube-hetzner/kube-hetzner/hcloud"
  #    When using the terraform registry as source, you can optionally specify a version number.
  #    See https://registry.terraform.io/modules/kube-hetzner/kube-hetzner/hcloud for the available versions
  # version = "2.15.3"
  # 2. If you want to use the latest master branch (see https://developer.hashicorp.com/terraform/language/modules/sources#github), use
  # source = "github.com/kube-hetzner/terraform-hcloud-kube-hetzner"

  # Note that some values, notably "location" and "public_key" have no effect after initializing the cluster.
  # This is to keep Terraform from re-provisioning all nodes at once, which would lose data. If you want to update
  # those, you should instead change the value here and manually re-provision each node. Grep for "lifecycle".

  # * Your ssh public key
  ssh_public_key = file("~/.ssh/id_ed25519.pub")
  ssh_private_key = file("~/.ssh/id_ed25519")

  # You can add additional SSH public Keys to grant other team members root access to your cluster nodes.
  # ssh_additional_public_keys = []

  # You can also add additional SSH public Keys which are saved in the hetzner cloud by a label.
  # See https://docs.hetzner.cloud/#label-selector
  # ssh_hcloud_key_label = "role=admin"

  # * For Hetzner locations see https://docs.hetzner.com/general/others/data-centers-and-connection/
  network_region = "us-east" # change to `us-east` if location is ash

  # Using the default configuration you can only create a maximum of 42 agent-nodepools.

  # You can safely add or remove nodepools at the end of each list. That is due to how subnets and IPs get allocated (FILO).
  # The maximum number of nodepools you can create combined for both lists is 50 (see above).
  # Also, before decreasing the count of any nodepools to 0, it's essential to drain and cordon the nodes in question. Otherwise, it will leave your cluster in a bad state.

  # Before initializing the cluster, you can change all parameters and add or remove any nodepools. You need at least one nodepool of each kind, control plane, and agent.
  # ⚠️ The nodepool names are entirely arbitrary, but all lowercase, no special characters or underscore (dashes are allowed), and they must be unique.

  # Please note that changing labels and taints after the first run will have no effect. If needed, you can do that through Kubernetes directly.

  control_plane_nodepools = [
    {
      name        = "control-plane",
      server_type = "cpx21",
      location    = "ash",
      labels      = [
        "node.kubernetes.io/role=control-plane"
      ],
      taints      = [],
      count       = 3
      # swap_size   = "2G" # remember to add the suffix, examples: 512M, 1G
      # zram_size   = "2G" # remember to add the suffix, examples: 512M, 1G
      # kubelet_args = ["kube-reserved=cpu=250m,memory=1500Mi,ephemeral-storage=1Gi", "system-reserved=cpu=250m,memory=300Mi"]

      # Fine-grained control over placement groups (nodes in the same group are spread over different physical servers, 10 nodes per placement group max):
      placement_group = "control-planes"

      # Enable automatic backups via Hetzner (default: false)
      # backups = true

      # To disable public ips (default: false)
      # WARNING: If both values are set to "true", your server will only be accessible via a private network. Make sure you have followed
      # the instructions regarding this type of setup in README.md: "Use only private IPs in your cluster".
      # disable_ipv4 = true
      # disable_ipv6 = true
    }
  ]

  agent_nodepools = [
    {
      name        = "agent-tender",
      server_type = "cpx21",
      location    = "ash",
      labels      = [
        "gport.giuliopime.dev/agent=tender",
        "node.longhorn.io/create-default-disk=true" # this allows longhord to use the memory for PV
      ],
      taints      = [],
      count       = 2
      # swap_size   = "2G" # remember to add the suffix, examples: 512M, 1G
      # zram_size   = "2G" # remember to add the suffix, examples: 512M, 1G
      # kubelet_args = ["kube-reserved=cpu=50m,memory=300Mi,ephemeral-storage=1Gi", "system-reserved=cpu=250m,memory=300Mi"]

      # Fine-grained control over placement groups (nodes in the same group are spread over different physical servers, 10 nodes per placement group max):
      # placement_group = "default"

      # Enable automatic backups via Hetzner (default: false)
      # backups = true

      # In the case of using Longhorn, you can use Hetzner volumes instead of using the node's own storage by specifying a value from 10 to 10240 (in GB)
      # It will create one volume per node in the nodepool, and configure Longhorn to use them.
      # Something worth noting is that Volume storage is slower than node storage, which is achieved by not mentioning longhorn_volume_size or setting it to 0.
      # So for something like DBs, you definitely want node storage, for other things like backups, volume storage is fine, and cheaper.

      # I use Hetzner Storage Boxes for slow storage instead of Volumes
      longhorn_volume_size = 0
    },
  ]

  # * LB location and type, the latter will depend on how much load you want it to handle, see https://www.hetzner.com/cloud/load-balancer
  load_balancer_type     = "lb11"
  load_balancer_location = "ash"

  # You can refine a base domain name to be use in this form of nodename.base_domain for setting the reverse dns inside Hetzner
  base_domain = "gport.giuliopime.dev"

  # Cluster Autoscaler
  # Providing at least one map for the array enables the cluster autoscaler feature, default is disabled.
  # ⚠️ Based on how the autoscaler works with this project, you can only choose either x86 instances or ARM server types for ALL autoscaler nodepools.
  # If you are curious, it's ok to have a multi-architecture cluster, as most underlying container images are multi-architecture too.
  autoscaler_nodepools = [
   {
     name        = "agent-cruiser"
     server_type = "cpx21"
     location    = "ash"
     min_nodes   = 1
     max_nodes   = 15
     labels      = {
       "gport.giuliopime.dev/agent": "cruiser"
     },
     taints      = []
     # kubelet_args = ["kube-reserved=cpu=250m,memory=1500Mi,ephemeral-storage=1Gi", "system-reserved=cpu=250m,memory=300Mi"]
   },
    {
      name        = "agent-racer"
      server_type = "cpx31"
      location    = "ash"
      min_nodes   = 0
      max_nodes   = 5
      labels      = {
        "gport.giuliopime.dev/agent": "racer"
      },
      taints      = [
        {
          key= "gport.giuliopime.dev/workload"
          value= "medium"
          effect= "NoExecute"
        }
      ]
      # kubelet_args = ["kube-reserved=cpu=250m,memory=1500Mi,ephemeral-storage=1Gi", "system-reserved=cpu=250m,memory=300Mi"]
    },
  ]

  # To disable public ips on your autoscaled nodes, uncomment the following lines:
  # autoscaler_disable_ipv4 = true
  # autoscaler_disable_ipv6 = true

  cluster_autoscaler_extra_args = [
    "--enforce-node-group-min-size=true",
  ]

  # To enable Hetzner Storage Box support, you can enable csi-driver-smb, default is "false".
  enable_csi_driver_smb = true

  # To use local storage on the nodes, you can enable Longhorn, default is "false".
  # See a full recap on how to configure agent nodepools for longhorn here https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner/discussions/373#discussioncomment-3983159
  # Also see Longhorn best practices here https://gist.github.com/ifeulner/d311b2868f6c00e649f33a72166c2e5b
  enable_longhorn = true

  # When you enable Longhorn, you can go with the default settings and just modify the above two variables OR you can add a longhorn_values variable
  # with all needed helm values, see towards the end of the file in the advanced section.
  # If that file is present, the system will use it during the deploy, if not it will use the default values with the two variable above that can be customized.
  # After the cluster is deployed, you can always use HelmChartConfig definition to tweak the configuration.

  # If you want to specify the Kured version, set it below - otherwise it'll use the latest version available.
  # See https://github.com/kubereboot/kured/releases for the available versions.
  kured_version = "1.17.1"

  ingress_controller = "nginx"

  # Use the klipperLB (similar to metalLB), instead of the default Hetzner one, that has an advantage of dropping the cost of the setup.
  # Automatically "true" in the case of single node cluster (as it does not make sense to use the Hetzner LB in that situation).
  # It can work with any ingress controller that you choose to deploy.
  # Please note that because the klipperLB points to all nodes, we automatically allow scheduling on the control plane when it is active.
  enable_klipper_metal_lb = "false"

  # By default nodes are drained before k3s upgrade, which will delete and transfer all pods to other nodes.
  # Set this to false to cordon nodes instead, which just prevents scheduling new pods on the node during upgrade
  # and keeps all pods running. This may be useful if you have pods which are known to be slow to start e.g.
  # because they have to mount volumes with many files which require to get the right security context applied.
  system_upgrade_use_drain = true

  # The cluster name, by default "k3s"
  cluster_name = "gport"

  # If you want to configure a different CNI for k3s, use this flag
  # possible values: flannel (Default), calico, and cilium
  # As for Cilium, we allow infinite configurations via helm values, please check the CNI section of the readme over at https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner/#cni.
  # Also, see the cilium_values at towards the end of this file, in the advanced section.
  # ⚠️ Depending on your setup, sometimes you need your control-planes to have more than
  # 2GB of RAM if you are going to use Cilium, otherwise the pods will not start.
  cni_plugin = "calico"

  # Enables Hubble Observability to collect and visualize network traffic. Default: false
  # cilium_hubble_enabled = true

  # Configures the list of Hubble metrics to collect.
  # cilium_hubble_metrics_enabled = [
  #   "policy:sourceContext=app|workload-name|pod|reserved-identity;destinationContext=app|workload-name|pod|dns|reserved-identity;labelsContext=source_namespace,destination_namespace"
  # ]

  # IP Addresses to use for the DNS Servers, the defaults are the ones provided by Hetzner https://docs.hetzner.com/dns-console/dns/general/recursive-name-servers/.
  # The number of different DNS servers is limited to 3 by Kubernetes itself.
  # It's always a good idea to have at least 1 IPv4 and 1 IPv6 DNS server for robustness.
  dns_servers = [
    "1.1.1.1",
    "8.8.8.8",
    "2606:4700:4700::1111",
  ]

  # When this is enabled, rather than the first node, all external traffic will be routed via a control-plane loadbalancer, allowing for high availability.
  # The default is false.
  use_control_plane_lb = true

  # When the above use_control_plane_lb is enabled, you can change the lb type for it, the default is "lb11".
  control_plane_lb_type = "lb11"

  lb_hostname = "gport.giuliopime.dev"

  # It is best practice to turn this off, but for backwards compatibility it is set to "true" by default.
  # See https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner/issues/349
  # When "false". The kubeconfig file can instead be created by executing: "terraform output --raw kubeconfig > cluster_kubeconfig.yaml"
  # Always be careful to not commit this file!
  create_kubeconfig = false

  ### ADVANCED - Custom helm values for packages above (search _values if you want to located where those are mentioned upper in this file)
  # ⚠️ Inside the _values variable below are examples, up to you to find out the best helm values possible, we do not provide support for customized helm values.
  # Please understand that the indentation is very important, inside the EOTs, as those are proper yaml helm values.
  # We advise you to use the default values, and only change them if you know what you are doing!

  # You can inline the values here in heredoc-style (as the examples below with the <<EOT to EOT). Please note that the current indentation inside the EOT is important.
  # Or you can create a thepackage-values.yaml file with the content and use it here with the following syntax:
  # thepackage_values = file("thepackage-values.yaml")

  # Longhorn, all Longhorn helm values can be found at https://github.com/longhorn/longhorn/blob/master/chart/values.yaml
  # The following is an example, please note that the current indentation inside the EOT is important.
  longhorn_values = <<EOT
defaultSettings:
  createDefaultDiskLabeledNodes: true
  kubernetesClusterAutoscalerEnabled: true
  defaultDataPath: /var/longhorn
  node-down-pod-deletion-policy: delete-both-statefulset-and-deployment-pod
persistence:
  defaultFsType: ext4
  defaultClassReplicaCount: 3
  defaultClass: false
  EOT
}
