# Define AWS provider and region
provider "aws" {
  region = "us-east-1"  # Replace with your desired AWS region
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_vpc" "ecs_vpc" {
  cidr_block = data.aws_vpc.default.cidr_block
}

/*data "aws_subnet" "default" {
  vpc_id  = data.aws_vpc.default.id
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}*/

# Create the first subnet
resource "aws_subnet" "ecs_subnet1" {
  vpc_id     = aws_vpc.ecs_vpc.id
  cidr_block = "172.31.80.0/20"
  availability_zone = "us-east-1a"  # Replace with the desired availability zone
}

# Create the second subnet
resource "aws_subnet" "ecs_subnet2" {
  vpc_id     = aws_vpc.ecs_vpc.id
  cidr_block = "172.31.16.0/20"
  availability_zone = "us-east-1b"  # Replace with the desired availability zone
}

data "aws_security_group" "default" {
  name = "default"
  vpc_id = aws_vpc.ecs_vpc.id
}


# Create an ECS task definition for the Flask app
resource "aws_ecs_task_definition" "flask_task" {
  family                   = "flask-app-task"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu = "256"  # Specify the CPU units for the task
  memory = "512"  # Specify the memory value for the task
  container_definitions = jsonencode([
    {
      name      = "flask-app"
      image     = "289624618993.dkr.ecr.us-east-1.amazonaws.com/flask_app_repo:latest"  # Replace with your ECR repository URL
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]
    }
  ])
}

# Create an ECS service to run the Flask app
resource "aws_ecs_service" "flask_service" {
  name            = "flask-app-service"
  cluster         = aws_ecs_cluster.flask_cluster.id
  task_definition = aws_ecs_task_definition.flask_task.arn
  desired_count   = 1 

  /*deployment_controller {
    type = "ECS"
  }*/

  network_configuration {
    subnets         = [aws_subnet.ecs_subnet1.id,aws_subnet.ecs_subnet2.id]
    security_groups = [data.aws_security_group.default.id]
  }

  /*load_balancer {
    target_group_arn = aws_lb_target_group.flask_target_group.arn
    container_name   = "flask-app"
    container_port   = 5000
  }*/
}

# Create an ECS cluster for the Flask app
resource "aws_ecs_cluster" "flask_cluster" {
  name = "flask-app-cluster"
}

# Create an IAM role for ECS task execution
resource "aws_iam_role" "ecs_execution_role" {
  name = "flask-ecs-execution-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Create an IAM policy for ECS task execution
resource "aws_iam_policy" "ecs_execution_policy" {
  name = "flask-ecs-execution-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ecs:*",
                "ecr:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        }
    ]
}
EOF
}

# Attach the IAM policy to the ECS execution role
resource "aws_iam_role_policy_attachment" "ecs_execution_policy_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_execution_policy.arn
}

/*# Create an Application Load Balancer target group
resource "aws_lb_target_group" "flask_target_group" {
  name        = "flask-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.ecs_vpc.id
  target_type = "ip"
}

# Associate the target group with the ALB
resource "aws_lb_target_group_attachment" "flask_attachment" {
  target_group_arn  = "arn:aws:elasticloadbalancing:us-east-1:289624618993:targetgroup/flask-target-group/cabd229df5535383"
  target_id         = aws_ecs_service.flask_service.id
  port             = 80
}

# Create an Application Load Balancer listener
resource "aws_lb_listener" "flask_listener" {
  load_balancer_arn = aws_lb.flask_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.flask_target_group.arn
    type             = "forward"
  }
}

# Create an Application Load Balancer
resource "aws_lb" "flask_lb" {
  name               = "flask-load-balancer"
  load_balancer_type = "application"
  subnets            = [aws_subnet.ecs_subnet1.id, aws_subnet.ecs_subnet2.id]
  security_groups    = [aws_security_group.ecs_sg.id]
}

# Create a route table
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.ecs_vpc.id
}

# Associate the route table with a subnet
resource "aws_route_table_association" "example" {
  subnet_id      = aws_subnet.ecs_subnet1.id
  route_table_id = aws_route_table.example.id
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.ecs_vpc.id
}

resource "aws_route" "example" {
  route_table_id         = aws_route_table.example.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.example.id
}
*/
