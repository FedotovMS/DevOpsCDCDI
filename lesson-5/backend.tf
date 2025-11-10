terraform {
  backend "s3" {
    bucket         = "my-lesson5-terraform-goit-neovercity-demo-hw5-state"
    key            = "lesson-5/terraform.tfstate"
    region         = "eu-north-1"                        
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}