resource "aws_route" "rt_pub_default_ipv6" {
  route_table_id              = aws_route_table.rt_public.id
  destination_ipv6_cidr_block = var.rt_pub_default_ipv6
  gateway_id                  = aws_internet_gateway.a4l_igw.id
}
