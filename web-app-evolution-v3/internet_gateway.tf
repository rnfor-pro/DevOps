resource "aws_internet_gateway" "a4l_igw" {
  vpc_id = aws_vpc.a4l_vpc.id

  # depends_on = [aws_instance.example]

  lifecycle {
    prevent_destroy = false
    create_before_destroy = false
  }

  tags = {
    Name = "A4L-IGW"
  }
}

# igw_attachment
# resource "aws_internet_gateway_attachment" "igw_attachment" {
#   vpc_id             = aws_vpc.a4l_vpc.id
#   internet_gateway_id = aws_internet_gateway.a4l_igw.id
# }



# resource "aws_vpc_gateway_attachment" "igw_attachment" {
#   vpc_id              = aws_vpc.a4l_vpc.id
#   internet_gateway_id = aws_internet_gateway.a4l_igw.id
# }
