
resource "aws_apigatewayv2_api" "gateway" {

  name                       = "earthbenders-http-api"
  protocol_type              = "HTTP"

}

resource "aws_apigatewayv2_integration" "get_request_integration" {

  api_id = aws_apigatewayv2_api.gateway.id
  integration_type = "AWS_PROXY"
  description = "GET_lambda_integration_method"
  integration_uri = aws_lambda_function.get_lambda.invoke_arn
  

}

resource "aws_apigatewayv2_deployment" "get_request_deployment" {
  
  api_id = aws_apigatewayv2_api.gateway.id
  description = "GET_lambda_deployment_method"
  
  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_apigatewayv2_stage" "get_request_stage" {
  
  api_id = aws_apigatewayv2_api.gateway.id
  auto_deploy = true
  name = "default"

      access_log_settings {

    destination_arn = aws_cloudwatch_log_group.gateway.arn


    # configuration for cloudwatch
    format = jsonencode({

      requestId               = "$context.requestId"

      sourceIp                = "$context.identity.sourceIp"

      requestTime             = "$context.requestTime"

      protocol                = "$context.protocol"

      httpMethod              = "$context.httpMethod"

      resourcePath            = "$context.resourcePath"

      routeKey                = "$context.routeKey"

      status                  = "$context.status"

      responseLength          = "$context.responseLength"

      integrationErrorMessage = "$context.integrationErrorMessage"

      }

    )

}
}

resource "aws_apigatewayv2_route" "get_request_route" {

   api_id = aws_apigatewayv2_api.gateway.id
   route_key = "GET /posts"
   # use this to see it as the default route... mostly good for testing
   #route_key = "$default"
   target = "integrations/${aws_apigatewayv2_integration.get_request_integration.id}"
   
}


# Included for debugging, will tell us what errors we get from aws console
resource "aws_cloudwatch_log_group" "gateway" {
  name = "/aws/${aws_apigatewayv2_api.gateway.name}"
  retention_in_days = 1
}