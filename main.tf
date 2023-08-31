// resource <type> <name> 

//Setting Up VPC : A virtual private cloud is a private cloud hosted within a public cloud.
resource "aws_vpc" "mtc_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "dev"
  }
}

//Setting Up Subnet in the VPC : Division in the VPC Networks
resource "aws_subnet" "mtc_public_subnet" {
  vpc_id                  = aws_vpc.mtc_vpc.id
  cidr_block              = "10.123.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "dev-public"
  }
}

//Setting Up Gateway for the VPC : Acts as an Entry point to the Network
resource "aws_internet_gateway" "mtc_inter_gateway" {
  vpc_id = aws_vpc.mtc_vpc.id

  tags = {
    Name = "dev-gateway"
  }
}

//Setting Up Routing Table : To store the Routes associated in the VPC
resource "aws_route_table" "mtc_public_rt" {
  vpc_id = aws_vpc.mtc_vpc.id

  tags = {
    Name = "dev-public-rt"
  }
}

//Setting up a Route in the Above Routing Table
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.mtc_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mtc_inter_gateway.id
}


//Attaching the Route Table to the VPC Created
resource "aws_route_table_association" "mtc_public_rt_association" {
  subnet_id      = aws_subnet.mtc_public_subnet.id
  route_table_id = aws_route_table.mtc_public_rt.id
}

//Setting Up Security Groups
resource "aws_security_group" "mtc_sg" {
  name        = "dev-sg"
  description = "dev security group"
  vpc_id      = aws_vpc.mtc_vpc.id

  //Setting up Inbound Rules for the security group
  ingress {
    from_port   = 0
    to_port     = 0
    //Implies that all types of traffic are allowed from any source IP
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #allow all traffic from anywhere
  }

  //Setting up Outbound Rules for the security group
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//Setting up Key-Pair to securely SSH access the instances lauched in the Subnet
resource "aws_key_pair" "mtc_key_pair" {
  key_name   = "mtckey"
  public_key = file("~/.ssh/mtckey.pub")
}

//Lauching the EC2 Instance 
resource "aws_instance" "dev_node" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server_ami.id  #Amazon Machine Image
  key_name               = aws_key_pair.mtc_key_pair.id
  vpc_security_group_ids = [aws_security_group.mtc_sg.id]
  subnet_id              = aws_subnet.mtc_public_subnet.id
  user_data              = file("userdata.tpl") #Commands to be executed after the instance is successfully running
  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "dev-node"
  }

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname      = self.public_ip
      user          = "ubuntu",
      identity_file = "~/.ssh/mtckey"
    })

    interpreter = ["Powershell", "-Command"]
  }
}
