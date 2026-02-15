module "demo-ec2" {
    source  = "../projects/ec2"

  name = "demo-instance-dev"

  instance_type = "t3.micro"
  key_name      = "Demo-Key"
  env           = "dev"

}