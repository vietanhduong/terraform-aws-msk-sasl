data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "proxy" {
  vpc_id = data.aws_vpc.selected.id

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = var.proxy_whitelist_ip
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_network_interface" "proxy" {
  subnet_id       = local.public_subnets[0]
  security_groups = [aws_security_group.proxy.id]
}

resource "tls_private_key" "proxy" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "proxy" {
  count      = var.enable_proxy ? 1 : 0
  key_name   = "${var.cluster_name}_proxy_key"
  public_key = tls_private_key.proxy.public_key_openssh
}

resource "aws_instance" "proxy" {
  count         = var.enable_proxy ? 1 : 0
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  network_interface {
    network_interface_id = aws_network_interface.proxy.id
    device_index         = 0
  }

  root_block_device {
    volume_size = 50
  }

  key_name = aws_key_pair.proxy.0.id

  tags = {
    Name = "${var.cluster_name}'s proxy"
  }

  depends_on = [aws_msk_cluster.this]
}

resource "aws_eip" "proxy" {
  count    = var.enable_proxy ? 1 : 0
  instance = aws_instance.proxy.0.id
  vpc      = true
}

resource "null_resource" "installer" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = aws_eip.proxy.0.public_ip
    private_key = tls_private_key.proxy.private_key_pem
  }

  provisioner "file" {
    source      = "setup.sh"
    destination = "/tmp/setup.sh"
  }

  provisioner "file" {
    source      = "msk-proxy.service"
    destination = "/tmp/msk-proxy.service.tpl"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "/tmp/setup.sh ${aws_msk_cluster.this.bootstrap_brokers_sasl_scram} ${aws_eip.proxy.0.public_ip}",
    ]
  }

  triggers = {
    always_run = "${timestamp()}"
  }

  depends_on = [aws_eip.proxy, aws_msk_cluster.this]
}
