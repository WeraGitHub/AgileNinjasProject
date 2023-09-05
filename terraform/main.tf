provider "aws" {
  region = "eu-west-2"
}


# Create an AWS instance
resource "aws_instance" "agile_app" {
  ami           = "ami-028eb925545f314d6"
  instance_type = "t2.micro"



  tags = {
    Name = "agile_app"
  }


  user_data = <<-EOF
        #!/bin/bash
        exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
        yum update -y
        yum install -y docker
        service docker start
        docker pull weronikadocker/agile-ninjas-project
        docker run -d -p 80:5000 weronikadocker/agile-ninjas-project
              EOF
}


resource "aws_security_group" "agile_app_sg" {
  name_prefix = "docker-example-"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.agile_app_sg.id
  network_interface_id = aws_instance.agile_app.primary_network_interface_id
}

