resource "aws_vpc" "talentflow_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "talentflow-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.talentflow_vpc.id

  tags = {
    Name = "talentflow-vpc-igw"
  }
}

resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.talentflow_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "talentflow-vpc-subnet-public1-eu-north-1a"
  }
}

resource "aws_subnet" "public_1b" {
  vpc_id                  = aws_vpc.talentflow_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "talentflow-vpc-subnet-public2-eu-north-1b"
  }
}

resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.talentflow_vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "talentflow-vpc-subnet-private1-eu-north-1a"
  }
}

resource "aws_subnet" "private_1b" {
  vpc_id            = aws_vpc.talentflow_vpc.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "talentflow-vpc-subnet-private2-eu-north-1b"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.talentflow_vpc.id
  service_name    = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = [aws_route_table.public.id]

  tags = {
    Name = "talentflow-vpc-vpce-s3"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.talentflow_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "talentflow-vpc-rtb-public"
  }
}

resource "aws_route_table_association" "pub_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "pub_1b" {
  subnet_id      = aws_subnet.public_1b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_s3_bucket" "resumes" {
  bucket        = "talentflow-resumes-prod-storage"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "resumes_crypto" {
  bucket = aws_s3_bucket.resumes.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "resumes_pab" {
  bucket                  = aws_s3_bucket.resumes.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
