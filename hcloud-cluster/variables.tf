variable "hcloud_token" {
  type = string
  sensitive = true
  description = "Hetzner API token: create a new project in Hetzner --> Security --> API Tokens --> create one with 'read and write' permissions"
}

variable "cloudflare_zone_id" {
  type = string
  sensitive = true
  description = "open your domain dashboard --> Overview --> scroll down until `API` on the right --> Zone ID"
}

variable "cloudflare_api_token" {
  type = string
  sensitive = true
  description = "Cloudflare --> Profile (top right) --> Api Tokens --> generate a token with `All zones - Zone:Read, SSL and Certificates:Edit, DNS:Edit`"
}