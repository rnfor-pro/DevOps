resource "aws_instance" "my_web_instance" {
    ami = "ami-07caf09b362be10b8"
    instance_type = "t2.micro"
    key_name = "A4L"

    subnet_id = aws_subnet.my_public_subnet.id
    vpc_security_group_ids = [aws_security_group.web_sg.id]
    associate_public_ip_address = true

    # user_data = <<-EOF
    # #!/bin/bash
    # yum update -y
    # yum install httpd -y
    # echo "<html><h1>webpage 1(whatever you want, give the page name here)</h1></html>" > /var/www/html/index.html
    # service httpd start
    # chkconfig httpd on
    # EOF

    tags = {
        "Name": "My Web App Server"
    }
}