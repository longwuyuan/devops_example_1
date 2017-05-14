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

## Create a EC2 Instance using terraform

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
    key_name      = "mykeypair"
}
```

- I use awscli. So I have ~/.aws/credentials on all my computers. Hence I don't need to put my aws access keys in this file as terraform will use ~/.aws/credentials automatically.
- I am using RancherOS AMI ami-e499b383. So I don't need to install any software or configure any services. Reasons are explained here http://rancher.com/rancher-os/.





# PREFERRED SOLUTION

- If this was a real production wordpress, then it is better to use Terraform
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
