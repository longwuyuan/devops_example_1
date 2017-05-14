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
    key_name = "...."
}

resource "aws_db_instance" "wordpressdbinstance" {
  allocated_storage    = 5
  storage_type         = "gp2"
  engine               = "mariadb"
  engine_version       = "10.1.19"
  instance_class       = "db.t2.micro"
  name                 = "wordpressdb"
  username             = "...."
  password             = "....."
  parameter_group_name = "default.mariadb10.1"
}
```

- I use awscli. So I have ~/.aws/credentials on all my computers. Hence I don't need to put my aws access keys in the config file as terraform will use ~/.aws/credentials automatically.

- I am using RancherOS AMI ami-e499b383. So I don't need to install any software or configure any services. Reasons are explained here http://rancher.com/rancher-os/.


- Type the below command to verify what will happen if you apply the above config ;

```
teraform plan
```

- Execute the planned config as follows

```
terraform apply
```
- The result is seen below, which can be confirmed from the AWS-Console

```
devops_example_1% terraform show
aws_db_instance.wordpressdbinstance:
  id = .......
  address = .........ap-northeast-1.rds.amazonaws.com
  allocated_storage = 5
  arn = arn:aws:rds:ap-northeast-1:......:db:......
  auto_minor_version_upgrade = true
  availability_zone = ap-northeast-1b
  backup_retention_period = 0
  backup_window = 19:47-20:17
  copy_tags_to_snapshot = false
  db_subnet_group_name = default
  endpoint = .........ap-northeast-1.rds.amazonaws.com:3306
  engine = mariadb
  engine_version = 10.1.19
  hosted_zone_id = Z24O6O9L7SGTNB
  iam_database_authentication_enabled = false
  identifier = .......
  instance_class = db.t2.micro
  iops = 0
  kms_key_id =
  license_model = general-public-license
  maintenance_window = sat:14:29-sat:14:59
  monitoring_interval = 0
  multi_az = false
  name = ......
  option_group_name = default:mariadb-10-1
  parameter_group_name = default.mariadb10.1
  password = ......
  port = 3306
  publicly_accessible = false
  replicas.# = 0
  replicate_source_db =
  security_group_names.# = 0
  skip_final_snapshot = false
  status = available
  storage_encrypted = false
  storage_type = gp2
  tags.% = 0
  timezone =
  username = ....
  vpc_security_group_ids.# = 1
  vpc_security_group_ids.3079241892 = sg-....
aws_instance.wordpressphost:
  id = i-0f9....
  ami = ami-e499b383
  associate_public_ip_address = true
  availability_zone = ap-northeast-1b
  disable_api_termination = false
  ebs_block_device.# = 0
  ebs_optimized = false
  ephemeral_block_device.# = 0
  iam_instance_profile =
  instance_state = running
  instance_type = t2.micro
  ipv6_address_count = 0
  ipv6_addresses.# = 0
  key_name = ....keypair
  monitoring = false
  network_interface.# = 0
  network_interface_id = eni-28b04066
  primary_network_interface_id = eni-28b04066
  private_dns = ip-1.....ap-northeast-1.compute.internal
  private_ip = 172.31.....
  public_dns = ......ap-northeast-1.compute.amazonaws.com
  public_ip = 52......
  root_block_device.# = 1
  root_block_device.0.delete_on_termination = true
  root_block_device.0.iops = 0
  root_block_device.0.volume_size = 8
  root_block_device.0.volume_type = standard
  security_groups.# = 0
  source_dest_check = true
  subnet_id = subnet-....
  tags.% = 0
  tenancy = default
  volume_tags.% = 0
  vpc_security_group_ids.# = 1
  vpc_security_group_ids.3079241892 = sg-....

devops_example_1%
```

- It is possible to completely delete and recreate the EC2 instance and the RDS database with a single command. To delete/destroy the ec2 and the rds ;

```
terraform destroy
```
To recreate the EC2 Instance & the RDS ;

```
terraform apply
```

## Create a custom wordpress docker image using packer & ansible

- Download packer and unzip it in $HOME/bin
- Install ansible from the linux package manager repository

- Create a new file called _create_wordpress_docker_image.json_
- Put the below content in the file _create_wordpress_docker_image.json_

```
{
    "builders": [
        {
            "type": "docker",
            "image": "",
            "commit": true
        }
    ],
    "provisioners": [
        {
            "type": "ansible-local",
            "playbook_dir": ".",
            "playbook_file": "wordpress.yml"
        }
    ],
    "post-processors": [
        [
            {
                "type": "docker-tag",
                "repository": "",
                "tag": ""
            },
            {
                "type": "docker-push",
                "login": "true",
                "login_username": "",
                "login_password": "",
                "login_email": ""
            }
        ]
    ]
}
```


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
