resource "cloudflare_dns_record" "public_api_kube_dns_record" {
  zone_id = var.cloudflare_zone_id
  name = "public.api.kube"
  ttl = 1
  type = "A"
  content = module.kube-hetzner.lb_control_plane_ipv4
  # makes it so connection go directly to the cluster without passing through Cloudflare
  proxied = false
}

resource "cloudflare_dns_record" "grafana_dns_record" {
  zone_id = var.cloudflare_zone_id
  name    = "grafana"
  type    = "A"
  ttl     = 1
  proxied = true
  content = module.kube-hetzner.ingress_public_ipv4
}

# argoCD
resource "cloudflare_dns_record" "argocd_grpc_dns_record" {
  zone_id = var.cloudflare_zone_id
  name    = "grpc.argocd"
  type    = "A"
  ttl     = 1
  proxied = true
  content = module.kube-hetzner.ingress_public_ipv4
}

resource "cloudflare_dns_record" "argocd_dns_record" {
  zone_id = var.cloudflare_zone_id
  name    = "argocd"
  type    = "A"
  ttl     = 1
  proxied = true
  content = module.kube-hetzner.ingress_public_ipv4
}
