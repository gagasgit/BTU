variable "region" {
  description = "Please Enter AWS Region to deploy Server"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Enter Instance Type"
  type        = string
  default     = "t2.micro"
}


variable "allow_ports" {
  description = "List of Ports to open for server"
  type        = list
  default     = ["80", "443", "22", "8080"]
}

variable "enable_detailed_monitoring" {
  type    = bool
  default = false
}


variable "common_tags" {
  description = "Common Tags to apply to all resources"
  type        = map
  default = {
    Project     = "Internal_Project"
    Environment = "Production"
  }
}

####

variable "rds_instance_type" {
  description = "Enter Instance Type"
  type        = string
  default     = "db.t2.micro"
}

# variable "database_master_password" {}

variable "passname" {
  default = "nanadaa"
}
