output "vcn_id" {
  description = "The OCID of the VCN."
  value       = oci_core_virtual_network.vcn.id
}

output "public_subnet_id" {
  description = "The OCID of the public subnet."
  value       = oci_core_subnet.public_subnet.id
}

output "private_subnet_id" {
  description = "The OCID of the private subnet."
  value       = oci_core_subnet.private_subnet.id
}

output "default_dhcp_options_id" {
  description = "The OCID of the VCN's default DHCP options."
  value       = oci_core_virtual_network.vcn.default_dhcp_options_id
}

output "internet_gateway_id" {
  description = "The OCID of the internet gateway."
  value       = oci_core_internet_gateway.internet_gateway.id
}

output "nat_gateway_id" {
  description = "The OCID of the NAT gateway."
  value       = oci_core_nat_gateway.nat_gateway.id
}

output "service_gateway_id" {
  description = "The OCID of the service gateway."
  value       = oci_core_service_gateway.service_gateway.id
}

output "public_route_table_id" {
  description = "The OCID of the public (default) route table."
  value       = oci_core_default_route_table.public_route_table.id
}

output "private_route_table_id" {
  description = "The OCID of the private route table."
  value       = oci_core_route_table.private_route_table.id
}

output "public_security_list_id" {
  description = "The OCID of the public (default) security list."
  value       = oci_core_default_security_list.public_security_list.id
}

output "private_security_list_id" {
  description = "The OCID of the private security list."
  value       = oci_core_security_list.private_security_list.id
}
