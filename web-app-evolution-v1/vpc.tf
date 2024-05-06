resource "aws_vpc" "my_custom_vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "My Custom VPC"
    }
}