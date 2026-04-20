resource "oci_core_virtual_network" "vcn" {
  display_name   = var.vcn_display_name
  compartment_id = var.compartment_id
  dns_label      = var.vcn_dns_label
  is_ipv6enabled = false
  cidr_blocks    = [var.vcn_cidr_block]
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags

  lifecycle {
    precondition {
      condition     = cidrcontains(var.vcn_cidr_block, cidrhost(var.public_subnet_cidr, 0)) && tonumber(split("/", var.public_subnet_cidr)[1]) >= tonumber(split("/", var.vcn_cidr_block)[1])
      error_message = "public_subnet_cidr must be within vcn_cidr_block."
    }
    precondition {
      condition     = cidrcontains(var.vcn_cidr_block, cidrhost(var.private_subnet_cidr, 0)) && tonumber(split("/", var.private_subnet_cidr)[1]) >= tonumber(split("/", var.vcn_cidr_block)[1])
      error_message = "private_subnet_cidr must be within vcn_cidr_block."
    }
    precondition {
      condition     = !cidrcontains(var.public_subnet_cidr, cidrhost(var.private_subnet_cidr, 0)) && !cidrcontains(var.private_subnet_cidr, cidrhost(var.public_subnet_cidr, 0))
      error_message = "public_subnet_cidr and private_subnet_cidr must not overlap."
    }
  }
}
