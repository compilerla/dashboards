terraform {
  required_providers {
    # Explicitly map the cloudflare provider to the correct source
    # to prevent Terraform from looking for a 'hashicorp/cloudflare' provider.
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.28.0"
    }
  }
}

resource "cloudflare_dns_record" "cname" {
  zone_id = var.zone_id
  name    = var.subdomain
  type    = "CNAME"
  content = "ghs.googlehosted.com"
  ttl     = var.ttl
  proxied = var.proxy_enabled
}
