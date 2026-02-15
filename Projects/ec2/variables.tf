  variable "name"   { }
  variable "instance_type" { }
  variable "key_name"      { }
  variable "monitoring"    { 
    default = "false"
   }
  variable "subnet_id"     {
    default = "subnet-542ecb32"
   }
  variable "env"   { }
  
  variable "vpc_id" {
    default = "vpc-b50e3fcf"
  }