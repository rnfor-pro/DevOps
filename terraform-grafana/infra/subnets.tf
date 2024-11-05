resource "aws_subnet" "my_public_subnet" {
    vpc_id = aws_vpc.my_custom_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "My Custom Private Public Subnet"
    }
}

resource "aws_subnet" "my_private_subnet" {
    vpc_id = aws_vpc.my_custom_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "My Custom Private Subnet"
    }
}