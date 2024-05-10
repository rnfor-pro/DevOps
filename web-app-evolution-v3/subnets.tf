resource "aws_subnet" "sn_pub_a" {
  vpc_id                  = aws_vpc.a4l_vpc.id
  cidr_block              = var.snpubA
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  # depends_on = [aws_instance.example]

  lifecycle {
    prevent_destroy = false
  }

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
  cidr_block              = var.snpubB
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  # depends_on = [aws_instance.example]

  lifecycle {
    prevent_destroy = false
  }

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
  cidr_block              = var.snpubC
  availability_zone       = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true

  # depends_on = [aws_instance.example]

  lifecycle {
    prevent_destroy = false
  }

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
  cidr_block        = var.snappA
  availability_zone = data.aws_availability_zones.available.names[0]
    
  # depends_on = [aws_instance.example]

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = "sn-app-A"
  }
}

resource "aws_subnet" "sn_app_b" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = var.snappB
  availability_zone = data.aws_availability_zones.available.names[1]

  # depends_on = [aws_instance.example]

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = "sn-app-B"
  }
}

resource "aws_subnet" "sn_app_c" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = var.snappC
  availability_zone = data.aws_availability_zones.available.names[2]

  # depends_on = [aws_instance.example]

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = "sn-app-C"
  }
}

resource "aws_subnet" "sn_db_a" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = var.sndba
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "sn-db-A"
  }
}

resource "aws_subnet" "sn_db_b" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = var.sndbB
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "sn-db-B"
  }
}


resource "aws_subnet" "sn_db_c" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = var.sndbc
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "sn-db-C"
  }
}





