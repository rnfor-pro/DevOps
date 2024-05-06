resource "aws_route_table" "my_public_rt" {
    vpc_id = aws_vpc.my_custom_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_IGW.id
    }

    route {
        ipv6_cidr_block = "::/0"
        gateway_id = aws_internet_gateway.my_IGW.id
    }
    tags = {
        Name = "My Custom Public Route Table"
    }
}

# Route table association

resource "aws_route_table_association" "my_public_rt_a" {
    subnet_id = aws_subnet.my_public_subnet.id
    route_table_id = aws_route_table.my_public_rt.id
}