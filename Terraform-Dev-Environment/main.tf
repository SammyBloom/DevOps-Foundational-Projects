resource "aws_vpc" "dev_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "dev_public_subnet" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "dev-public-subnet"
  }
}

resource "aws_internet_gateway" "dev_internet_gateway" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "dev-internet-gateway"
  }
}

resource "aws_route_table" "dev_public_route_table" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "dev-public-route-table"
  }
}

resource "aws_route" "dev_public_route" {
  route_table_id         = aws_route_table.dev_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dev_internet_gateway.id
}

resource "aws_route_table_association" "dev_public_route_table_association" {
  subnet_id      = aws_subnet.dev_public_subnet.id
  route_table_id = aws_route_table.dev_public_route_table.id
}

resource "aws_security_group" "dev_security_group" {
  name        = "dev_security_group"
  description = "Security group for dev environment"
  vpc_id      = aws_vpc.dev_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "dev_key" {
  key_name   = "devkey"
  public_key = file("~/.ssh/devkey.pub")
}

resource "aws_instance" "dev_instance" {
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.dev_public_subnet.id
  ami                    = data.aws_ami.dev_server_ami.id
  key_name               = aws_key_pair.dev_key.key_name
  vpc_security_group_ids = [aws_security_group.dev_security_group.id]
  user_data = file("userscript.tpl")

  tags = {
    Name = "dev-instance"
  }

  root_block_device {
    volume_size           = 10
    volume_type           = "gp2"
    delete_on_termination = true
  }

  provisioner "local-exec" {
    command = templatefile("linux-ssh-config.tpl", {
      host = self.public_ip,
      user = "ubuntu",
      identityfile = "~/.ssh/devkey"
    })
    interpreter = [ "bash", "-c" ]
  }
}