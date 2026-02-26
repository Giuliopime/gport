# gport
this is my IaC for my personal projects

## Hetzner cluster
I use Hetzner as cloud provider, I create a Kubernetes cluster using k3s hosted on non-dedicated servers.    
this part is managed via terraform and the [terraform-hcloud-kube-hetzner](https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner) module.  
it lives in the `/hcloud-cluster` folder.

#### usage
1) set up terraform variables:  
```shell
cp hcloud_cluster/terraform.tfvars.template hcloud_cluster/terraform.tfvars
```
then fill the file with your values, each variable has a comment explaining how to obtain it.  

2) follow kube-hetzner module [installation instructions](https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner)  
3) run terraform apply
```shell
terraform apply
```
4) it will take a bit to create the cluster, once done you can get the kubeconfig with
```shell
terraform output -raw kubeconfig > ./kubeconfig 
```

#### what gets created
- cloudflare records for kubernetes api and grafana dashboard
- a control-plane node pool with 3 nodes (recommended server type at least `cpx21` because 4GB of RAM are a minimum in most cases to handle the cluster well)  
- an agent node pool for lightweight applications and core kubernetes services (the nodes are called `agent-sailboat`)  
- an autoscaler agent node pool for general purpose applications (called `agent-as-sailboat`)
- 2 Hetzner load balancers, one for the control plane and one for the agent nodes
- all nodes use [`OpenSUSE MicroOS`](https://microos.opensuse.org)

kubernetes wise (installed directly via the kube-hetzner Terraform module):
- calico as the CNI
- nginx
- longhorn for efficient and scalable storage management  
  is used to have fast persistant storage for stuff like DBs.  
  uses all the nodes nvme storage and manages them together giving you a simple StorageClass that you can use in your PVCs.  

  will only use the storage of nodes with the label `node.longhorn.io/create-default-disk=true`    
  the default StorageClass name is `longhorn`  
- kured for automatic kernel updates
- cluster autoscaler (bless it)
- smb support: in the future I wanna use Hetzner Storage Boxes for hosting immich and other stuff

## Kubernetes resources
Kubernetes resources are managed using ArgoCD in the `/k8s-resources` folder.  

#### secrets management
Secrets cannot be commited to git, for this reason we use [sealed secrets](https://github.com/bitnami-labs/sealed-secrets)  

1) Install `kubeseal` on your local machine:
    ```shell
    brew install kubeseal
    ``` 
2) Follow [installation instructions](https://github.com/bitnami-labs/sealed-secrets?tab=readme-ov-file#installation) for sealed-secrets
    ```shell
    kubectl apply -k ./sealed-secrets-installation
    ```
3) Prepare secrets:  
   In each folder under `/k8s-resources` there can be a `/secrets` folder.  
   Each contains a `*-secret.template.yaml` file, duplicate it and remove the `.template` part from the new file name. Then fill out the values.
4) Seal the secrets:
    ```shell
    chmod +x scripts/seal-secrets.sh && scripts/seal-secrets.sh
    ```
   (Recommended) You can also provide a specific folder to the script, instead of sealing all secrets: `scripts/seal-secrets.sh cert-manager`

5) Commit and push the changes

> devs note:  
> Argocd ignores subfolders when we choose a folder as a source.  
> Even if that's the case, I still decided to ignore `secrets` folders explicitly, 'cause you never know.
#### argocd
1) [install ArgoCD](https://argo-cd.readthedocs.io/en/stable/getting_started/) in the cluster:
    ```shell
    kubectl create namespace argocd
    kubectl apply -k ./argocd-installation
    ```

    and on your local machine:
    ```shell
    brew install argocd
    ```
2) Configure two Nginx ingresses for HTTP/HTTPS and gRPC:
    ```shell
    kubectl apply -f ./argocd-installation/argocd-nginx-ingresses.yaml
    ```
3) Login via the cli
    ```shell
    argocd admin initial-password -n argocd
    ```
   use username: admin and the password from the previous command to login
   ```shell
    argocd login grpc.argocd.giuliopime.dev
    ```
   then change the password and delete the old one
    ```shell
    argocd account update-password
    ```
    ```shell
    kubectl delete secret argocd-initial-admin-secret -n argocd
    ```
4) Access the web UI [argocd.giuliopime.dev](https://argocd.giuliopime.dev) using the credentials created at the previous step
5) Apply the resources in the `/k8s-resources` folder:
    ```shell
    kubectl apply -f ./argocd/gport.yaml
    ```
---

## suggested tools / resources
- [Lens IDE](https://k8slens.dev)
