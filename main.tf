resource "aws_vpc" "vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1a"

  tags = {
    Name = "dev-public"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "dev-public-rt"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "security_group" {
  name   = "dev-sg"
  vpc_id = aws_vpc.vpc.id

  ingress { #incoming traffic
    description = "SSH"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          #every protocol
    cidr_blocks = ["0.0.0.0/0"] #should be replaced with your IP: ["X.X.X.X/32"]
  }

  egress { #outgoing traffic
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          #every protocol
    cidr_blocks = ["0.0.0.0/0"] #everywhere
  }
}

resource "aws_key_pair" "key_pair" {
  key_name   = "dev-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "instance" {
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.key_pair.key_name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.security_group.id]
  user_data              = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "dev-instance"
  }
}