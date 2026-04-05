# -------------------------------
# Get latest Amazon Linux AMI
# -------------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# -------------------------------
# Launch Template
# -------------------------------
resource "aws_launch_template" "swiggy-app-template" {
  name_prefix   = "swiggy-app-template-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [
    aws_security_group.swiggy-ec2-asg-sg-app.id
  ]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install mysql -y
  EOF
  )
}

# -------------------------------
# Auto Scaling Group
# -------------------------------
resource "aws_autoscaling_group" "swiggy-app-asg" {
  name = "swiggy-app-asg"

  launch_template {
    id      = aws_launch_template.swiggy-app-template.id
    version = "$Latest"
  }

  vpc_zone_identifier = [
    aws_subnet.swiggy-pvt-sub-1.id,
    aws_subnet.swiggy-pvt-sub-2.id
  ]

  min_size         = 2
  max_size         = 3
  desired_capacity = 2

  depends_on = [
    aws_launch_template.swiggy-app-template
  ]
}
