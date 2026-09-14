resource "aws_instance" "myinstance" {
  ami           = "ami-053ea429a1c73a5b7"
  instance_type = "t3.micro"

  tags = {
    Name = "Terraform-EC2" 
  }
}