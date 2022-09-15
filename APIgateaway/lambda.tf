resource "aws_iam_role" "lambda_iam" {
  
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
        "Service": "lambda.amazonaws.com"
      },

      "Effect": "Allow",
      "Sid": ""

    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_iam.id

  policy = file("policy.json")
}


# We need a role AND a permission or it won't connect correctly
# we will need this for each lambda we create, change function_name to include our current lambda 
# ex. get_lamba -> new_lambda
resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = var.lambda_action
  function_name = aws_lambda_function.get_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_apigatewayv2_api.gateway.execution_arn}/*/*"
}

resource "aws_lambda_function" "get_lambda" {
  # If the file is not in the current working directory you will need to include a 
  # path.module in the filename.
  filename      = "index.zip"
  function_name = "cr-sprint5-earthbenders-POST-GET"
  role          = aws_iam_role.lambda_iam.arn
  # This needs to be index.handler, not .js... not really sure why?
  handler       = "index.handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
#   source_code_hash = filebase64sha256("lambda_function_payload.zip")

  # The one in the documentaiton is node 12 but we need node 16 for it to work
  runtime = "nodejs16.x"

  # environment {
  #   variables = {
  #     foo = "bar"
  #   }
  # }

# Environemnt Variables that we need to configure
# May want to put these into a variables.tf file and NOT upload to bitbucket
  environment {
    variables = {
      TABLE_NAME  = var.dynamo_table
      BUCKET_NAME = var.s3_bucket   
    }
 }
}
