resource "aws_instance" "my_web_instance" {
    ami = "ami-005fc0f236362e99f"
    instance_type = "t2.xlarge"
    key_name = "A4L"

    subnet_id = aws_subnet.my_public_subnet.id
    vpc_security_group_ids = [aws_security_group.web_sg.id]
    associate_public_ip_address = true

    user_data = <<-EOF
    #!/bin/bash
    # make sure your package lists are updated.
    sudo apt update -y
     
    # select your version of Grafana https://grafana.com/grafana/download
    # Then ensure that the dependencies for Grafana are installed.
    sudo apt-get install -y adduser libfontconfig1 musl

    # Now to download the binary.
    wget https://dl.grafana.com/oss/release/grafana_11.3.0_amd64.deb

    # run the package manager.
    sudo dpkg -i grafana_11.3.0_amd64.deb

    # start the Grafana service
    sudo service grafana-server start

    # set the Grafana service to auto restart after reboot
    sudo systemctl enable grafana-server.service

    # Your Grafana server will be hosted at
    # http://[your Grafana server ip]:3000  Your username/password will now be admin/admin

    EOF

    tags = {
        "Name": "My-grafanaServer"
    }
}