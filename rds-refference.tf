#########################
# Provider Configuration
#########################

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

#########################
# Fetch Existing VPC
#########################

# Option 1: By tag
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["my-vpc"]  # Change to your VPC name tag
  }
}

# Option 2: By CIDR (alternative)
# data "aws_vpc" "selected" {
#   cidr_block = "10.0.0.0/16"
# }

#########################
# Fetch Private Subnets
#########################

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.selected.id

  tags = {
    Tier = "private"
  }
}

data "aws_subnet" "private_subnets" {
  for_each = toset(data.aws_subnet_ids.private.ids)
  id       = each.key
}

#########################
# Security Groups
#########################

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP access"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
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
    Name = "web-sg"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Allow MySQL from web SG"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description     = "MySQL from web"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
  }
}

#########################
# RDS Subnet Group
#########################

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = data.aws_subnet_ids.private.ids
  description = "Private subnets for RDS"

  tags = {
    Name = "rds-subnet-group"
  }
}

#########################
# RDS Instance
#########################

resource "aws_db_instance" "rds" {
  identifier              = "mydb-instance"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  username                = "admin"
  password                = "StrongPassword123!"
  db_name                 = "mydatabase"
  multi_az                = false
  skip_final_snapshot     = true
  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  availability_zone       = data.aws_subnet.private_subnets[element(data.aws_subnet_ids.private.ids, 0)].availability_zone

  tags = {
    Name = "rds-instance"
  }
}
