# Longhorn best practices

The following settings are provided as an example how longhorn should be configured  in a production cluster, especially if it is deployed on Hetzner Cloud infrastructure.

Hetzner server nodes provide local storage and allow up to five attached volumes (with a size of up to 10TiB each)
Local storage is provided by NVMe storage and therefore is much faster than the attached volumes, but limited in size (max 300GiB usable).

It is assumed that the cluster creation is already done, e.g. via terraform scripts provided by the great [kube-hetzner](https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner) project.

## Initial configuration

Also you want to control the nodes that are used for storage. So it is suggested to set the option `Create default disk only on labeled node` to `true`
This is done via a setting in the longhorn helm chart:

```yaml
defaultSettings:
  createDefaultDiskLabeledNodes: true
  kubernetesClusterAutoscalerEnabled: true # if autoscaler is active in the cluster
  defaultDataPath: /var/lib/longhorn
  # ensure pod is moved to an healthy node if current node is down:
  node-down-pod-deletion-policy: delete-both-statefulset-and-deployment-pod
persistence:
  defaultClass: true
  defaultFsType: ext4
  defaultClassReplicaCount: 3
```

## Node preparation

### Label the node

The following label signals longhorn to use a dedicated config. The config must be provided via an annotation. If the label is present, longhorn will not create a default disk but follows the config provided in the annotation.

### add the 'config' label
```
kubectl label node <node> node.longhorn.io/create-default-disk='config'
```

### remove the label
```bash
# remove label
kubectl label node <node> node.longhorn.io/create-default-disk-
```

## Longhorn-relevant annotation

See also [longhorn default disk configuration](https://longhorn.io/docs/1.3.2/advanced-resources/default-disk-and-node-config/#customizing-default-disks-for-new-nodes)

The default disk configuration is provided by annotating the node. 
In the example below you find a configuration for a two disk setup - the internal disk and one external hcloud volume (mounted at `/var/longhorn`).

`storageReserved` should be 25% for the local disk, 10% for attached dedicated hcloud volumes.
So if the local disk space is 160GiB, 40GiB (42949672960 bytes) should be defined as reserved.
Also we define tags for the different disks - "nvme" for the fast, internal disk, "ssd" for the slow, hcloud volume.

```
kubectl annotate node <storagenode> node.longhorn.io/default-disks-config='[ { "path":"/var/lib/longhorn","allowScheduling":true, "storageReserved":21474836240, "tags":[ "nvme" ]}, { "name":"hcloud-volume", "path":"/var/longhorn","allowScheduling":true, "storageReserved":10737418120,"tags":[ "ssd" ] }]'
```

## StorageClasses

To ensure that the volume is using the right storage, the corresponding `StorageClass` needs to be defined:

```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: longhorn-fast
provisioner: driver.longhorn.io
allowVolumeExpansion: true
reclaimPolicy: Delete
volumeBindingMode: Immediate
parameters:
  numberOfReplicas: "3"
  staleReplicaTimeout: "2880" # 48 hours in minutes
  fromBackup: ""
  fsType: "ext4"
  diskSelector: "nvme"
  
  #  backingImage: "bi-test"
  #  backingImageDataSourceType: "download"
  #  backingImageDataSourceParameters: '{"url": "https://backing-image-example.s3-region.amazonaws.com/test-backing-image"}'
  #  backingImageChecksum: "SHA512 checksum of the backing image"
  #  diskSelector: "ssd,fast"
  #  nodeSelector: "storage,fast"
  #  recurringJobSelector: '[
  #   {
  #     "name":"snap",
  #     "isGroup":true,
  #   },
  #   {
  #     "name":"backup",
  #     "isGroup":false,
  #   }
  #  ]'
  ````

## Benchmarks

Below find some results with different StorageClasses using the benchmark utility `dbench`.
Besides disk selection and replicas als the used server type for the storage nodes has a huge impact (vCPU, RAM).

### Dbench


```bash
# StorageClass longhorn (3 replicas, hcloud-volume)
==================
= Dbench Summary =
==================
Random Read/Write IOPS: 4202/240. BW: 228MiB/s / 26.2MiB/s
Average Latency (usec) Read/Write: 2716.04/18.33
Sequential Read/Write: 305MiB/s / 66.3MiB/s
Mixed Random Read/Write IOPS: 823/272


# StorageClass longhorn-fast (3 replicas, internal disk)
==================
= Dbench Summary =
==================
Random Read/Write IOPS: 7305/3737. BW: 250MiB/s / 62.1MiB/s
Average Latency (usec) Read/Write: 1789.55/
Sequential Read/Write: 299MiB/s / 67.8MiB/s
Mixed Random Read/Write IOPS: 4446/1482

Random Read/Write IOPS: 6914/3661. BW: 256MiB/s / 57.9MiB/s
Average Latency (usec) Read/Write: 1801.84/
Sequential Read/Write: 275MiB/s / 62.6MiB/s
Mixed Random Read/Write IOPS: 4908/1632

# StorageClass longhorn-fast-xfs (3 replicas, internal disk)
==================
= Dbench Summary =
==================
Random Read/Write IOPS: 5887/4083. BW: 244MiB/s / 44.8MiB/s
Average Latency (usec) Read/Write: 2720.66/
Sequential Read/Write: 278MiB/s / 46.2MiB/s
Mixed Random Read/Write IOPS: 3880/1298

```
