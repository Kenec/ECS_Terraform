# # Availablity Zone
data "aws_availability_zones" "available" {
  state = "available"
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"
  instance_tenancy = "${var.tenancy}"

  tags = {
    Name = "main"
  }
}

# # Create Private Subnet
resource "aws_subnet" "private" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.private_subnet}"

  tags = {
    Name = "private-subnet"
  }
}

# Create Public Subnet
resource "aws_subnet" "public" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.public_subnet}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "public2" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.public_subnet2}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"

  
  tags = {
    Name = "public-subnet-2"
  }
}

# Internet Gateway for the public subnet
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "Internet-GW"
  }
}

# Create Elastic IP
resource "aws_eip" "gw" {
  vpc        = true
  depends_on = ["aws_internet_gateway.gw"]
}

# Create NAT Gateway
resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.gw.id}"
  subnet_id     = "${aws_subnet.public.id}"
  depends_on = ["aws_internet_gateway.gw"]
}

# Create Route Table for public subnet
resource "aws_route_table" "public-RT" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "public-RT"
  }
}

# Create Route Table for private subnet
resource "aws_route_table" "private-RT" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.gw.id}"
  }

  tags = {
    Name = "private-RT"
  }
}

# Route the public subnet traffic through the IGW
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_route_table.public-RT.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

# Associate Private-RT route tables to the private subnets
resource "aws_route_table_association" "private" {
  subnet_id      = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.private-RT.id}"
}

# Associate Public-RT route tables to the public subnets
resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public-RT.id}"
}

# Associate Public-RT route tables to the public subnets
resource "aws_route_table_association" "public2" {
  subnet_id      = "${aws_subnet.public2.id}"
  route_table_id = "${aws_route_table.public-RT.id}"
}
