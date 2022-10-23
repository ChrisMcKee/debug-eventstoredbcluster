output "subjects_tls_key_pems" {
  sensitive = true
  value     = { for idx, cn in local.subjects_common_names : cn => tls_private_key.subjects[idx].private_key_pem }
}

output "subjects_tls_crt_pems" {
  value = { for idx, cn in local.subjects_common_names : cn => tls_locally_signed_cert.subjects[idx].cert_pem }
}

output "public_key_pem" {
  value = tls_self_signed_cert.ca.cert_pem
}
