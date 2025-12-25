packer {
  required_plugins {
    proxmox = {
      source  = "github.com/hashicorp/proxmox"
      version = ">= 1.2.0"
    }
  }
}

locals {
  template_name = "${var.template_prefix}-${var.hostname}"
}

source "proxmox-iso" "blueteam_router" {
  # =========================
  # Proxmox connection
  # =========================
  proxmox_url              = var.proxmox_url
  insecure_skip_tls_verify = var.proxmox_insecure_skip_tls_verify

  username = var.proxmox_username
  token    = var.proxmox_token
  node     = var.proxmox_node

  vm_id   = var.vm_id
  vm_name = local.template_name

  template_name        = local.template_name
  template_description = "Alpine BlueTeam Router (FRR + nftables NAT + key-only SSH)"
  tags                 = "alpine;router;blueteam;template"

  # =========================
  # Boot ISO (NO deprecated iso_* fields)
  # =========================
  boot_iso {
    type             = "scsi"
    iso_url          = "https://dl-cdn.alpinelinux.org/alpine/v3.23/releases/x86_64/alpine-virt-3.23.2-x86_64.iso"
    iso_checksum     = "file:https://dl-cdn.alpinelinux.org/alpine/v3.23/releases/x86_64/alpine-virt-3.23.2-x86_64.iso.sha256"
    iso_storage_pool = "hdd-data"


    iso_download_pve = false

  
    unmount = true
  }

  # =========================
  # VM hardware
  # =========================
  cores    = var.cpu_cores
  sockets  = 1
  cpu_type = "host"
  memory   = var.memory_mb

  os   = "l26"
  bios = "seabios"

  # Fix iothread requirement
  scsi_controller = "virtio-scsi-single" # required if io_thread=true :contentReference[oaicite:2]{index=2}
  qemu_agent      = true

  # =========================
  # Disk
  # =========================
  disks {
    type         = "scsi"
    disk_size    = var.disk_size
    storage_pool = var.disk_storage_pool

    # [Suy luận] Nếu pool của bạn là LVM-thin thì format raw hợp lý hơn qcow2.
    format     = "raw"
    cache_mode = "none"

    io_thread = true   # requires virtio-scsi-single :contentReference[oaicite:3]{index=3}
    discard   = true
  }

  # =========================
  # Network adapters (ORDER IS IMPORTANT)
  # =========================
  network_adapters {
    model  = "virtio"
    bridge = var.wan_bridge
  }

  network_adapters {
    model  = "virtio"
    bridge = var.transit_bridge
  }

  network_adapters {
    model  = "virtio"
    bridge = var.dmz_bridge
  }

  network_adapters {
    model  = "virtio"
    bridge = var.blue_bridge
  }

  # =========================
  # Packer HTTP server (serves ./http)
  # =========================
  http_directory = "http"

  # =========================
  # Boot & unattended install
  # =========================
  boot_wait = "10s"

  boot_command = [
    "<enter><wait>",
    "root<enter><wait>",

    # Bring up WAN in live ISO to fetch "ip link set "
    "ip link set ${var.live_wan_iface} up<enter>",
    "udhcpc -i ${var.live_wan_iface}<enter>",
    # "ip link set ${var.live_wan_iface} up<enter>",
    # "ip addr add ${var.wan_ip_cidr} dev ${var.live_wan_iface}<enter>",
    # "ip route add default via ${var.wan_gateway}<enter>",
    "echo nameserver ${var.dns_server} > /etc/resolv.conf<enter>",

    # Fetch answerfile from Packer HTTP server
    "wget -O /tmp/answers http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.answerfile_name}<enter>",

    # Non-interactive Alpine install
    # [Suy luận] Với disk type scsi thường là /dev/sda; nếu máy bạn ra /dev/vda thì đổi lại.
    "ERASE_DISKS=/dev/sda setup-alpine -e -f /tmp/answers && mount /dev/sda3 /mnt && apk add --root /mnt qemu-guest-agent && chroot /mnt rc-update add qemu-guest-agent default && reboot<enter>",
  ]

  # =========================
  # SSH communicator (Packer will SSH after install to run provisioners)
  # =========================
  communicator = "ssh"
  ssh_username = "root"
  # ssh_host     = var.ssh_host
  ssh_port     = 22
  ssh_timeout  = "25m"

  # Use pathexpand to handle "~"
  ssh_private_key_file = pathexpand(var.ssh_private_key_file)
  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"
}

build {
  sources = ["source.proxmox-iso.blueteam_router"]

  provisioner "shell" {
    script = "scripts/provision-blue.sh"
  }
}
