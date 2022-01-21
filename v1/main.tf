terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

}

provider "aws" {
  profile = "terraform"
  region  = "eu-west-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0fdbd8587b1cf431e"
  instance_type = "t2.micro"

  tags = {
    Name = var.instance_name
  }
}
