resource "aws_subnet" "sn_pub_a" {
  vpc_id                  = aws_vpc.a4l_vpc.id
  cidr_block              = "10.16.48.0/20"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "sn-pub-A"
  }
}

# route_table_association_public_a
resource "aws_route_table_association" "rta_pub_a" {
  subnet_id      = aws_subnet.sn_pub_a.id
  route_table_id = aws_route_table.rt_public.id
}


# subnet_public_b
resource "aws_subnet" "sn_pub_b" {
  vpc_id                  = aws_vpc.a4l_vpc.id
  cidr_block              = "10.16.112.0/20"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "sn-pub-B"
  }
}

# route_table_association_public_b

resource "aws_route_table_association" "rta_pub_b" {
  subnet_id      = aws_subnet.sn_pub_b.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_subnet" "sn_pub_c" {
  vpc_id                  = aws_vpc.a4l_vpc.id
  cidr_block              = "10.16.176.0/20"
  availability_zone       = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true

  tags = {
    Name = "sn-pub-C"
  }
}

# route_table_association_public_c
resource "aws_route_table_association" "rta_pub_c" {
  subnet_id      = aws_subnet.sn_pub_c.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_subnet" "sn_app_a" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = "10.16.32.0/20"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "sn-app-A"
  }
}

resource "aws_subnet" "sn_app_b" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = "10.16.96.0/20"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "sn-app-B"
  }
}

resource "aws_subnet" "sn_app_c" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = "10.16.160.0/20"
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "sn-app-C"
  }
}

resource "aws_subnet" "sn_db_a" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = "10.16.16.0/20"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "sn-db-A"
  }
}

resource "aws_subnet" "sn_db_b" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = "10.16.80.0/20"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "sn-db-B"
  }
}


resource "aws_subnet" "sn_db_c" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = "10.16.144.0/20"
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "sn-db-C"
  }
}





