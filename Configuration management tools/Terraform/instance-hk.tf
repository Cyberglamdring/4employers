resource "aws_instance" "day4" {
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"
  key_name = "${lookup(var.keys, var.region)}"
  subnet_id = "${lookup(var.subnets, var.region)}"
  private_ip = "${lookup(var.iprange, var.region)}"
  

  provisioner "local-exec" {
    command = "echo ${aws_instance.day4.private_ip} > eip.txt"
    on_failure = "continue"
  }
}

data "aws_s3_bucket" "selected" {
  bucket = "${lookup(var.buckets, var.region)}"
}

output "ip" {
  value = "${aws_instance.day4.public_ip}"
}
