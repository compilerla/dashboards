output "record_id" {
  description = "The ID of the created Cloudflare record."
  value       = cloudflare_dns_record.cname.id
}
