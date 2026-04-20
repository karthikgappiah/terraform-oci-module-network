resource "oci_core_default_security_list" "public_security_list" {
  display_name               = "${var.vcn_display_name}_public_security_list"
  compartment_id             = var.compartment_id
  manage_default_resource_id = oci_core_virtual_network.vcn.default_security_list_id
  freeform_tags              = var.freeform_tags
  defined_tags               = var.defined_tags

  egress_security_rules {
    description      = "Allows all outbound traffic."
    protocol         = "all"
    destination_type = "CIDR_BLOCK"
    destination      = "0.0.0.0/0"
    stateless        = false
  }

  ingress_security_rules {
    description = "Allows SSH from the configured source CIDR."
    protocol    = "6"
    source_type = "CIDR_BLOCK"
    source      = var.ssh_source_cidr
    stateless   = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    description = "Allows HTTPS from anywhere."
    protocol    = "6"
    source_type = "CIDR_BLOCK"
    source      = "0.0.0.0/0"
    stateless   = false

    tcp_options {
      min = 443
      max = 443
    }
  }

  ingress_security_rules {
    description = "Allows HTTP from anywhere."
    protocol    = "6"
    source_type = "CIDR_BLOCK"
    source      = "0.0.0.0/0"
    stateless   = false

    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    description = "Allows ICMP type-3 (destination unreachable, all codes) from the VCN."
    protocol    = "1"
    source_type = "CIDR_BLOCK"
    source      = var.vcn_cidr_block
    stateless   = false

    icmp_options {
      type = 3
    }
  }

  ingress_security_rules {
    description = "Allows ICMP type-3 code-4 (fragmentation needed) from anywhere."
    protocol    = "1"
    source_type = "CIDR_BLOCK"
    source      = "0.0.0.0/0"
    stateless   = false

    icmp_options {
      type = 3
      code = 4
    }
  }
}

resource "oci_core_security_list" "private_security_list" {
  display_name   = "${var.vcn_display_name}_private_security_list"
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags

  egress_security_rules {
    description      = "Allows all outbound traffic."
    protocol         = "all"
    destination_type = "CIDR_BLOCK"
    destination      = "0.0.0.0/0"
    stateless        = false
  }

  ingress_security_rules {
    description = "Allows SSH from within the VCN."
    protocol    = "6"
    source_type = "CIDR_BLOCK"
    source      = var.vcn_cidr_block
    stateless   = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    description = "Allows ICMP type-3 (destination unreachable, all codes) from the VCN."
    protocol    = "1"
    source_type = "CIDR_BLOCK"
    source      = var.vcn_cidr_block
    stateless   = false

    icmp_options {
      type = 3
    }
  }

  ingress_security_rules {
    description = "Allows ICMP type-3 code-4 (fragmentation needed) from anywhere."
    protocol    = "1"
    source_type = "CIDR_BLOCK"
    source      = "0.0.0.0/0"
    stateless   = false

    icmp_options {
      type = 3
      code = 4
    }
  }
}
