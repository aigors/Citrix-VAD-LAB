provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = var.vsphere_allow_unverified_ssl
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.vsphere_rp
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vsphere_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_folder" "folder" {
  path          = var.vsphere_folder
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

locals {
  template = data.vsphere_virtual_machine.template

  # Windows Server 2022/2025 templates on vSphere 8 are normally EFI. The clone
  # must use the same firmware as the template or the guest will not boot.
  firmware                = local.template.firmware
  efi_secure_boot_enabled = local.firmware == "efi" ? var.vm_efi_secure_boot : false
}

resource "vsphere_virtual_machine" "ddc" {
  name             = "${var.vm_ddc}${count.index + 1}"
  count            = 2
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = vsphere_folder.folder.path
  num_cpus         = var.vm_sizing.ddc.cpus
  memory           = var.vm_sizing.ddc.memory
  guest_id         = local.template.guest_id
  hardware_version = var.vm_hardware_version

  firmware                = local.firmware
  efi_secure_boot_enabled = local.efi_secure_boot_enabled
  enable_disk_uuid        = true

  scsi_type = local.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = local.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = local.template.disks[0].size
    eagerly_scrub    = local.template.disks[0].eagerly_scrub
    thin_provisioned = local.template.disks[0].thin_provisioned
  }

  dynamic "vtpm" {
    for_each = var.vm_vtpm ? [1] : []
    content {
      version = "2.0"
    }
  }

  clone {
    template_uuid = local.template.id

    linked_clone = var.vsphere_linkedclones

    customize {
      timeout = var.vsphere_customize_timeout

      windows_options {
        computer_name         = "${var.vm_ddc}${count.index + 1}"
        join_domain           = var.domain
        domain_ou             = var.domain_ou
        domain_admin_user     = var.domain_user
        domain_admin_password = var.domain_password
        time_zone             = var.vsphere_timezone
      }

      network_interface {}
    }
  }
}

resource "vsphere_virtual_machine" "storefront" {
  name             = "${var.vm_storefront}${count.index + 1}"
  count            = 2
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = vsphere_folder.folder.path
  num_cpus         = var.vm_sizing.storefront.cpus
  memory           = var.vm_sizing.storefront.memory
  guest_id         = local.template.guest_id
  hardware_version = var.vm_hardware_version

  firmware                = local.firmware
  efi_secure_boot_enabled = local.efi_secure_boot_enabled
  enable_disk_uuid        = true

  scsi_type = local.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = local.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = local.template.disks[0].size
    eagerly_scrub    = local.template.disks[0].eagerly_scrub
    thin_provisioned = local.template.disks[0].thin_provisioned
  }

  dynamic "vtpm" {
    for_each = var.vm_vtpm ? [1] : []
    content {
      version = "2.0"
    }
  }

  clone {
    template_uuid = local.template.id

    linked_clone = var.vsphere_linkedclones

    customize {
      timeout = var.vsphere_customize_timeout

      windows_options {
        computer_name         = "${var.vm_storefront}${count.index + 1}"
        join_domain           = var.domain
        domain_ou             = var.domain_ou
        domain_admin_user     = var.domain_user
        domain_admin_password = var.domain_password
        time_zone             = var.vsphere_timezone
      }

      network_interface {}
    }
  }
}

resource "vsphere_virtual_machine" "sql" {
  name             = var.vm_sql
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = vsphere_folder.folder.path
  num_cpus         = var.vm_sizing.sql.cpus
  memory           = var.vm_sizing.sql.memory
  guest_id         = local.template.guest_id
  hardware_version = var.vm_hardware_version

  firmware                = local.firmware
  efi_secure_boot_enabled = local.efi_secure_boot_enabled
  enable_disk_uuid        = true

  scsi_type = local.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = local.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = local.template.disks[0].size
    eagerly_scrub    = local.template.disks[0].eagerly_scrub
    thin_provisioned = local.template.disks[0].thin_provisioned
  }

  dynamic "vtpm" {
    for_each = var.vm_vtpm ? [1] : []
    content {
      version = "2.0"
    }
  }

  clone {
    template_uuid = local.template.id

    linked_clone = var.vsphere_linkedclones

    customize {
      timeout = var.vsphere_customize_timeout

      windows_options {
        computer_name         = var.vm_sql
        join_domain           = var.domain
        domain_ou             = var.domain_ou
        domain_admin_user     = var.domain_user
        domain_admin_password = var.domain_password
        time_zone             = var.vsphere_timezone
      }

      network_interface {}
    }
  }
}

resource "vsphere_virtual_machine" "vda" {
  name             = "${var.vm_vda}${count.index + 1}"
  count            = var.vda_count
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = vsphere_folder.folder.path
  num_cpus         = var.vm_sizing.vda.cpus
  memory           = var.vm_sizing.vda.memory
  guest_id         = local.template.guest_id
  hardware_version = var.vm_hardware_version

  firmware                = local.firmware
  efi_secure_boot_enabled = local.efi_secure_boot_enabled
  enable_disk_uuid        = true

  scsi_type = local.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = local.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = local.template.disks[0].size
    eagerly_scrub    = local.template.disks[0].eagerly_scrub
    thin_provisioned = local.template.disks[0].thin_provisioned
  }

  dynamic "vtpm" {
    for_each = var.vm_vtpm ? [1] : []
    content {
      version = "2.0"
    }
  }

  clone {
    template_uuid = local.template.id

    linked_clone = var.vsphere_linkedclones

    customize {
      timeout = var.vsphere_customize_timeout

      windows_options {
        computer_name         = "${var.vm_vda}${count.index + 1}"
        join_domain           = var.domain
        domain_ou             = var.domain_ou
        domain_admin_user     = var.domain_user
        domain_admin_password = var.domain_password
        time_zone             = var.vsphere_timezone
      }

      network_interface {}
    }
  }
}
