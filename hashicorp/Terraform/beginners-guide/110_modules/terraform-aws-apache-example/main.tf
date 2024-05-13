
data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_subnets" "example" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }  
}

data "aws_subnet" "example" {
  for_each = toset(data.aws_subnets.example.ids)
  id       = each.value
}



resource "aws_security_group" "sg_app_server" {
  name        = "sg_app_server"
  description = "SG for App Server"
  vpc_id      = data.aws_vpc.main.id

  ingress = [
    {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = "${values(data.aws_subnet.example).*.cidr_block}"  #["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  },
  {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = "${values(data.aws_subnet.example).*.cidr_block}" # [var.my_ip_with_cidr]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  }
  ]
  egress = [
  {
    description = "out bound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = "${values(data.aws_subnet.example).*.cidr_block}"  # ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids = []
    security_groups = []
    self = false
  }
  ]
}


resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.public_key
}

data "template_file" "userdata" {
  template = file("${abspath(path.module)}/userdata.yaml")
  
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "app_server" {
  ami           = "${data.aws_ami.amazon-linux-2.id}"
  # for_each = tolist(data.aws_subnet.subnet_id.id)[0]
  # subnet_id = data.aws_subnet.subnet_id[each.key]
  for_each      = toset(data.aws_subnets.example.ids)
  subnet_id     = each.value
  instance_type = var.instance_type
  key_name = "${aws_key_pair.deployer.key_name}"
  vpc_security_group_ids = [aws_security_group.sg_app_server.id]
  user_data = data.template_file.userdata.rendered

  connection {
    type     = "ssh"
    user     = "ec2-user"
    host     = "${self.public_ip}"
    private_key = "${file("/Users/macbookpro/.ssh/terraform")}"
  }

  tags = {
    Name = var.server_name
  }
}



