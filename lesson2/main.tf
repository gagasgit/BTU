provider "aws" {
  region = var.region
}

resource "aws_default_vpc" "default" {} # This need to be added since AWS Provider v4.29+ to get VPC id

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


resource "aws_eip" "my_static_ip" {
  vpc      = true # Need to add in new AWS Provider version
  instance = aws_instance.my_server.id
 // tags     = var.common_tags
  tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} Server IP" })

}


resource "aws_instance" "my_server" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.my_server.id]
  monitoring             = var.enable_detailed_monitoring
 # user_data              = file("server_cms.sh")
user_data = <<-EOF
  #!/bin/bash
  sudo yum -y update
  sudo yum -y install httpd
  sudo yum install -y mysql
  sudo amazon-linux-extras enable php7.4
  sudo yum clean metadata
  sudo yum install -y php php-{pear,cgi,common,curl,mbstring,gd,mysqlnd,gettext,bcmath,json,xml,fpm,intl,zip,imap,devel}
  sudo usermod -a -G apache ec2-user
  sudo chown -R ec2-user:apache /var/www
  sudo chmod 2775 /var/www
  sudo find /var/www -type d -exec chmod 2775 {} \;
  sudo find /var/www -type f -exec chmod 0664 {} \;
  sudo mkdir -p /var/www/inc
  sudo cat <<EOT > /var/www/inc/dbinfo.inc
  <?php
  define('DB_SERVER', '${aws_db_instance.db.address}');
  define('DB_USERNAME', 'webapp');
  define('DB_PASSWORD', '${random_string.rds_password.result}');
  define('DB_DATABASE', 'appmariadb');
  ?>
  EOT
  cd /var/www/html
  wget https://raw.githubusercontent.com/gagasgit/DATABASE_Check_APP/main/index.php
  sudo service httpd start
  chkconfig httpd on
EOF

  depends_on = [aws_db_instance.db]
  tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} Server Build by Terraform" })

}

resource "aws_security_group" "my_server" {
  name   = "My Security Group"
  vpc_id = aws_default_vpc.default.id # This need to be added since AWS Provider v4.29+ to set VPC id

  dynamic "ingress" {
    for_each = var.allow_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} Server SecurityGroup" })

}

#######################################

output "my_server_ip" {
  value = aws_eip.my_static_ip.public_ip
}

output "my_instance_id" {
  value = aws_instance.my_server.id
}

output "my_sg_id" {
  value = aws_security_group.my_server.id
}

output "rds_password" {
  value = data.aws_ssm_parameter.rds_password.value
  sensitive = true
}

# output "DB_Instance_Endpoint" {
#     value = aws_db_instance.db
# }

# output "DB_Instance_Status" {
#     value = aws_db_instance.db
# }

#terraform taint aws_instance.my_server
