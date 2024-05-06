resource "aws_internet_gateway" "my_IGW" {
    vpc_id = aws_vpc.my_custom_vpc.id

    tags = {
        Name = "My Custom Internet Gateway"
    }
}