
docker run --name vault -p 8200:8200 vault:1.12.7

You may need to set the following environment variables:

$ export VAULT_ADDR='http://0.0.0.0:8200'

Unseal Key: ****
Root Token: ***


export TF_VAR_aws_access_key=***
export TF_VAR_aws_secret_key=***
export VAULT_ADDR='http://0.0.0.0:8200'
export VAULT_TOKEN=***
