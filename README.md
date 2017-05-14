# devops_example_1
Devops For Wordpress


# PROBLEM

## OPS terraform / ansible / packer / docker test

For this exercise, I would like you use tools like Terraform, Packer and Ansible. The goal is to setup a wordpress container on an ECS cluster.

I would like you use Packer with the Ansible provisioner to create a "ready to use" wordpress image that will use a rds database.

I would like you publish it on a git repository (Github or bitbucket), with a README explaining for example :

 * What you have done
 * How run your project
 * How components interact between each over
 * What problems did you have
 * How you would have done things to have the best HA/automated architecture
 * Share with us any ideas you have in mind to improve this kind of infrastructure.

We also would like you to answer in the README to that question :


Tomorrow we want to put this project in production. What would be your advices and choices to achieve that.
Regarding the infrastructure itself and also external services like the monitoring, ...

# SOLUTION

## Create a EC2 & RDS Instance using terraform

- I did this on Linux
- Make sure $PATH included $HOME/bin
- Downloaded terraform from https://www.terraform.io/downloads.html
- Unzip terraform executable in $HOME/bin
- Created a directory in $HOME called problem1
- Created a file with name _create_ec2_instance.tf_
- Put the below content in _create_ec2_instance.tf_

```
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
```

- I use awscli. So I have ~/.aws/credentials on all my computers. Hence I don't need to put my aws access keys in this file as terraform will use ~/.aws/credentials automatically.
- I am using RancherOS AMI ami-e499b383. So I don't need to install any software or configure any services. Reasons are explained here http://rancher.com/rancher-os/.





# PREFERRED SOLUTIONS

To describe a preferred solution, let us clearly define some imaginary specs ;

* Wordpress application has to be a docker container
* Commercial end-users of wordpress
* Least amount of complication required
* SSL required
* Caching required
* CI+CD required
* HA required
* Auto-scaling required
* Static content should be on S3 for persistent storage

# Preferred Solution # 1

For all the above needs, AWS documentation itself refers to the wordpress container on hub.docker.com as seen here   http://docs.aws.amazon.com/AmazonECS/latest/developerguide/example_task_definitions.html#example_task_definition-wordpress

- If this was a real production wordpress, then it is better to use Terraform for creating AWS-ECS (container service) config in terraform https://www.terraform.io/docs/providers/aws/r/ecs_service.html

- The official hub.docker.com Wordpress container can take environment variables as parameters to connect to the RDS. Examples of the environment variables for the official wordpress container are ;

```
-e WORDPRESS_DB_HOST=... (defaults to the IP and port of the linked mysql container)
-e WORDPRESS_DB_USER=... (defaults to "root")
-e WORDPRESS_DB_PASSWORD=... (defaults to the value of the MYSQL_ROOT_PASSWORD environment variable from the linked mysql container)
-e WORDPRESS_DB_NAME=... (defaults to "wordpress")
-e WORDPRESS_TABLE_PREFIX=... (defaults to "", only set this when you need to override the default table prefix in wp-config.php)
-e WORDPRESS_AUTH_KEY=..., -e WORDPRESS_SECURE_AUTH_KEY=..., -e WORDPRESS_LOGGED_IN_KEY=..., -e WORDPRESS_NONCE_KEY=..., -e WORDPRESS_AUTH_SALT=..., -e WORDPRESS_SECURE_AUTH_SALT=..., -e WORDPRESS_LOGGED_IN_SALT=..., -e WORDPRESS_NONCE_SALT=... (default to unique random SHA1s)
```


# Preferred Solution # 2

- Create a VPC with Public & Private subnet in terraform
- Create subnets in 2 availability Zones for HA in terraform
- Create 1 Server in each Public subnet with RacherOS as the AMI in terraform
- Run Rancher-Server in HA mode like this http://docs.rancher.com/rancher/v1.6/en/installing-rancher/installing-server/#multi-nodes using ansible
- After this stop using Ansible and Terraform for any other part of the architecture
- Remaining part of the architecture is all done using docker-compose.yml in Rancher
- Launch a host from Rancher API in each Public-Subnet with EIP and tag them as pubhost
- Launch a host from Rancher API in each private-subnet and tag it as privhost
- Launch a Wordpress stack inside rancher on privhost
- Launch HAProxy Containers inside Rancher on the pubhost
- Launch varnish cache container on privhost if not using AWS-CDN
- Link varnish cache container to wordpress backend if not using AWS-CDN
- Configure Wordpress static content & uploads directory to be served from S3
- Use the Catalog inside rancher to launch the Wordpress instance
- Use terraform to make & desroy Route53 DNS entry for the wordpress site's FQDN
- Pull the Official hub.docker.com Wordpress image instead of using packer to build the wordpress image
- Pass the environment variables to the official Wordpress image on ub.docker.com for connection to RDS
-
