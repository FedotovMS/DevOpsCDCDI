# resource "aws_dynamodb_table" "locks" {
#  billing_mode = "PAY_PER_REQUEST"
#
#  attribute {
#    name = "LockID"
#    type = "S"
#  }

#  tags = {
#    Purpose = "terraform-locks"
#  }
#}