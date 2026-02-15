terraform {
    backend "s3" {
        bucket = "test-581199458150"
        key    = "test/dev/terraform.tfstate"
        region = "us-east-1"
        dynamodb_table = "test-581199458150-locks"
        encrypt        = true
    }
}