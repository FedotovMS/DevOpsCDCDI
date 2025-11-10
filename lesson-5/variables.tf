variable "instance_type" {
  default = "t3.micro"
}

variable "aws_region" { 
  default = "eu-north-1" 
  }

variable "state_bucket_name" { 
  default = "my-lesson5-terraform-goit-neovercity-demo-hw5-state" 
  }

variable "state_lock_table_name" { 
  default = "terraform-locks" 
  }

###########
#VPC#######
###########
variable "vpc_cidr_block" { 
  default = "10.0.0.0/16" 
  }

variable "public_subnets" { 
  type = list(string) 
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"] 
  }

variable "private_subnets" { 
  type = list(string) 
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"] 
  }

variable "availability_zones" {
  default= ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  type        = list(string)
}

variable "vpc_name" { 
  type = string 
  default = "lesson-5-vpc" 
  }

#########
#ECR#####
#########

variable "ecr_name" { 
  type = string 
  default = "lesson-5-ecr" 
  }
variable "ecr_scan_on_push" { 
  type = bool 
  default = true 
  }