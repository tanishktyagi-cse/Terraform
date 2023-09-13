provider "aws" {
    region  = var.aws-region
    profile = var.aws-profile
}

resource "aws_vpc" "new_vpc" {
    tags = {
        Name = "${var.environment-name}-vpc-${var.project-name}"
    }
    cidr_block = "10.0.0.0/16"
}

data "aws_availability_zones" "available" {
    state = "available"
}

resource "aws_subnet" "private_subnets" {
    depends_on = [
        aws_vpc.new_vpc
    ]
    count = length(data.aws_availability_zones.available.names)
    vpc_id     = aws_vpc.new_vpc.id
    cidr_block = "10.0.1${count.index + 1}.0/24"
    availability_zone = data.aws_availability_zones.available.names[count.index]

    tags = {
        Name = "${var.environment-name}-private-subnet${count.index + 1}-${var.project-name}"
    }
}

resource "aws_subnet" "public-subnets" {
    depends_on = [
        aws_vpc.new_vpc
    ]
    count = length(data.aws_availability_zones.available.names)
    vpc_id     = aws_vpc.new_vpc.id
    cidr_block = "10.0.${count.index + 1}.0/24"
    availability_zone = data.aws_availability_zones.available.names[count.index]

    tags = {
        Name = "${var.environment-name}-public-subnet${count.index + 1}-${var.project-name}"
    }
}

resource "aws_internet_gateway" "gw" {
    depends_on = [
        aws_vpc.new_vpc
    ]
    vpc_id = aws_vpc.new_vpc.id

    tags = {
        Name = "${var.environment-name}-igw-${var.project-name}"
    }
}


resource "aws_eip" "nat_eip" {
    count = length(data.aws_availability_zones.available.names)
    tags = {
        Name = "${var.environment-name}-nat-${count.index + 1}-eip-${var.project-name}"
    }
}


resource "aws_nat_gateway" "nat_gw" {
    depends_on = [
        aws_eip.nat_eip,
        aws_subnet.public-subnets
    ]
    count = length(data.aws_availability_zones.available.names)
    allocation_id = aws_eip.nat_eip[count.index].id
    subnet_id     = aws_subnet.public-subnets[count.index].id

    tags = {
      Name = "${var.environment-name}-nat-${count.index + 1}-${var.project-name}"
  }
}

resource "aws_route_table" "public_route" {
    depends_on = [
        aws_internet_gateway.gw
    ]
    vpc_id = aws_vpc.new_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }

    tags = {
        Name = "${var.environment-name}-public-rt-${var.project-name}"
    }
}

resource "aws_route_table_association" "public_subnet_association" {
    depends_on = [
        aws_route_table.public_route
    ]
    count = length(data.aws_availability_zones.available.names)
    subnet_id      = aws_subnet.public-subnets[count.index].id
    route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table" "private_route" {
    depends_on = [
        aws_nat_gateway.nat_gw
    ]
    count = length(data.aws_availability_zones.available.names)
    vpc_id = aws_vpc.new_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nat_gw[count.index].id
    }

    tags = {
        Name = "${var.environment-name}-private-rt-${count.index + 1}-${var.project-name}"
    }
}

resource "aws_route_table_association" "private_subnet_association" {
    depends_on = [
        aws_route_table.private_route
    ]
    count = length(data.aws_availability_zones.available.names)
    subnet_id      = aws_subnet.private_subnets[count.index].id
    route_table_id = aws_route_table.private_route[count.index].id
}
