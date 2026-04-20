locals {
  oci_service = data.oci_core_services.all_oci_services.services[0]
}
