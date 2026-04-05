# -------------------------------
# Get latest Amazon Linux AMI
# -------------------------------
data "aws_ami" "amazon_linux_web" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# -------------------------------
# Launch Template (WEB)
# -------------------------------
resource "aws_launch_template" "swiggy-web-template" {
  name_prefix   = "swiggy-web-template-"
  image_id      = data.aws_ami.amazon_linux_web.id
  instance_type = "t3.small"

  vpc_security_group_ids = [
    aws_security_group.swiggy-ec2-asg-sg.id
  ]

  user_data = base64encode(file("apache.sh"))
}

# -------------------------------
# Auto Scaling Group (WEB)
# -------------------------------
resource "aws_autoscaling_group" "swiggy-web-asg" {
  name = "swiggy-web-asg"

  launch_template {
    id      = aws_launch_template.swiggy-web-template.id
    version = "$Latest"
  }

  vpc_zone_identifier = [
    aws_subnet.swiggy-pub-sub-1.id,
    aws_subnet.swiggy-pub-sub-2.id
  ]

  min_size         = 2
  max_size         = 3
  desired_capacity = 2

  depends_on = [
    aws_launch_template.swiggy-web-template
  ]
}
