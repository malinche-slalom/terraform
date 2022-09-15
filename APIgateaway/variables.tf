variable "dynamo_table" {
  type = string
  default = "earthbenders-db"
  #default = "earthbenders-dd"
}

variable "s3_bucket" {
  type = string
  default = "earthbenders-s3-public"
}

variable "lambda_action" {
    type = string
    default = "lambda:InvokeFunction"
}