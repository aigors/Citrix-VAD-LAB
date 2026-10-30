variable "vsphere_server" {
  description = "vCenter server for the environment"
  type        = string
}

variable "vsphere_user" {
  description = "vCenter user for the environment"
  type        = string
}

variable "vsphere_password" {
  description = "vCenter password for the environment"
  type        = string
  sensitive   = true
}

variable "vsphere_allow_unverified_ssl" {
  description = "Skip vCenter certificate validation (self-signed VMCA cert)"
  type        = bool
  default     = true
}

variable "vsphere_datacenter" {
  description = "vsphere datacenter"
  type        = string
}

variable "vsphere_datastore" {
  description = "vsphere datastore to deploy"
  type        = string
}

variable "vsphere_rp" {
  description = "vsphere resource pool (CLUSTER/Resources for the cluster root pool)"
  type        = string
}

variable "vsphere_folder" {
  description = "VM folder to create for the lab"
  type        = string
  default     = "Citrix-Lab"
}

variable "vsphere_template" {
  description = "vsphere template or vm to clone"
  type        = string
}

variable "vsphere_network" {
  description = "vsphere network for deployed vms"
  type        = string
}

variable "vsphere_linkedclones" {
  description = "Use linked clones to deploy (source VM must have a single snapshot)"
  type        = bool
  default     = true
}

variable "vsphere_timezone" {
  description = "Windows time zone index to use for deployed machines"
  type        = number
}

variable "vsphere_customize_timeout" {
  description = "Minutes to wait for guest customization (sysprep + domain join) to finish"
  type        = number
  default     = 30
}

variable "vm_hardware_version" {
  description = "Virtual hardware version (20 = vSphere 8.0, 21 = vSphere 8.0 U2). null keeps the template's version"
  type        = number
  default     = null
}

variable "vm_efi_secure_boot" {
  description = "Enable UEFI Secure Boot (only applied when the template uses EFI firmware)"
  type        = bool
  default     = false
}

variable "vm_vtpm" {
  description = "Add a vTPM 2.0 device (requires EFI firmware and a vCenter key provider, e.g. Native Key Provider)"
  type        = bool
  default     = false
}

variable "vm_sizing" {
  description = "CPU and memory (MB) per role"
  type = object({
    ddc        = object({ cpus = number, memory = number })
    storefront = object({ cpus = number, memory = number })
    sql        = object({ cpus = number, memory = number })
    vda        = object({ cpus = number, memory = number })
  })
  default = {
    ddc        = { cpus = 2, memory = 4096 }
    storefront = { cpus = 2, memory = 4096 }
    sql        = { cpus = 2, memory = 8192 }
    vda        = { cpus = 2, memory = 8192 }
  }
}

variable "vda_count" {
  description = "Number of VDA servers"
  type        = number
  default     = 1
}

variable "domain_user" {
  description = "Domain Admin User"
  type        = string
}

variable "domain_password" {
  description = "Domain Admin Password"
  type        = string
  sensitive   = true
}

variable "domain" {
  description = "Domain to join"
  type        = string
}

variable "domain_ou" {
  description = "(Optional) OU for the computer accounts, e.g. OU=Citrix,DC=mydomain,DC=local"
  type        = string
  default     = null
}

variable "vm_storefront" {
  description = "Prefix for Storefront servers"
  type        = string
}

variable "vm_ddc" {
  description = "Prefix for DDC servers"
  type        = string
}

variable "vm_sql" {
  description = "Name for SQL and license server"
  type        = string
}

variable "vm_vda" {
  description = "Prefix for VDA server"
  type        = string
}
