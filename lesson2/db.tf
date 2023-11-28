####### RDS Server Security Group
resource "aws_security_group" "database_1" {
  name = "Database SecurityGroup"
  description = "Database SecurityGroup"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Database 1 SecurityGroup"
  }
}

// Generate Password
resource "random_string" "rds_password" {
  length           = 12
  special          = true
  override_special = "#%*@"

  keepers = {
    passwordchanger = var.passname
  }
}

// Store Password in SSM Parameter Store
resource "aws_ssm_parameter" "rds_password" {
  name        = "/prod/mariadb"
  description = "Master Password for RDS MySQL"
  type        = "SecureString"
  value       = random_string.rds_password.result
# value       = var.database_master_password
}

// Get Password from SSM Parameter Store
  data "aws_ssm_parameter" "rds_password" {
  name       = "/prod/mariadb"
  depends_on = [aws_ssm_parameter.rds_password]
}
