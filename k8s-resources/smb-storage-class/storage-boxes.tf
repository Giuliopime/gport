# Storage Boxes are not yet supported via Terraform
# see issue https://github.com/hetznercloud/terraform-provider-hcloud/issues/1144
# so right now one is created manually and probably will remain like that

# TODO: Create once Hetzner supports Storage Boxes creation via Terraform

# the csi-driver-smb chart is already added to the cluster via the kube-hetzner volume

# k8s secret with username and password for hetzner storage boxes
# resource "kubernetes_secret" "smbcreds" {
#   metadata {
#     name = "smbcreds"
#     namespace = "default"
#   }
#
#   data = {
#     username = var.smb_username
#     password = var.smb_password
#   }
#
#   type = "Opaque"
# }
#
# # StorageClass that uses the storage box
# resource "kubernetes_storage_class" "smb" {
#   metadata {
#     name = "smb"
#   }
#
#   storage_provisioner = "smb.csi.k8s.io"
#
#   parameters = {
#     source = var.smb_source
#     "csi.storage.k8s.io/provisioner-secret-name"      = kubernetes_secret.smbcreds.metadata[0].name
#     "csi.storage.k8s.io/provisioner-secret-namespace" = kubernetes_secret.smbcreds.metadata[0].namespace
#     "csi.storage.k8s.io/node-stage-secret-name"       = kubernetes_secret.smbcreds.metadata[0].name
#     "csi.storage.k8s.io/node-stage-secret-namespace"  = kubernetes_secret.smbcreds.metadata[0].namespace
#   }
#
#   reclaim_policy      = "Retain"
#   volume_binding_mode = "Immediate"
#   allow_volume_expansion = true
#
#   mount_options = [
#     "dir_mode=0777",
#     "file_mode=0777",
#     "uid=1001",
#     "gid=1001"
#   ]
#
#   depends_on = [
#     kubernetes_secret.smbcreds
#   ]
# }
