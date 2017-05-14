provider "aws" {
  region     = "ap-northeast-1"
}

resource "aws_instance" "example" {
  ami           = "ami-e499b383"
  instance_type = "t2.micro"
}
