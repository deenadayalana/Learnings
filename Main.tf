provider "aws" {
    region = "ap-south-1"
}

resource "aws_vpc" "myvpc"{
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "test_vpc"
    }
}

resource "aws_internet_gateway" "myigw" {
    vpc_id = aws_vpc.myvpc.id
    tags = {
        Name = "test_igw"
    }
}

resource "aws_subnet" "pub_sub" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.1.0/24"
    tags = {
        Name = "test_pubnet"
    }
}

resource "aws_subnet" "priv_sub" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.2.0/24"
    tags = {
        Name = "test_privnet"
    }
}

resource "aws_route_table" "my_route" {
    vpc_id = aws_vpc.myvpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myigw.id
    } 
    
    tags = {
        Name = "test_route"
    }
}

resource "aws_route_table_association" "my_pub_sub_assoc" {
    subnet_id = aws_subnet.pub_sub.id
    route_table_id = aws_route_table.my_route.id
}

resource "aws_eip" "my_eip" {
    domain = "vpc"
}

resource "aws_nat_gateway" "my_nat" {
    allocation_id = aws_eip.my_eip.id
    subnet_id = aws_subnet.pub_sub.id

    tags = {
        Name = "test_nat"
    }
}

resource "aws_route_table" "my_priv_route_table" {
    vpc_id = aws_vpc.myvpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.my_nat.id
    }
    tags = {
        Name = "test_priv_route_table"
    }
}

resource "aws_route_table_association" "my_priv_sub_assoc" {
    subnet_id = aws_subnet.priv_sub.id
    route_table_id = aws_route_table.my_priv_route_table.id
}

resource "aws_instance" "pub_instance" {
    ami = "ami-08718895af4dfa033"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.pub_sub.id
    associate_public_ip_address = true
    key_name = "testkey"

    tags = {
        Name = "test_pub_instance"
    }
}

resource "aws_instance" "priv_instance" {
    ami = "ami-08718895af4dfa033"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.priv_sub.id
    associate_public_ip_address = false
    key_name = "testkey"

    tags = {
        Name = "test_priv_instance"

    }
}

