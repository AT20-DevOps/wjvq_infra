terraform {
    required_providers {
        virtualbox = {
            source = "terra-farm/virtualbox"
            version = "0.2.2-alpha.1"
            }
    }
}

resource "virtualbox_vm" "node" {
    count = 1
    name = format("node-%02d", count.index + 1)
    image = "https://app.vagrantup.com/ubuntu/boxes/bionic64/versions/20180903.0.0/providers/virtualbox.box"
    cpus = 2
    memory = "2056 mib"
    user_data = ""
    network_adapter {
        type = "bridged"
        host_interface = "Realtek PCIe GbE Family Controller"
    }

  connection {
    type = "ssh"
    host = element(virtualbox_vm.node.*.network_adapter.0.ipv4_address,1)
    user = "vagrant"
    private_key = file("vagrant")
  }
  
  provisioner "file" {
    source = "../scripts/install_docker.sh"
    destination = "/tmp/install_docker.sh"
  }

  //provision
  provisioner "remote-exec" {
    inline = [ 
      "chmod +x /tmp/install_docker.sh",
      "/tmp/install_docker.sh" 
      ]
    
  }
}

output "IPAddr" {
  value = element(virtualbox_vm.node.*.network_adapter.0.ipv4_address, 1)
}