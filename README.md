# terraform-oci-module-networking

This Terraform module provisions an all-inclusive virtual cloud network with internet connectivity,
ready to attach compute, database, or Kubernetes/K8s workloads!

## Architecture

```
VCN (vcn_cidr_block)
├── Internet Gateway
├── NAT Gateway
├── Service Gateway  (Oracle Services Network — e.g. Object Storage)
│
├── Public Subnet  (public_subnet_cidr)
│   ├── Default Route Table  →  Internet Gateway (0.0.0.0/0)
│   └── Default Security List
│       ├── Ingress: TCP 22 from ssh_source_cidr
│       ├── Ingress: ICMP type 3 (unreachable) from 0.0.0.0/0
│       ├── Ingress: ICMP type 3 code 4 from vcn_cidr_block
│       └── Egress:  all traffic to 0.0.0.0/0
│
└── Private Subnet  (private_subnet_cidr)
    ├── Private Route Table  →  NAT Gateway (0.0.0.0/0)
    │                        →  Service Gateway (OSN CIDR)
    └── Private Security List
        ├── Ingress: all traffic from vcn_cidr_block
        ├── Ingress: ICMP type 3 code 4 from 0.0.0.0/0
        └── Egress:  all traffic to 0.0.0.0/0
```

OCI creates a default route table and default security list with every VCN.
This module manages them explicitly and assigns them to the public subnet so they remain under Terraform control.

## Usage

```hcl
module "networking" {
  source = "github.com/karthikgappiah/terraform-oci-module-network"

  compartment_id = var.compartment_id

  vcn_cidr_block   = "10.0.0.0/16"
  vcn_display_name = "prod-vcn"
  vcn_dns_label    = "prodvcn"

  public_subnet_cidr      = "10.0.0.0/24"
  public_subnet_dns_label = "pubsub"

  private_subnet_cidr      = "10.0.1.0/24"
  private_subnet_dns_label = "prisub"

  # Restrict to your bastion or VPN egress IP — avoid 0.0.0.0/0 in production
  ssh_source_cidr = "203.0.113.0/32"

  freeform_tags = {
    environment = "production"
    managed_by  = "terraform"
  }
}

# Pass subnet OCIDs to other modules
output "public_subnet_id"  { value = module.networking.public_subnet_id }
output "private_subnet_id" { value = module.networking.private_subnet_id }
```

## Requirements

| Name       | Version  |
| ---------- | -------- |
| terraform  | >= 1.5.0 |
| oracle/oci | ~> 8.5.0 |

Terraform 1.5+ is required for `cidrcontains()` (used in CIDR validation preconditions) and `lifecycle.precondition` blocks.

## Inputs

| Name                        | Description                                                                                                                                                   | Type          | Default         | Required |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------- | --------------- | -------- |
| `compartment_id`            | OCID of the compartment where all resources are created.                                                                                                      | `string`      | —               | yes      |
| `vcn_cidr_block`            | CIDR block for the VCN.                                                                                                                                       | `string`      | `"10.0.0.0/16"` | no       |
| `vcn_display_name`          | Display name for the VCN; used as a prefix for all derived resource names.                                                                                    | `string`      | `"vcn"`         | no       |
| `vcn_dns_label`             | DNS label for the VCN. Must start with a letter, be alphanumeric, ≤ 15 characters.                                                                            | `string`      | `"vcn"`         | no       |
| `public_subnet_cidr`        | CIDR block for the public subnet. Must be within `vcn_cidr_block` and must not overlap `private_subnet_cidr`.                                                 | `string`      | `"10.0.0.0/24"` | no       |
| `public_subnet_dns_label`   | DNS label for the public subnet. Same format rules as `vcn_dns_label`.                                                                                        | `string`      | `"pubsub"`      | no       |
| `private_subnet_cidr`       | CIDR block for the private subnet. Must be within `vcn_cidr_block` and must not overlap `public_subnet_cidr`.                                                 | `string`      | `"10.0.1.0/24"` | no       |
| `private_subnet_dns_label`  | DNS label for the private subnet. Same format rules as `vcn_dns_label`.                                                                                       | `string`      | `"prisub"`      | no       |
| `ssh_source_cidr`           | Source CIDR permitted to reach port 22 on the public subnet. No default — callers must make an explicit choice.                                               | `string`      | —               | yes      |
| `nat_gateway_block_traffic` | When `true`, the NAT gateway drops all outbound traffic. Use during maintenance windows to cut private subnet internet egress without destroying the gateway. | `bool`        | `false`         | no       |
| `freeform_tags`             | Freeform tags applied to all resources.                                                                                                                       | `map(string)` | `{}`            | no       |
| `defined_tags`              | Defined tags applied to all resources, in `{"Namespace.Key" = "value"}` form.                                                                                 | `map(string)` | `{}`            | no       |

### CIDR validation

Variable `validation` blocks cannot cross-reference other variables in Terraform,
so containment and overlap checks are implemented as `lifecycle.precondition` blocks on the VCN resource:

- `public_subnet_cidr` must be within `vcn_cidr_block`
- `private_subnet_cidr` must be within `vcn_cidr_block`
- `public_subnet_cidr` and `private_subnet_cidr` must not overlap each other

These fire at plan time and produce a clear error message if violated.

## Outputs

| Name                       | Description                                 |
| -------------------------- | ------------------------------------------- |
| `vcn_id`                   | OCID of the VCN.                            |
| `public_subnet_id`         | OCID of the public subnet.                  |
| `private_subnet_id`        | OCID of the private subnet.                 |
| `default_dhcp_options_id`  | OCID of the VCN's default DHCP options.     |
| `internet_gateway_id`      | OCID of the internet gateway.               |
| `nat_gateway_id`           | OCID of the NAT gateway.                    |
| `service_gateway_id`       | OCID of the service gateway.                |
| `public_route_table_id`    | OCID of the public (default) route table.   |
| `private_route_table_id`   | OCID of the private route table.            |
| `public_security_list_id`  | OCID of the public (default) security list. |
| `private_security_list_id` | OCID of the private security list.          |

## Development

```bash
# Download the oracle/oci provider
terraform init

# Validate syntax and provider schema
terraform validate

# Format all .tf files
terraform fmt -recursive

# Plan (requires OCI credentials and a tfvars file)
terraform plan -var-file=terraform.tfvars
```

No test framework is configured.
Correctness is verified via `terraform validate` and `terraform plan` against a real OCI tenancy.

A `terraform.tfvars.example` file is included;
copy it to `terraform.tfvars` and fill in your tenancy values before running a plan.
