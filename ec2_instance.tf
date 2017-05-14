provider "aws" {
    region     = "ap-northeast-1"
}

resource "aws_instance" "wordpressphost" {
    ami           = "ami-e499b383"
    instance_type = "t2.micro"
    key_name = "mykeypair"
    security_groups = ["sg-886b83ee"]
}
