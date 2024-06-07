provider "aws" {
  region = "us-west-2"
}

resource "aws_ecr_repository" "my_repository" {
  name = "my-ecr-repo"
}

resource "aws_ecs_cluster" "my_cluster" {
  name = "my-ecs-cluster"
}

resource "aws_ecs_task_definition" "my_task" {
  family                   = "my-task-family"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
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
  default_for_az = true
}

data "aws_security_group" "default" {
  name = "default"
}
