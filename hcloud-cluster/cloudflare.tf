resource "cloudflare_dns_record" "kube_public_api" {
  zone_id = var.cloudflare_zone_id
  name    = "public.api.kube"
  ttl     = 1
  type    = "A"
  content = module.kube-hetzner.lb_control_plane_ipv4
  # makes it so connection go directly to the cluster without passing through Cloudflare
  proxied = false
}

resource "cloudflare_dns_record" "grafana" {
  zone_id = var.cloudflare_zone_id
  name    = "grafana"
  type    = "A"
  ttl     = 1
  proxied = true
  content = module.kube-hetzner.ingress_public_ipv4
}

resource "cloudflare_dns_record" "longhorn" {
  zone_id = var.cloudflare_zone_id
  name    = "longhorn"
  type    = "A"
  ttl     = 1
  proxied = true
  content = module.kube-hetzner.ingress_public_ipv4
}

# argoCD
resource "cloudflare_dns_record" "argocd_grpc" {
  zone_id = var.cloudflare_zone_id
  name    = "grpc.argocd"
  type    = "A"
  ttl     = 1
  proxied = false
  content = module.kube-hetzner.ingress_public_ipv4
}

resource "cloudflare_dns_record" "argocd" {
  zone_id = var.cloudflare_zone_id
  name    = "argocd"
  type    = "A"
  ttl     = 1
  proxied = true
  content = module.kube-hetzner.ingress_public_ipv4
}

resource "cloudflare_dns_record" "wg-easy" {
  zone_id = var.cloudflare_zone_id
  name    = "wg"
  type    = "A"
  ttl     = 1
  proxied = true
  content = module.kube-hetzner.ingress_public_ipv4
}


///////////////
//// INDEX ////
///////////////
resource "cloudflare_dns_record" "index_api" {
  zone_id = var.cloudflare_index_zone_id
  name    = "api"
  type    = "A"
  ttl     = 1
  proxied = true
  content = module.kube-hetzner.ingress_public_ipv4
}
