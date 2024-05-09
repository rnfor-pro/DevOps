resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.a4l_vpc.id

  tags = {
    Name = "A4L-vpc-rt-pub"
  }
}
