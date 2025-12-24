variable "proxmox_url" {
  type        = string
  description = "Proxmox API URL, e.g. https://pve:8006/api2/json"
}

variable "proxmox_username" {
  type        = string
  description = "Proxmox username incl. realm. For token auth: user@realm!tokenid"
}

variable "proxmox_token" {
  type        = string
  sensitive   = true
  description = "Proxmox API token secret (NOT the token id)."
}

variable "proxmox_node" {
  type        = string
  description = "Proxmox node name to build on."
}

variable "proxmox_insecure_skip_tls_verify" {
  type        = bool
  default     = true
  description = "Skip TLS verify for Proxmox API."
}

variable "vm_id" {
  type        = number
  default     = 0
  description = "Optional fixed VMID. Set 0 to auto-assign."
}

variable "disk_storage_pool" {
  type        = string
  default     = "local-lvm"
  description = "Proxmox storage pool for the VM disk."
}

variable "disk_size" {
  type        = string
  default     = "8G"
  description = "VM disk size, e.g. 8G"
}

variable "cpu_cores" {
  type        = number
  default     = 2
  description = "Number of vCPU cores"
}

variable "memory_mb" {
  type        = number
  default     = 512
  description = "Memory in MB"
}

variable "template_prefix" {
  type        = string
  default     = "tpl"
  description = "Template name prefix"
}

variable "hostname" {
  type        = string
  default     = "blue-router"
  description = "Hostname (also used in template name)"
}

variable "wan_bridge" {
  type        = string
  description = "Proxmox bridge for WAN (net0)"
}

variable "transit_bridge" {
  type        = string
  description = "Proxmox bridge for transit"
}

variable "dmz_bridge" {
  type        = string
  description = "Proxmox bridge for DMZ"
}

variable "blue_bridge" {
  type        = string
  description = "Proxmox bridge for Blue LAN"
}

variable "live_wan_iface" {
  type        = string
  default     = "eth0"
  description = "Interface name in the live ISO environment (usually eth0)."
}

variable "wan_ip_cidr" {
  type        = string
  description = "WAN IP/CIDR for the Blue router (also used during live ISO bootstrap), e.g. 10.10.100.21/24"
}

variable "wan_gateway" {
  type        = string
  description = "WAN gateway, e.g. 10.10.100.1"
}

variable "dns_server" {
  type        = string
  default     = "1.1.1.1"
  description = "DNS server used in live ISO to fetch answerfile"
}

variable "ssh_host" {
  type        = string
  description = "IP that Packer will SSH to after install, e.g. 10.10.100.21"
}

variable "ssh_private_key_file" {
  type        = string
  description = "Private key path that matches ROOTSSHKEY in http/answers (e.g. /root/.ssh/id_ed25519)."
}

variable "answerfile_name" {
  type        = string
  default     = "answers"
  description = "Filename inside http/ used as setup-alpine answerfile."
}
