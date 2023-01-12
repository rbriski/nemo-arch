packer {
  required_plugins {
    amazon = {
      version = ">= 1.1.1"
      source = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "nemo" {
  profile = "default"
  region = "us-west-2"

  source_ami_filter {
    filters = {
       virtualization-type = "hvm"
       name = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
       root-device-type = "ebs"
    }
    owners = ["099720109477"]
    most_recent = true
  }

  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = 100 
    volume_type = "gp2"
    delete_on_termination = true
  }

  ami_name = "dept-nemo-image-{{timestamp}}"
  ami_description = "AMI with full NVIDIA NeMo NPL install"
  ami_virtualization_type = "hvm"
  ami_regions = ["us-west-2"]
  instance_type = "p3.2xlarge"
  ssh_username  =  "ubuntu"
}

build {
  sources = ["source.amazon-ebs.nemo"]

  provisioner "shell" {
    execute_command = "{{.Vars}} DEBIAN_FRONTEND='noninteractive' sudo -S -E '{{.Path}}'"
    script = "scripts/setup.sh"
  }

  provisioner "shell" {
    execute_command = "{{.Vars}} DEBIAN_FRONTEND='noninteractive' sudo -S -E '{{.Path}}'"
    script = "scripts/nvidia_drivers.sh"
    expect_disconnect = true
  }

  provisioner "shell" {
    pause_before = "60s"
    execute_command = "{{.Vars}} DEBIAN_FRONTEND='noninteractive' sudo -S -E '{{.Path}}'"
    script = "scripts/install_cuda.sh"
  }

  provisioner "shell" {
    script = "scripts/install_nemo.sh"
  }
}