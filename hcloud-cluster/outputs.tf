output "cluster_name" {
  value       = module.kube-hetzner.cluster_name
  description = "Shared suffix for all resources belonging to this cluster."
}

output "network_id" {
  value       = module.kube-hetzner.network_id
  description = "The ID of the HCloud network."
}

output "ssh_key_id" {
  value       = module.kube-hetzner.ssh_key_id
  description = "The ID of the HCloud SSH key."
}

output "control_planes_public_ipv4" {
  value       = module.kube-hetzner.control_planes_public_ipv4
  description = "The public IPv4 addresses of the controlplane servers."
}

output "control_planes_public_ipv6" {
  value       = module.kube-hetzner.control_planes_public_ipv6
  description = "The public IPv6 addresses of the controlplane servers."
}

output "agents_public_ipv4" {
  value       = module.kube-hetzner.agents_public_ipv4
  description = "The public IPv4 addresses of the agent servers."
}

output "agents_public_ipv6" {
  value       = module.kube-hetzner.agents_public_ipv6
  description = "The public IPv6 addresses of the agent servers."
}

output "ingress_public_ipv4" {
  value       = module.kube-hetzner.ingress_public_ipv4
  description = "The public IPv4 address of the Hetzner load balancer (with fallback to first control plane node)."
}

output "ingress_public_ipv6" {
  value       = module.kube-hetzner.ingress_public_ipv6
  description = "The public IPv6 address of the Hetzner load balancer (with fallback to first control plane node)."
}

output "lb_control_plane_ipv4" {
  value       = module.kube-hetzner.lb_control_plane_ipv4
  description = "The public IPv4 address of the Hetzner control plane load balancer."
}

output "lb_control_plane_ipv6" {
  value       = module.kube-hetzner.lb_control_plane_ipv6
  description = "The public IPv6 address of the Hetzner control plane load balancer."
}

output "k3s_endpoint" {
  value       = module.kube-hetzner.k3s_endpoint
  description = "A controller endpoint to register new nodes."
}

output "k3s_token" {
  value       = module.kube-hetzner.k3s_token
  description = "The k3s token to register new nodes."
  sensitive   = true
}

output "control_plane_nodes" {
  value       = module.kube-hetzner.control_plane_nodes
  description = "The control plane nodes."
}

output "agent_nodes" {
  value       = module.kube-hetzner.agent_nodes
  description = "The agent nodes."
}

output "domain_assignments" {
  value       = module.kube-hetzner.domain_assignments
  description = "Assignments of domains to IPs based on reverse DNS."
}

output "kubeconfig_file" {
  value       = module.kube-hetzner.kubeconfig_file
  description = "Kubeconfig file content with external IP address, or internal IP address if only private IPs are available."
  sensitive   = true
}

output "kubeconfig" {
  value       = module.kube-hetzner.kubeconfig
  description = "Kubeconfig file content with external IP address, or internal IP address if only private IPs are available."
  sensitive   = true
}

output "kubeconfig_data" {
  value       = module.kube-hetzner.kubeconfig_data
  description = "Structured kubeconfig data to supply to other providers."
  sensitive   = true
}

output "cilium_values" {
  value       = module.kube-hetzner.cilium_values
  description = "Helm values.yaml used for Cilium."
  sensitive   = true
}

output "cert_manager_values" {
  value       = module.kube-hetzner.cert_manager_values
  description = "Helm values.yaml used for cert-manager."
  sensitive   = true
}

output "csi_driver_smb_values" {
  value       = module.kube-hetzner.csi_driver_smb_values
  description = "Helm values.yaml used for SMB CSI driver."
  sensitive   = true
}

output "longhorn_values" {
  value       = module.kube-hetzner.longhorn_values
  description = "Helm values.yaml used for Longhorn."
  sensitive   = true
}

output "traefik_values" {
  value       = module.kube-hetzner.traefik_values
  description = "Helm values.yaml used for Traefik."
  sensitive   = true
}

output "nginx_values" {
  value       = module.kube-hetzner.nginx_values
  description = "Helm values.yaml used for nginx-ingress."
  sensitive   = true
}

output "haproxy_values" {
  value       = module.kube-hetzner.haproxy_values
  description = "Helm values.yaml used for HAProxy."
  sensitive   = true
}

output "nat_router_public_ipv4" {
  value       = module.kube-hetzner.nat_router_public_ipv4
  description = "The address of the NAT router, if it exists."
}

output "nat_router_public_ipv6" {
  value       = module.kube-hetzner.nat_router_public_ipv6
  description = "The address of the NAT router, if it exists."
}

output "nat_router_username" {
  value       = module.kube-hetzner.nat_router_username
  description = "The non-root user as which you can ssh into the router."
}

output "nat_router_ssh_port" {
  value       = module.kube-hetzner.nat_router_ssh_port
  description = "The SSH port for the NAT router."
}