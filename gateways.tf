resource "oci_core_internet_gateway" "internet_gateway" {
  display_name   = "${var.vcn_display_name}_internet_gateway"
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  enabled        = true
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
}

resource "oci_core_nat_gateway" "nat_gateway" {
  display_name   = "${var.vcn_display_name}_nat_gateway"
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  block_traffic  = var.nat_gateway_block_traffic
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
}

resource "oci_core_service_gateway" "service_gateway" {
  display_name   = "${var.vcn_display_name}_service_gateway"
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags

  services {
    service_id = local.oci_service.id
  }

  lifecycle {
    precondition {
      condition     = length(data.oci_core_services.all_oci_services.services) > 0
      error_message = "No OCI services matched the service gateway filter. Verify the region supports Oracle Services Network."
    }
  }
}
