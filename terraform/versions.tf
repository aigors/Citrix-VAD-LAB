terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # vSphere 8.0 is supported from provider v2.3.0; v2.10+ is required for the
    # vtpm block and Windows Server 2022/2025 guest IDs used on vSphere 8.0 U2+.
    vsphere = {
      source  = "vmware/vsphere"
      version = ">= 2.10.0, < 3.0.0"
    }
  }

  # (Optional) HCP Terraform / Terraform Cloud remote state.
  # Replaces the old 'backend "remote"' block.
  # cloud {
  #   organization = "TechDrabble"
  #   workspaces {
  #     name = "cvad-lab"
  #   }
  # }
}
