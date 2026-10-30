output "ddc_ips" {
  value = vsphere_virtual_machine.ddc[*].default_ip_address
}

output "storefront_ips" {
  value = vsphere_virtual_machine.storefront[*].default_ip_address
}

output "sql_ip" {
  value = vsphere_virtual_machine.sql.default_ip_address
}

output "vda_ips" {
  value = vsphere_virtual_machine.vda[*].default_ip_address
}
