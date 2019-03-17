# Create VPC for LAMP
resource "aws_vpc" "main" {
  cidr_block       = "172.40.0.0/16"
  instance_tenancy = "dedicated"

  tags {
    Name = "lamp-vpc"
  }
}
# Create private subnet
resource "aws_subnet" "main" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.private_subnet_lamp}"

  tags {
    Name = "private-sub-lamp"
  }
}

#Reference public subnet
data "aws_subnet" "public-sub-lamp"{
  id ="${var.public_subnet_lamp_id}"
}

# Creating security group
resource "aws_security_group" "allow_internal_" {
  name        = "allow_internal"
  description = "Allow all internal inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${aws_vpc.main.cidr_block}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

#Create internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "lamp_igw"
  }
}


#Create routetable
resource "aws_route_table" "public-rt" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "public-rt"
  }
}

#Associate public rt with public subnet
resource "aws_route_table_association" "public-rt-association"{
  subnet_id = "${data.aws_subnet.public-sub-lamp.id}"
  route_table_id= "${aws_route_table.public-rt.id}"
}

