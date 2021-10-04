provider "aws" {
  region   = "ap-south-1"
  profile  = "jayesh"
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

  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/jayes/Downloads/mykey.pem")
    host     = aws_instance.myinstance.public_ip 
 }
 provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd  php git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]
  }

  tags = {
     Name = "jayesh"
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
  volume_id   = "${aws_ebs_volume.esb2.id}"
  instance_id = "${aws_instance.myinstance.id}"
  force_detach = true
}

output  "myoutebs" {
	value = aws_ebs_volume.esb2.id
}

resource "null_resource" "nulllocal2"  {
	provisioner "local-exec" {
	    command = "echo  ${aws_instance.myinstance.public_ip} > publicip.txt"
  	}
}

resource "null_resource" "nullremote3"  {

depends_on = [
    aws_volume_attachment.ebs_att,
  ]


  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/jayes/Downloads/mykey.pem")
    host     = aws_instance.myinstance.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdh",
      "sudo mount  /dev/xvdh  /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/jayeshbaman/workspace.git /var/www/html/"
    ]
  }
}

resource "aws_ebs_snapshot" "my_snapshot" {
  volume_id = "${aws_ebs_volume.esb2.id}"

  tags = {
    Name = "HelloWorld_snap"
  }
}

resource "null_resource" "nulllocal1"  {


depends_on = [
    null_resource.nullremote3,
  ]

	provisioner "local-exec" {
	    command = "chrome  ${aws_instance.myinstance.public_ip}"
  	}
}












