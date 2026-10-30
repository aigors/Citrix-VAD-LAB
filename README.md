# Citrix Virtual Apps and Desktop vCenter Lab Deploy
Uses Terraform and Ansible to deploy a fully functional CVAD environment. Many of the scripts used are thanks to [Dennis Span](https://dennisspan.com) and his fantastic blog.

## What it does

Deploys the following:
 - 2 DDC Controllers with Director
 - 2 Storefront Servers (Cluster)
 - 1 SQL and License Server
 - 1 Stand alone VDA

### DDC
 - Installs components including director
 - Creates Citrix site
 - Creates 1 Machine Catalog
 - Creates 1 Delivery Group
 - Creates 1 Published Desktop
 - Creates 3 Applications
    - Notepad
    - Calculator
    - Paint
 - Configures director
    - Adds logon domain
    - Sets default page
    - Removes SSL Warning

### Storefront
 - Installs Storefront components
 - Creates Storefront cluster
 - Configures Storefromt
   - Adds Citrix Gateway
   - Sets default page
   - Enables HTTP loopback for SSL offload
   - Adjusts logoff behavior

### SQL and Citrix License
 - Installs SQL and license server
 - Installs SQL management tools
 - Configures SQL for admins and service account
 - Copies Citrix license files

### VDA
 - Installs VDA components
 - Configures for DDCs

## Prerequisites

- Need CVAD ISO contents copied to accessible share via Ansible account (eg \\\mynas\isos\Citrix\Citrix_Virtual_Apps_and_Desktops_7_1906_2)
    - I used CVAD 1906 2 ISO
- Need SQL ISO contents copied to accessible share via Ansible account (eg \\\mynas\isos\Microsoft\SQL\en_sql_server_2017_standard_x64_dvd_11294407)
    - I used SQL 2017 but other versions should work
- DHCP enabled network
- vCenter Server 8.0 (ESXi 8.0 hosts) and rights capable of deploying machines
    - Tested target: vSphere 8.0 U1/U2/U3. vSphere 7 still works with the default settings
- (optional for remote state) [HCP Terraform](https://app.terraform.io/signup/account) account created and API key for remote state.

### Deploy machine
I used [Ubuntu WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10) to deploy from

1. [Ansible installed](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-ansible-on-ubuntu-18-04)
   - Install **pywinrm** `pip install pywinrm` and `pip install pywinrm[credssp]`
2. [Terraform >= 1.5 installed](https://developer.hashicorp.com/terraform/install)
    - Uses the [vmware/vsphere](https://registry.terraform.io/providers/vmware/vsphere/latest) provider `>= 2.10, < 3.0`
3. [Terraform-Inventory](https://github.com/adammck/terraform-inventory/releases) **v0.10 or later** (needed for Terraform >= 0.12 state) installed in path.  This is used for the Ansible inventory
    - I copied to */usr/bin/*
4. (If using remote state)[Configure Access for the Terraform CLI](https://www.terraform.io/docs/cloud/free/index.html#configure-access-for-the-terraform-cli)
5. This REPO cloned down

### vCenter Windows Server Template
    
1. Windows Server 2022 recommended (2019 also works). On vSphere 8 build the template with
    - Virtual hardware version 20 (vSphere 8.0) or 21 (vSphere 8.0 U2+)
    - EFI firmware (the clones automatically inherit the template firmware)
    - Current VMware Tools (required for guest customization / domain join)
    - VMXNET3 NIC and PVSCSI or LSI Logic SAS controller (inherited from the template)
2. WinRM needs to be configured and **CredSSP** enabled
    - Ansible provides a great script to enable quickly https://github.com/ansible/ansible/blob/devel/examples/scripts/ConfigureRemotingForAnsible.ps1
    - Run manually `Enable-WSManCredSSP -Role Server -Force`
3. I use linked clones to quickly deploy.  In order for this to work the template needs to be converted to a VM with a **single snapshot** created.
4. (Optional) vSphere 8 security features, set in **lab.tfvars**
    - `vm_efi_secure_boot = true` enables Secure Boot (EFI templates only)
    - `vm_vtpm = true` adds a vTPM 2.0. Requires a key provider in vCenter (e.g. the built-in Native Key Provider)
    - `vm_hardware_version = 20|21` upgrades the clones' virtual hardware

## Getting Started

### Terraform
1. From the *terraform* directory copy **lab.tfvars.sample** to **lab.tfvars**
2. Adjust variables to reflect vCenter environment
3. Review **variables.tf** and adjust `vm_sizing` / `vda_count` if needed
4. (If using remote cloud state) In **versions.tf** uncomment the *cloud* block and edit the *organization* and *workspaces* fields
```
cloud {
  organization = "TechDrabble"
  workspaces {
    name = "cvad-lab"
  }
}
```
5. run `terraform init` to install needed provider

### Ansible
1. From the *ansible* directory copy **vars.yml.sample** to **vars.yml**
2. Adjust variables to reflect environment
3. If you want to license CVAD environment place generated license file in **ansible\roles\license\files**

## Deploy
If you are comfortable with below process `build.sh` handles the below steps.  

**Note:** If you prefer to run many of the tasks asynchronously switch the `ansible-playbook` lines within `build.sh` which will call a seperate playbook. This is faster but can consume more resources and less informative output.
```
#Sync
#ansible-playbook --inventory-file=/usr/bin/terraform-inventory ./ansible/playbook.yml -e @./ansible/vars.yml
#If you prefer to run most of the tasks async (can increase resources)
ansible-playbook --inventory-file=/usr/bin/terraform-inventory ./ansible/playbook-async.yml -e @./ansible/vars.yml
```

## Terraform
1. From the *terraform* directory run `terraform apply --var-file="lab.tfvars"`
2. Verify the results and type `yes` to start the build

## Ansible
1. From the *root* directory and the terraform deployment is completed run the following
    - `export TF_STATE=./terraform` used for the inventory script
    - Synchronous run (Serial tasks)
        - `ansible-playbook --inventory-file=/usr/bin/terraform-inventory ./ansible/playbook.yml -e @./ansible/vars.yml` to start the playbook
    - Asynchronous run (Parallel tasks)
        - `ansible-playbook --inventory-file=/usr/bin/terraform-inventory ./ansible/playbook-async.yml -e @./ansible/vars.yml` to start the playbook
    - Grab coffee

## Destroy
If you are comfortable with below process `destroy.sh` handles the below steps.  **Please note this does not clean up the computer accounts**

## Terraform
1. From the *terraform* directory run `terraform destroy --var-file="lab.tfvars"`
2. Verify the results and type `yes` to destroy


