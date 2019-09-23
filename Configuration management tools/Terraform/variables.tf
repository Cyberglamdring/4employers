variable "region" {
  default = "us-east-2"
}

variable "amis" {
  type = "map"
  default = {
    "us-east-1" = "ami-0d747e7903ded9955"
    "us-east-2" = "ami-0d8f6eb4f641ef691"
  }
}

variable "keys" {
  type = "map"
  default = {
    "us-east-1" = "Thenumber"
    "us-east-2" = "key-ohio"
  }
}

variable "subnets" {
  type = "map"
  default = {
	"us-east-1" = "subnet-54d0f133"
	"us-east-2" = "subnet-0bf94e47"
  }
}

variable "iprange" {
  type = "map"
  default = {
	"us-east-1" = "172.31.2.221"
	"us-east-2" = "172.31.32.221"
  }
}

variable "buckets" {
  type = "map"
  default = {
	"us-east-1" = "trial1408"
	"us-east-2" = "hkanonik"
  }
}
 