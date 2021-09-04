aws_region = "region"
map_accounts = []
map_roles = [
    {
      rolearn  = "arn:aws:iam::66666666666:role/role1"
      username = "role1"
      groups   = ["system:masters"]
    }
  ]
map_users = [
    {
      userarn  = "arn:aws:iam::66666666666:user/username"
      username = "garrett.username"
      groups   = ["system:masters"]
    }
  ]
