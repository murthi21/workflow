provider "aws" {
  region = "us-west-2"
}

# --------------------
# VPC + Networking
# --------------------
resource "aws_vpc" "k8s_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "k8s-vpc"
  }
}

resource "aws_subnet" "k8s_subnet" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
  tags = {
    Name = "k8s-subnet"
  }
}

resource "aws_internet_gateway" "k8s_igw" {
  vpc_id = aws_vpc.k8s_vpc.id
  tags = {
    Name = "k8s-igw"
  }
}

resource "aws_route_table" "k8s_rt" {
  vpc_id = aws_vpc.k8s_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_igw.id
  }
  tags = {
    Name = "k8s-rt"
  }
}

resource "aws_route_table_association" "k8s_rta" {
  subnet_id      = aws_subnet.k8s_subnet.id
  route_table_id = aws_route_table.k8s_rt.id
}

# --------------------
# Security Groups
# --------------------
resource "aws_security_group" "sg_control" {
  name        = "k8s-control-sg"
  description = "Kubernetes control plane SG"
  vpc_id      = aws_vpc.k8s_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "K8s API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_workers" {
  name        = "k8s-workers-sg"
  description = "Kubernetes workers SG"
  vpc_id      = aws_vpc.k8s_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Rules for Cluster <-> Workers Communication
resource "aws_security_group_rule" "workers_to_control" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_workers.id
  security_group_id        = aws_security_group.sg_control.id
}

resource "aws_security_group_rule" "control_to_workers" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_control.id
  security_group_id        = aws_security_group.sg_workers.id
}

# --------------------
# EC2 Instances
# --------------------
resource "aws_instance" "k8s_cluster" {
  ami                         = "ami-0c65adc9a5c1b5d7c" # Amazon Linux 2 (free-tier, us-west-2)
  instance_type               = "t2.micro"
  key_name                    = "murthi"
  subnet_id                   = aws_subnet.k8s_subnet.id
  vpc_security_group_ids      = [aws_security_group.sg_control.id]

  tags = {
    Name = "k8s-cluster"
  }
}

resource "aws_instance" "k8s_worker1" {
  ami                         = "ami-0c65adc9a5c1b5d7c"
  instance_type               = "t2.micro"
  key_name                    = "murthi"
  subnet_id                   = aws_subnet.k8s_subnet.id
  vpc_security_group_ids      = [aws_security_group.sg_workers.id]

  tags = {
    Name = "k8s-worker1"
  }
}

resource "aws_instance" "k8s_worker2" {
  ami                         = "ami-0c65adc9a5c1b5d7c"
  instance_type               = "t2.micro"
  key_name                    = "murthi"
  subnet_id                   = aws_subnet.k8s_subnet.id
  vpc_security_group_ids      = [aws_security_group.sg_workers.id]

  tags = {
    Name = "k8s-worker2"
  }
}

