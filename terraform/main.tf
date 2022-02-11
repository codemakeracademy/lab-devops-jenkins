provider "aws" {
  region  = "us-west-2" # Oregon
  profile = "PowerUserAccess-529396670287"
}

resource "aws_vpc" "trogaev-vpc" {
  cidr_block = "172.16.0.0/16"
  enable_dns_hostnames = true
  
  tags = {
    Name = "trogaev-vpc"
  }
}

resource "aws_subnet" "trogaev-subnet" {
  vpc_id = aws_vpc.trogaev-vpc.id
  cidr_block = "172.16.10.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "trogaev-subnet"
  }
}

resource "aws_internet_gateway" "trogaev-gateway" {
  vpc_id = aws_vpc.trogaev-vpc.id

  tags = {
    Name = "trogaev-gateway"
  }
}

resource "aws_route_table" "trogaev-table" {
  vpc_id = aws_vpc.trogaev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.trogaev-gateway.id
  }

  tags = {
    Name = "trogaev-route-table"
  }
}

resource "aws_security_group" "trogaev-sg" {
  vpc_id = aws_vpc.trogaev-vpc.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "trogaev-sg"
  }
} 

resource "aws_eip" "trogaev-eip" {
  instance = aws_instance.trogaev-jenkins-lab.id
  vpc      = true
}

resource "aws_key_pair" "trogaev_key" {
  key_name = "rp"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7E0QKlKmk97ZeNjl8pC0g898h7MqF8ci/YbamrYSkgAemVc5drIafHHvzi+njpjHUiOH7pPP/nS8l7bZSGPdQW+mYYcmMjm0AlqFdp84GTuSz15CQJmWyx03eLnWXfe4cKx6mdc3BqMQduF/E7/SeO3ZGOatzY766FOo97KSbPqc8mtb9HR2JhPwugCiEqYWB6o+sl3+9/1V7gc8PzHnJKJkd9nvvYSZ3bQuC2S715WQvRuxYs1SqBfBn5tknYPYcs8nvP+fUXj/5yiYsNNw1CrMlgRF9oD9EI/w9jgrxsxuleCEzcfmo8GX3iK+Bg4aqaIC2k+ImZ8gnROtiiEJL pi@raspberrypi"
}

resource "aws_instance" "trogaev-jenkins-lab" {
  ami = "ami-0892d3c7ee96c0bf7"
  instance_type = "t3.large"
  subnet_id = aws_subnet.trogaev-subnet.id
  vpc_security_group_ids = [aws_security_group.trogaev-sg.id] 
  key_name = aws_key_pair.trogaev_key.key_name
  iam_instance_profile = "jenkins"
  root_block_device {
    volume_size = "20"
  }
  tags = {
    Name = "trogaev-jenkins-lab"
  }
}

resource "aws_instance" "trogaev-jenkins-k8s" {
  ami = "ami-0892d3c7ee96c0bf7"
  instance_type = "t3.large"
  subnet_id = aws_subnet.trogaev-subnet.id
  vpc_security_group_ids = [aws_security_group.trogaev-sg.id] 
  key_name = aws_key_pair.trogaev_key.key_name
  iam_instance_profile = "jenkins"
  root_block_device {
    volume_size = "20"
  }
  tags = {
    Name = "trogaev-jenkins-k8s"
  }
}

resource "aws_cloudwatch_metric_alarm" "trogaev_alarm" {
    alarm_name          = "trogaev_alarm"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods  = 12
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = 300
    statistic           = "Average"
    threshold           = 10
    alarm_description = "Stop the EC2 instance when CPU utilization stays below 10% on average for 12 periods of 5 minutes, i.e. 1 hour"
    alarm_actions     = ["arn:aws:automate:us-west-2:ec2:stop"]
    dimensions = {
        InstanceId = "${aws_instance.trogaev-jenkins-lab.id}"
    }
}

resource "aws_cloudwatch_metric_alarm" "trogaev2_alarm" {
    alarm_name          = "trogaev2_alarm"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods  = 12
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = 300
    statistic           = "Average"
    threshold           = 10
    alarm_description = "Stop the EC2 instance when CPU utilization stays below 10% on average for 12 periods of 5 minutes, i.e. 1 hour"
    alarm_actions     = ["arn:aws:automate:us-west-2:ec2:stop"]
    dimensions = {
        InstanceId = "${aws_instance.trogaev-jenkins-k8s.id}"
    }
}

resource "aws_dynamodb_table" "dynamodb-terraform-state-trogaev" {
  name = "terraform-state-lock-trogaev"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "trogaev-bucket-remote-state" {
  bucket = "trogaev-bucket-remote-state"
  acl    = "public-read"

  versioning {
    enabled = true
  }

  tags = {
    Name        = "trogaev-bucket-remote-state"
  }

}