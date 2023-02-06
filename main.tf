provider "aws" {
  region     = ""
  access_key = ""
  secret_key = ""
}

// Create VPC


resource "aws_vpc" "kwx" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "kwx"
  }
}

// Create subnets


resource "aws_subnet" "public_subnet1" {
  vpc_id            = aws_vpc.kwx.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "public_subnet1"
  }
}


resource "aws_subnet" "public_subnet2" {
  vpc_id            = aws_vpc.kwx.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "public_subnet2"
  }
}




resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.kwx.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "private_subnet1"
  }
}


// Create internet gateway

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.kwx.id

  tags = {
    Name = "IGW"
  }
}




//Create Route table

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.kwx.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }



  tags = {
    Name = "Public_rt"
  }
}



resource "aws_route_table_association" "public_1_rt_a" {
  subnet_id      = aws_subnet.public_subnet1.id 
  route_table_id = aws_route_table.public_rt.id
}




resource "aws_route_table_association" "public_1_rt_b" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_rt.id
}



// Creating elastic IP and attaching to the ec2 instance

resource "aws_eip" "ec2-eip" {
  instance = aws_instance.Bastion.id
  vpc      = true


tags = {
    Name = "elastic_IP"
  }


}




//Create sec group

resource "aws_security_group" "web_sg" {
  name   = "HTTP and SSH"
  vpc_id = aws_vpc.kwx.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}


// create keypair

resource "tls_private_key" "keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "kiranns"       # Create a "myKey" to AWS!!
  public_key = tls_private_key.keypair.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.kp.key_name}.pem"
  content = tls_private_key.keypair.private_key_pem
}






//Create instaces

resource "aws_instance" "Bastion" {
  ami           = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
  key_name      = "kiranns"

  subnet_id                   = aws_subnet.public_subnet1.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true







  tags = {
    "Name" : "Bastion"
  }



   connection {
       type        = "ssh"
       user        = "ubuntu"
       private_key = tls_private_key.keypair.private_key_pem
       host        = self.public_ip
  
     }


  provisioner "file" {
    source      = "/home/kiran/Desktop/kiran1/Kiran N S/terraform/kiran/userdata.sh"
    destination = "/tmp/userdata.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/userdata.sh",
      "sudo sh /tmp/userdata.sh",
    ]
  }






}



