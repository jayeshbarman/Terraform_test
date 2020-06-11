provider "aws" {
  region   = "ap-south-1"
  profile  = "PrincePrashantSaini"
}

#creating security group
resource "aws_security_group" "allow_tls" {
  name         = "allow_tls"
  description  = "allow ssh and httpd"
 
  ingress {
    description = "SSH Port"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPD Port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 
  ingress {
    description = "Localhost"
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
    Name = "allow_tls"
  }
}
#creating key variable 
variable "enter_ur_key_name" {
	type = string
	default = "mykey"
}

#create EC2
resource "aws_instance" "myinstance" {
  ami  = "ami-005956c5f0f757d37"
  instance_type = "t2.micro"
  key_name      = var.enter_ur_key_name
  security_groups = ["${aws_security_group.allow_tls.name}"]

  tags = {
     Name = "PrincePrashant"
  }
}

output  "myavzon" {
	value = aws_instance.myinstance.availability_zone
}

output  "my_sec_public_ip" {
	value = aws_instance.myinstance.public_ip
}

resource "aws_ebs_volume" "esb2" {
  availability_zone = aws_instance.myinstance.availability_zone
  size              = 1

  tags = {
    Name = "myebs1"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdd"
  volume_id   = aws_ebs_volume.esb2.id
  instance_id = aws_instance.myinstance.id
}

output  "myoutebs" {
	value = aws_ebs_volume.esb2.id
}