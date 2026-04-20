resource "oci_core_default_route_table" "public_route_table" {
  display_name               = "${var.vcn_display_name}_public_route_table"
  compartment_id             = var.compartment_id
  manage_default_resource_id = oci_core_virtual_network.vcn.default_route_table_id
  freeform_tags              = var.freeform_tags
  defined_tags               = var.defined_tags

  route_rules {
    description       = "Route traffic via internet gateway."
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
    destination_type  = "CIDR_BLOCK"
    destination       = "0.0.0.0/0"
  }
}

resource "oci_core_route_table" "private_route_table" {
  display_name   = "${var.vcn_display_name}_private_route_table"
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags

  route_rules {
    description       = "Route traffic via NAT gateway."
    network_entity_id = oci_core_nat_gateway.nat_gateway.id
    destination_type  = "CIDR_BLOCK"
    destination       = "0.0.0.0/0"
  }

  route_rules {
    description       = "Route OCI services via service gateway."
    network_entity_id = oci_core_service_gateway.service_gateway.id
    destination_type  = "SERVICE_CIDR_BLOCK"
    destination       = local.oci_service.cidr_block
  }
}
