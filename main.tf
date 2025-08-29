resource "aws_vpc" "my_vpc" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Name = "my_vpc"
  }
}

resource "aws_subnet" "my_subnet-1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "my_subnet-1"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "public_rt" {

        vpc_id = "${aws_vpc.my_vpc.id}"

        route {

                cidr_block = "0.0.0.0/0"
                gateway_id = "${aws_internet_gateway.igw.id}"
        }

}

##route table association

resource "aws_route_table_association" "a" {

                route_table_id = "${aws_route_table.public_rt.id}"
                subnet_id = "${aws_subnet.my_subnet-1.id}"
}

resource "aws_security_group" "my_sg" {
  name        = "my-security-group"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id = aws_vpc.my_vpc.id

  # Inbound Rule: SSH
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound Rule: HTTP
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my-security-group"
  }
}



resource "aws_instance" "test" {

        ami = "ami-0b016c703b95ecbe4"
        instance_type = "t2.micro"
        subnet_id = "${aws_subnet.my_subnet-1.id}"
        key_name = "MyLinuxKey"
        
        vpc_security_group_ids = [aws_security_group.my_sg.id]

        user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y java-17-amazon-corretto.x86_64

              # Create directory
              mkdir -p /mnt/server
              cd /mnt/server

              # Download Tomcat (example: Tomcat 9)
              wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.44/bin/apache-tomcat-10.1.44.zip
              unzip apache-tomcat-10.1.44.zip
              rm -rf apache-tomcat-10.1.44.zip
              chmod -R 777 apache-tomcat-10.1.44

              # Deploy custom index.html
              echo "<html><h1>Hello from Terraform Tomcat!</h1></html>" > /mnt/server/apache-tomcat-10.1.44/webapps/ROOT/index.html

              chmod -R 777 /mnt/server/apache-tomcat-10.1.44/webapps/ROOT/index.html


              # Start Tomcat
              sh /mnt/server/apache-tomcat-10.1.44/bin/startup.sh
              EOF

        tags = {
                Name = "test"
        }


}

# Attach Elastic IP
resource "aws_eip" "my_eip" {
  instance = aws_instance.test.id

  tags = {
    Name = "my_eip"
  }
}
