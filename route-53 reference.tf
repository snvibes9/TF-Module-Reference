/* # get hosted zone details
data "aws_route53_zone" "hosted_zone" {
  name = 
}

# create a record set in route 53
resource "aws_route53_record" "site_domain" {
  zone_id = 
  name    = 
  type    = 

  alias {
    name                   = 
    zone_id                = 
    evaluate_target_health = 
  }
} */

provider "aws" {
  region = "us-east-1"
}

##############################
# 1. Get Hosted Zone by Name #
##############################

data "aws_route53_zone" "hosted_zone" {
  name         = "example.com."  # Note the trailing dot
  private_zone = false           # Set to true if using private hosted zones
}

######################################
# 2. Create Route53 Alias Record Set #
######################################

resource "aws_route53_record" "site_domain" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "www.example.com"  # The subdomain (or use root like "example.com")
  type    = "A"                # Use "A" for alias to ALB or CloudFront

  alias {
    name                   = "d1234abcd.cloudfront.net"  # Example target DNS
    zone_id                = "Z2FDTNDATAQYW2"             # Example: CloudFront zone ID
    evaluate_target_health = false
  }
}
