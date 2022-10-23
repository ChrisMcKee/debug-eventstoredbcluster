# CA
locals {
  algorithm_type = "RSA"
}
resource "tls_private_key" "ca" {
  algorithm = local.algorithm_type
  rsa_bits  = 4096
}

locals {
  ca_common_name = var.ca_common_name
  ca_valid_hours = var.ca_valid_days * 24
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem

  subject {
    common_name = local.ca_common_name

    country             = "gb"
    locality            = "Wales"
    organization        = "Test Eventstore Ltd"
    organizational_unit = "eventstore-service"
    province            = "wales"
    serial_number       = "eventstoretedt01"
  }

  validity_period_hours = local.ca_valid_hours

  is_ca_certificate = true

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing"
  ]
}

resource "local_file" "tls_ca_cert" {
  content  = chomp(tls_self_signed_cert.ca.cert_pem)
  filename = "${path.module}/../certs/ca/ca.crt"
}

# Certs
locals {
  subjects_common_names = var.subjects_common_names
}

resource "tls_private_key" "subjects" {
  for_each = local.subjects_common_names

  algorithm = local.algorithm_type
  rsa_bits  = 4096
}

resource "tls_cert_request" "subjects" {
  for_each = local.subjects_common_names

  private_key_pem = tls_private_key.subjects[each.key].private_key_pem

  subject {
    common_name = "*.${each.value}"

    country             = "gb"
    locality            = "Wales"
    organization        = "Test Eventstore Ltd"
    organizational_unit = "eventstore-service"
    province            = "wales"
  }

  dns_names = ["*.gb.${each.value}", "localhost"]
}

locals {
  subjects_valid_hours = var.subjects_valid_days * 24
}

resource "tls_locally_signed_cert" "subjects" {
  for_each = local.subjects_common_names

  cert_request_pem   = tls_cert_request.subjects[each.key].cert_request_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem
  ca_private_key_pem = tls_self_signed_cert.ca.private_key_pem

  validity_period_hours = local.subjects_valid_hours

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]
}

resource "local_file" "tls_domain_key" {
  for_each = local.subjects_common_names
  content  = chomp(tls_private_key.subjects[each.key].private_key_pem)
  filename = "${path.module}/../certs/nodecert/${replace(each.key, "*", "wc")}.key"
}

resource "local_file" "tls_domain_cert" {
  for_each = local.subjects_common_names
  content  = chomp(tls_locally_signed_cert.subjects[each.key].cert_pem)
  filename = "${path.module}/../certs/nodecert/${replace(each.key, "*", "wc")}.crt"
}

