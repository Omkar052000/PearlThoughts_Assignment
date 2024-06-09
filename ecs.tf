provider "aws" {
  region = "ap-south-1"
}

resource "aws_ecr_repository" "my_repository" {
  name = "my-ecr-repo"
}

resource "aws_ecs_cluster" "my_cluster" {
  name = "my-ecs-cluster"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}

resource "aws_ecs_task_definition" "my_task" {
  family                   = "my-task-family"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  cpu                      = "256"
  memory                   = "512"
  
  container_definitions = jsonencode([{
    name  = "my-container"
    image = "${aws_ecr_repository.my_repository.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_ecs_service" "my_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [data.aws_subnet.default.id]
    security_groups = [data.aws_security_group.default.id]
  }
}

data "aws_subnet" "default" {
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
  filter {
    name   = "availability-zone"
    values = ["ap-south-1a"] # specify the availability zone
  }
}

data "aws_security_group" "default" {
  filter {
    name   = "group-name"
    values = ["default"]
  }
  vpc_id = data.aws_vpc.default.id
}

data "aws_vpc" "default" {
  default = true
}
