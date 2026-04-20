# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

```bash
# Initialise (downloads oracle/oci provider)
terraform init

# Validate syntax and provider schema
terraform validate

# Format all .tf files
terraform fmt -recursive

# Plan (requires OCI credentials and a tfvars file)
terraform plan -var-file=terraform.tfvars
```

No test framework is configured. Validation is done via `terraform validate` and `terraform plan`.

## Architecture

This is a **Terraform child module** (no backend, no provider config) that provisions a complete OCI networking baseline:

- One VCN (`main.tf`)
- Internet gateway, NAT gateway, service gateway (`gateways.tf`)
- Public (default) and private route tables (`route_tables.tf`)
- Public (default) and private security lists (`security_lists.tf`)
- Public and private subnets (`subnets.tf`)

Supporting files:

- `data.tf` — looks up the Oracle Services Network CIDR for the current region
- `locals.tf` — dereferences `services[0]` once so `local.oci_service.{id,cidr_block}` is used everywhere
- `versions.tf` — pins `oracle/oci ~> 8.5.0` and `terraform >= 1.5.0`

### Key design decisions

**CIDR validation** — Terraform variable `validation` blocks cannot cross-reference other variables, so containment and overlap checks (`public_subnet_cidr` and `private_subnet_cidr` within `vcn_cidr_block`, and non-overlap with each other) are implemented as `lifecycle.precondition` blocks on `oci_core_virtual_network.vcn` in `main.tf`. These require `>= 1.5.0` for `cidrcontains()`.

**Default resource management** — OCI automatically creates a default route table and default security list with every VCN. The module manages them explicitly via `oci_core_default_route_table.public_route_table` and `oci_core_default_security_list.public_security_list`, assigning them to the public subnet.

**Service gateway guard** — `local.oci_service` indexes `services[0]` from the data source. A `lifecycle.precondition` on `oci_core_service_gateway.service_gateway` asserts `length(...services) > 0` so a region without Oracle Services Network fails with a clear message rather than a cryptic index error.

**`ssh_source_cidr` is required with no default** — callers must explicitly choose who can reach port 22 on the public subnet. There is no safe default for production use.

### Resource naming convention

All display names are prefixed with `var.vcn_display_name` (e.g. `"${var.vcn_display_name}_public_subnet"`). The Terraform resource labels match the OCI resource type without redundant prefix (e.g. `oci_core_subnet.public_subnet`, not `oci_core_subnet.vcn_public_subnet`).
