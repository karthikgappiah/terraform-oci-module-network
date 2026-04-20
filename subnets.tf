resource "oci_core_subnet" "public_subnet" {
  display_name               = "${var.vcn_display_name}_public_subnet"
  dns_label                  = var.public_subnet_dns_label
  cidr_block                 = var.public_subnet_cidr
  prohibit_public_ip_on_vnic = false
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_virtual_network.vcn.id
  dhcp_options_id            = oci_core_virtual_network.vcn.default_dhcp_options_id
  route_table_id             = oci_core_default_route_table.public_route_table.id
  security_list_ids          = [oci_core_default_security_list.public_security_list.id]
  freeform_tags              = var.freeform_tags
  defined_tags               = var.defined_tags
}

resource "oci_core_subnet" "private_subnet" {
  display_name               = "${var.vcn_display_name}_private_subnet"
  dns_label                  = var.private_subnet_dns_label
  cidr_block                 = var.private_subnet_cidr
  prohibit_public_ip_on_vnic = true
  prohibit_internet_ingress  = true
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_virtual_network.vcn.id
  dhcp_options_id            = oci_core_virtual_network.vcn.default_dhcp_options_id
  route_table_id             = oci_core_route_table.private_route_table.id
  security_list_ids          = [oci_core_security_list.private_security_list.id]
  freeform_tags              = var.freeform_tags
  defined_tags               = var.defined_tags
}
