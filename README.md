# API's and Databases

This project contains a terraform script (./terraform) to provision an AWS vpc, a public subnet with 2 nodes, a private subnet with a database that can communicate with each other. It also has an app that starts a postgres db and seeds it with nhl data from 2023. It exposes 4 endpoints that can be displayed on the browser in json format on port 3000.

# Example data

# Architecture

![architecture](./public/images/architecture.png)

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

- Display the public ipv4 of the ec2 instance crated on port 3000: `http://<your-aws-public-ip-address>:3000` and see that it displays the first 10 rows of the dataset.
- Go to `http://<your-aws-public-ip-address>:3000/players` and see the first 10 players
- `http://<your-aws-public-ip-address>:3000/toronto` will show all the toronto maple leafs players
- `http://<your-aws-public-ip-address>:3000/points` will show the 10 players that has the most amount of points scored

# How to run the app locally

- Start your PostgreSQL server. On pgAdmin you can turn on your connection with your password and localhost.
- Create `.env` file with your `POSTGRES_USER`, `HOST` or leave it to be localhost, `POSTGRES_DB`, and `PASSWORD`.
- Run

```sh
$ yarn
$ yarn start
```

- Go on your browser `http://localhost:3000/` to see the results and play with the different endpoints.

# URL to public GitHub repo

https://github.com/LaraTunc/wcd-5-apis-databases
