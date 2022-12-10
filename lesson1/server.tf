resource "aws_instance" "my_webserver" {
  ami                    = "ami-0b0dcb5067f052a63"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_webserver.id]
  user_data              = <<EOF
#!/bin/bash
yum -y update
yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h2>WebServer IP: $myip</h2><br>BTU 26.11.22"  >  /var/www/html/index.html
sudo service httpd start
chkconfig httpd on
EOF

  tags = {
    Name  = "Web Server Build by Terraform"
    lesson = "1"
  }
}
