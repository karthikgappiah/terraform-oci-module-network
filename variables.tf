variable "compartment_id" {
  description = "The OCID of the compartment where networking resources will be created."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.compartment\\.", var.compartment_id))
    error_message = "compartment_id must be a valid compartment OCID."
  }
}

variable "vcn_cidr_block" {
  description = "The CIDR block for the VCN."
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.vcn_cidr_block))
    error_message = "vcn_cidr_block must be a valid CIDR block."
  }
}

variable "vcn_display_name" {
  description = "Display name for the VCN. Used as a prefix for derived resource display names."
  type        = string
  default     = "vcn"
}

variable "vcn_dns_label" {
  description = "DNS label for the VCN. Must start with a letter, be alphanumeric, and 15 characters or fewer."
  type        = string
  default     = "vcn"
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9]{0,14}$", var.vcn_dns_label))
    error_message = "vcn_dns_label must start with a letter, be alphanumeric, and 15 characters or fewer."
  }
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet. Must be within vcn_cidr_block and must not overlap private_subnet_cidr."
  type        = string
  default     = "10.0.0.0/24"
  validation {
    condition     = can(cidrnetmask(var.public_subnet_cidr))
    error_message = "public_subnet_cidr must be a valid CIDR block."
  }
}

variable "public_subnet_dns_label" {
  description = "DNS label for the public subnet. Must start with a letter, be alphanumeric, and 15 characters or fewer."
  type        = string
  default     = "pubsub"
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9]{0,14}$", var.public_subnet_dns_label))
    error_message = "public_subnet_dns_label must start with a letter, be alphanumeric, and 15 characters or fewer."
  }
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet. Must be within vcn_cidr_block and must not overlap public_subnet_cidr."
  type        = string
  default     = "10.0.1.0/24"
  validation {
    condition     = can(cidrnetmask(var.private_subnet_cidr))
    error_message = "private_subnet_cidr must be a valid CIDR block."
  }
}

variable "private_subnet_dns_label" {
  description = "DNS label for the private subnet. Must start with a letter, be alphanumeric, and 15 characters or fewer."
  type        = string
  default     = "prisub"
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9]{0,14}$", var.private_subnet_dns_label))
    error_message = "private_subnet_dns_label must start with a letter, be alphanumeric, and 15 characters or fewer."
  }
}

variable "ssh_source_cidr" {
  description = "The source CIDR block permitted to reach port 22 on the public subnet. Use 0.0.0.0/0 only if no bastion or VPN is available."
  type        = string
  validation {
    condition     = can(cidrnetmask(var.ssh_source_cidr))
    error_message = "ssh_source_cidr must be a valid CIDR block."
  }
}

variable "nat_gateway_block_traffic" {
  description = "When true, the NAT gateway drops all outbound traffic. Set to true during maintenance windows to cut private subnet internet egress without destroying the gateway."
  type        = bool
  default     = false
}

variable "freeform_tags" {
  description = "Freeform tags to apply to all resources. Keys and values must be strings."
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "Defined tags to apply to all resources, in the form {\"Namespace.Key\" = \"value\"}."
  type        = map(string)
  default     = {}
}
