provider "aws" {
    region     = "ap-northeast-1"
}

resource "aws_instance" "wordpressphost" {
    ami           = "ami-e499b383"
    instance_type = "t2.micro"
    key_name = "myawstokyokeypair"
}

resource "aws_db_instance" "wordpressdbinstance" {
  allocated_storage    = 5
  storage_type         = "gp2"
  engine               = "mariadb"
  engine_version       = "10.1.19"
  instance_class       = "db.t2.micro"
  name                 = "wordpressdb"
  username             = "wordpress"
  password             = "WordPress123***"
  parameter_group_name = "default.mariadb10.1"
}
