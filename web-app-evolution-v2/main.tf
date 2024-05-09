terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.48.0"
    }
  }
}


resource "aws_vpc" "vpc" {
  cidr_block                       = var.vpc_cidr_block
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "A4LVPC"
  }
}


#Internet Gateway

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.vpc.id

  tags = {

    Name = "A4L-IGW"

  }

}

# igw_attachment
# resource "aws_internet_gateway_attachment" "igw_attachment" {
#   vpc_id = aws_vpc.vpc.id
#   internet_gateway_id = aws_internet_gateway.igw.id
# }


#Public Subnet 1

resource "aws_subnet" "pubsub1" {

  cidr_block = var.snpubA

  # public subnet 1 cidr block iteration found in the terraform.tfvars file

  vpc_id = aws_vpc.vpc.id

  map_public_ip_on_launch = true

  availability_zone = data.aws_availability_zones.available.names[0]

  #0 indicates the first AZ

  tags = {

    Name = "sn-pub-A"

  }

}

#Public Subnet 2

resource "aws_subnet" "pubsub2" {

  cidr_block = var.snpubB

  # public subnet 2 cidr block iteration found in the terraform.tfvars file

  vpc_id = aws_vpc.vpc.id

  map_public_ip_on_launch = true

  availability_zone = data.aws_availability_zones.available.names[1]

  #1 indicates the second AZ

  tags = {

    Name = "sn-pub-B"

  }

}


#Public Subnet 3

resource "aws_subnet" "pubsub3" {

  cidr_block = var.snpubC

  # public subnet 3 cidr block iteration found in the terraform.tfvars file

  vpc_id = aws_vpc.vpc.id

  map_public_ip_on_launch = true

  availability_zone = data.aws_availability_zones.available.names[2]

  #2 indicates the 3rd AZ

  tags = {

    Name = "sn-pub-C"

  }

}



#Public Route Table

resource "aws_route_table" "routetablepublic" {

  vpc_id = aws_vpc.vpc.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.igw.id

  }

  tags = {

    Name = "A4L-vpc-rt-pub"

  }

}


#Associate Public Route Table to Public Subnets

resource "aws_route_table_association" "pubrtas1" {

  subnet_id = aws_subnet.pubsub1.id

  route_table_id = aws_route_table.routetablepublic.id

}



resource "aws_route_table_association" "pubrtas2" {

  subnet_id = aws_subnet.pubsub2.id

  route_table_id = aws_route_table.routetablepublic.id

}


resource "aws_route_table_association" "pubrtas3" {

  subnet_id = aws_subnet.pubsub3.id

  route_table_id = aws_route_table.routetablepublic.id

}







#Private Subnet 1

resource "aws_subnet" "prisub1" {

  cidr_block = var.snappA

  # private subnet 1 cidr block iteration found in the terraform.tfvars file

  vpc_id = aws_vpc.vpc.id

  map_public_ip_on_launch = false

  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {

    Name = "sn-app-A"

  }

}



#Private Subnet 2

resource "aws_subnet" "prisub2" {

  cidr_block = var.snappB

  # private subnet 2 cidr block iteration found in the terraform.tfvars file

  vpc_id = aws_vpc.vpc.id

  map_public_ip_on_launch = false

  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {

    Name = "sn-app-B"

  }

}


#Private Subnet 3

resource "aws_subnet" "prisub3" {

  cidr_block = var.snappC

  # private subnet 3 cidr block iteration found in the terraform.tfvars file

  vpc_id = aws_vpc.vpc.id

  map_public_ip_on_launch = false

  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {

    Name = "sn-app-C"

  }

}

resource "aws_subnet" "sndba" { 
  vpc_id                          =  aws_vpc.vpc.id
  cidr_block                      = var.sndba
  availability_zone               = data.aws_availability_zones.available.names[0]
  assign_ipv6_address_on_creation = true
  # ipv6_cidr_block                 = "${aws_vpc.vpc.ipv6_cidr_block}01::/64"
  ipv6_cidr_block = cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, 1)

  tags = {
    Name = "sn-db-A"
  }
}


#Private Subnet 5
resource "aws_subnet" "prisub5" {

  cidr_block = var.sndbB

  # private subnet 5 cidr block iteration found in the terraform.tfvars file
  vpc_id = aws_vpc.vpc.id

  map_public_ip_on_launch = false

  availability_zone = data.aws_availability_zones.available.names[4]

  tags = {

    Name = "sn-db-B"

  }

}

#Private Subnet 6
resource "aws_subnet" "prisub6" {

  cidr_block = var.sndbc

  # private subnet 6 cidr block iteration found in the terraform.tfvars file
  vpc_id = aws_vpc.vpc.id

  map_public_ip_on_launch = false

  availability_zone = data.aws_availability_zones.available.names[5]

  tags = {

    Name = "sn-db-C"

  }

}





#Private Route Table

# resource "aws_route_table" "routetableprivate" {

#   vpc_id = aws_vpc.vpc.id

#   route {

#     cidr_block = "0.0.0.0/0"

#     gateway_id = aws_nat_gateway.ngw.id

#   }

#   tags = {

#     Name = "rt-prirt-arun"

#   }

# }



#Associate Private Route Table to Private Subnets

# resource "aws_route_table_association" "prirtas1" {

#   subnet_id = aws_subnet.prisub1.id

#   route_table_id = aws_route_table.routetableprivate.id

# }



# resource "aws_route_table_association" "prirtas2" {

#   subnet_id = aws_subnet.prisub2.id

#   route_table_id = aws_route_table.routetableprivate.id

# }



# resource "aws_route_table_association" "prirtas3" {

#   subnet_id = aws_subnet.prisub3.id

#   route_table_id = aws_route_table.routetableprivate.id

# }

# resource "aws_route_table_association" "prirtas4" {

#   subnet_id = aws_subnet.prisub4.id

#   route_table_id = aws_route_table.routetableprivate.id

# }

# resource "aws_route_table_association" "prirtas5" {

#   subnet_id = aws_subnet.prisub5.id

#   route_table_id = aws_route_table.routetableprivate.id

# }

# resource "aws_route_table_association" "prirtas6" {

#   subnet_id = aws_subnet.prisub6.id

#   route_table_id = aws_route_table.routetableprivate.id

# }










