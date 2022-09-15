# For demo

# Public bucket for front-end
resource "aws_s3_bucket" "earthbenders-s3-public" {
  bucket = "earthbenders-s3-demo"

  tags = {
    Name        = "earthbenders-s3-demo"
    Environment = "Dev"
  }
}

# Public bucket policy to allow access
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.earthbenders-s3-public.id
  policy = <<EOF
   {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::earthbenders-s3-demo/*"
        }
    ]
   }
   EOF
}


# DEMO ################################















# Private bucket for images
resource "aws_s3_bucket" "earthbenders-s3-private" {
  bucket = "earthbenders-s3-private"

  tags = {
    Name        = "earthbenders-s3-private"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "earthbenders-s3-private" {
  bucket = aws_s3_bucket.earthbenders-s3-private.id
  acl    = "private"
}

resource "aws_s3_bucket_website_configuration" "earthbenders-website" {
  bucket = aws_s3_bucket.earthbenders-s3-public.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_acl" "earthbenders-s3-public" {
  bucket = aws_s3_bucket.earthbenders-s3-public.id
  acl    = "public-read"
}



# This uploads frontend to S3
resource "aws_s3_object" "object1" {
  for_each = fileset("frontend/build/", "**/*.*")
  bucket   = aws_s3_bucket.earthbenders-s3-public.id
  key      = each.value
  source   = "frontend/build/${each.value}"
  etag     = filemd5("frontend/build/${each.value}")
  # needed to host website?
  content_type = "text/html"
}

# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Sid": "PublicReadGetObject",
#             "Effect": "Allow",
#             "Principal": "*",
#             "Action": "s3:GetObject",
#             "Resource": "arn:aws:s3:::earthbenders-s3-public/*"
#         }
#     ]
# }