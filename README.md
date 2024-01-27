# API's and Databases

This project contains a terraform script (./terraform) to provision an AWS vpc, a public subnet with 2 nodes, a private subnet with a database that can communicate with each other. It also has the code that seeds a database and creates API endpoints that will be accessible on the ec2 public url.

# Example data

# Architecture

![architecture](./imagees/architecture.png)

# Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (version 0.15.0)
- [AWS CLI](https://aws.amazon.com/cli/) (optional, version 2.2.0)

### Installation

1. Install Terraform: [Terraform Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
2. Install AWS CLI (optional): [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

# How to run

- Export your env variables or create them in .tfvars: `AWS_REGION`, `AWS_PROFILE`, `KEY_PAIR_NAME`
- To run

```sh
$ terraform plan
$ terraform apply --auto-approve
```

- To destroy after

```sh
$ terraform destroy --auto-approve
```

# URL to public GitHub repo

https://github.com/LaraTunc/wcd-5-apis-databases
