provider "aws" {
  # Configuration options
  region  = "us-west-2"
  #profile = "default"   #Had errors because of the default line when my state got migrated to terraform cloud that's why it is commented.
  #https://discuss.hashicorp.com/t/error-error-configuring-terraform-aws-provider-failed-to-get-shared-config-profile-default/39417/2#:~:text=I%20confirm.%20Removing%20the%20profile%20line%20makes%20it%20work%3A
}

provider "aws" {
  # Configuration options
  #profile = "default"
  region  = "us-east-2"
  alias = "use2"
}