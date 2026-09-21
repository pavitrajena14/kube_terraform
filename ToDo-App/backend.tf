terraform {
  backend "s3" {
    bucket       = "eks-terra-bucket123"
    key          = "backend/ToDo-App.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
  }
}