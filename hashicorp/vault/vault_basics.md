Vault:
vaut study guide: 

- How do applicati&ns get secrets?
- How do humans acquire secrets?
- How are secrets updated?
- How is a secret revoked?
- When were secrets used?
- What do we do in the event of compromise?

What is vault?:
HashiCorp Vault is an identity-based secrets and encryption management system.  
It is used to secure, store and protect secrets and other sensitive data 
# using a UI, CLI, or HTTP API. 

When we talk about vault the problem we're really talking about solving is the
secret management problem.

When we start talking about secret management the first question that naturally comes
up is what is a secret. 
- A secret is anything that you want to tightly control access to such as 
- API tokens, (Use for server-to-server communications, accessing public data like a weather API, integrating with 3rd party systems.)
- API keys,   (Use for user authentication, fine-grained access control (FGAC), granting temporary access to resources, browser access, and managing user sessions.)
- passwords, 
- TLS certificates (used to protect both the end users' information while it's in transfer, and to authenticate the website's organization identity to ensure users are interacting with legitimate website owners.)
- encryption keys  (a string of specifically organized bits designed to unscramble and decipher encrypted data.)

So secret management is all about managing a set of different credentials.
That is anything that might grant you authentication or authorization to a system 

The point is, we can use these to either login to a system and authenticate such as a username and
password or we're using to prove our identity. 
# stuffs like a TLS certificate. 
So we're using it to authorize access potentially. 
All of these things fall in the realm of secrets and these are things they want to carefully manage. 
We want to understand who has access to them. 
We want to understand who's been using these things. 
We want some story around how we can periodically rotate these.

# Vault provides a unified interface to any secret, while providing tight access control and recording a 
# detailed audit log.
# Vault validates and authorizes clients (users, machines, apps) before providing them access to secrets 
# or stored sensitive data.

why use vault? :
- Most enterprises today have credentials sprawled across their organizations.
- Passwords, API keys, and credentials are stored in plain text, app source code, config files, 
and other locations. 
- Because these credentials live everywhere, the sprawl can make it difficult and daunting to 
really know who has access and authorization to what.
- Having credentials in plain text also increases the potential for malicious attacks, both by 
internal and external attackers. 
- Vault was designed with these challenges in mind.
- Vault takes all of these credentials and centralizes them so that they are defined in one location, 
which reduces unwanted exposure to credentials.
- But Vault takes it a few steps further by making sure users, apps, and systems are authenticated and 
explicitly authorized to access resources, while also providing an audit trail that captures and 
preserves a history of clients' actions.

Key features of vault:
The key features of Vault are:
Secure Secret Storage:
arbitrary key/value secrets can be stored in Vault. 
Vault encrypts these secrets prior to writing them to persistent storage, so gaining access to the 
raw storage isn't enough to access your secrets.   

Dynamic Secrets: 
Vault can generate secrets on-demand for some systems, such as AWS or SQL databases.   
For example, when an application needs to access an S3 bucket, it asks Vault for credentials, 
and Vault will generate an AWS keypair with valid permissions on demand. After creating these 
dynamic secrets, Vault will also automatically revoke them after the lease is up.

Data Encryption:
Vault can encrypt and decrypt data without storing it. This allows security teams to define encryption 
parameters and developers to store encrypted data in a location such as a SQL database without having 
to design their own encryption methods.  

Leasing and Renewal: 
All secrets in Vault have a lease associated with them. At the end of the lease, Vault will automatically 
revoke that secret. Clients are able to renew leases via built-in renew APIs.  

Revocation: 
Vault has built-in support for secret revocation. Vault can revoke not only single secrets, but a tree 
of secrets, for example all secrets read by a specific user, or all secrets of a particular type. 
Revocation assists in key rolling as well as locking down systems in the case of an intrusion.  


how does it work? :
Vault works primarily with tokens and a token is associated to the client's policy. Each policy is 
path-based and policy rules constrains the actions and accessibility to the paths for each client. 
With Vault, you can create tokens manually and assign them to your clients, or the clients can log in 
and obtain a token.
link to diagram: https://developer.hashicorp.com/vault/docs/what-is-vault#:~:text=The%20illustration%20below%20displays%20Vault%27s%20core%20workflow.  

The core Vault workflow consists of four stages:
Authenticate: 
Authentication in Vault is the process by which a client supplies information that Vault uses to 
determine if they are who they say they are.  
Once the client is authenticated against an auth method, a token is generated and associated to a policy.

Validation: 
Vault validates the client against third-party trusted sources, such as Github, LDAP, AppRole, and more.  

Authorize:
A client is matched against the Vault security policy. This policy is a set of rules defining which API 
endpoints a client has access to with its Vault token. Policies provide a declarative way to grant or 
forbid access to certain paths and operations in Vault.  

Access:
Vault grants access to secrets, keys, and encryption capabilities by issuing a token based on policies 
associated with the client’s identity. 
The client can then use their Vault token for future operations.  

What is HCP Vault?:
HashiCorp Cloud Platform (HCP) Vault is a hosted version of Vault, which is operated by HashiCorp 
to allow organizations to get up and running quickly. HCP Vault uses the same binary as self-hosted 
Vault, which means you will have a consistent user experience. You can use the same Vault clients to 
communicate with HCP Vault as you use to communicate with a self hosted vault.
here: https://developer.hashicorp.com/hcp/docs/vault



different ways to deploy vault in:
k8s:
Vault can be deployed into Kubernetes using the official HashiCorp Vault Helm chart. 
The Helm chart allows users to deploy Vault in various configurations.

Dev: a single in-memory Vault server for testing Vault
Standalone (default): a single Vault server persisting to a volume using the file storage backend
High-Availability (HA): a cluster of Vault servers that use an HA storage backend such as Consul (default)
External: a Vault Agent Injector server that depends on an external Vault server

different cloud providers.
AWS:
AZURE:
GCP:
GITHUB:  
Vault installation: https://www.youtube.com/watch?v=-sU0O82fdZs&list=PL7iMyoQPMtAP7XeXabzWnNKGkCex1C_3C&index=2
Api Address: http://127.0.0.1:8200
Cluster Address: https://127.0.0.1:8201
Storage: inmem
Version: Vault v1.15.5, built 2024-01-26T14:53:40Z
Version Sha: xxxxxxxxx
$ export VAULT_ADDR='http://127.0.0.1:8200'
Unseal Key: xxxxxxxxx
Root Token: hvs.xxxxxxxxx
$ export VAULT_TOKEN='hvs.xxxxxxxxx'


In this section we will talk about three operations - 
ref: https://developer.hashicorp.com/vault/tutorials/getting-started/getting-started-first-secret
youtube: https://www.youtube.com/watch?v=SvyIkMDsdUY&list=PL7iMyoQPMtAP7XeXabzWnNKGkCex1C_3C&index=4
1. READ - For reading the secrets from the vault
2. WRITE/PUT - For writing the secrets inside the vault
3. DELETE - For removal of the secrets from the vault

▬▬▬▬▬▬ ⭐️ Vault Basic Commands ⭐️ ▬▬▬▬▬▬ 

WRITE SECRET ## 
$ vault kv put my/path my-key-1=value-1

READ SECRET ## 
$ vault kv get my/path 

READ the secrets in JSON format ## 
$ vault kv get -format=json my/path 

DELETE SECRET ##
$ vault kv delete my/path


note:
If you are using a new custom path you need to label it into the secret engine.
Enable secret path in Hashi corp ##
$ vault secrets enable -path=my kv

Basic vault commands:
vault: is the client 
kv: stands for key value 
put: staands for the write operaton 
my/path: is the path where you have to store your secret 
key: is the key of our secret 
value: is the value of our secret


In this section we will talk on secret engine and how to manage Hashicorp Vault secret engine. 
Here are the topics which we are going to cover -
ref from hashicorp: https://developer.hashicorp.com/vault/tutorials/getting-started/getting-started-secrets-engines 
youtube video: 
1. List secret engine path
2. Enable secret engine path
3. Disable secret engine path

▬▬▬▬▬▬ ⭐️ Command for Secret Engine ⭐️ ▬▬▬▬▬▬ 

1. Enable custom secret engine
$ vault secrets enable -path=my-custom-secret-engine-1 kv 

2. List all the secret engine available in vault
$ vault secrets list -detailed

3. Disable secret engine 
$ vault secrets disable my-custom-secret-engine-1


In this section of Dynamic secret generation, we will be using AWS account for generating the ACCESS_KEY and SECRET_KEY
ref: https://developer.hashicorp.com/vault/tutorials/getting-started/getting-started-dynamic-secrets
youtube: https://www.youtube.com/watch?v=V-YaXal0t4k&list=PL7iMyoQPMtAP7XeXabzWnNKGkCex1C_3C&index=4
▬▬▬▬▬▬ ⭐️ Dynamic Secrets generation commands ⭐️ ▬▬▬▬▬▬ 

1. Enable the secret engine path for AWS 
$ vault secrets enable -path=aws aws

2. View the secret list
$ vault secrets list

3. Write AWS root config inside your hashicorp vault
$ vault write aws/config/root \
access_key=xxxxxxxxx \
secret_key=xxxxxxxxx \
region=us-west-2

4. Setup role 
$ vault write aws/roles/my-ec2-role \
        credential_type=iam_user \
        policy_document=-<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1426528957000",
      "Effect": "Allow",
      "Action": [
        "ec2:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF

5. Generate access key and secret key for that role
$ vault read aws/creds/my-ec2-role  (To trigger the creation of an IAM user)
Here's how it works:
- This command instructs Vault to generate AWS credentials based on the my-ec2-role role configuration.
- When this command is executed, Vault interacts with AWS using the root credentials previously 
configured (vault write aws/config/root).
- Vault then dynamically creates a new IAM user in AWS and attaches the policy defined in the my-ec2-role. 
- This policy is specified in the role creation step (vault write aws/roles/my-ec2-role). 
So, the user creation in AWS doesn't happen when you're writing the 
role (vault write aws/roles/my-ec2-role), but when you're reading from the role to 
get credentials (vault read aws/creds/my-ec2-role). 

6.  Revoke the secrets if you do not want it any longer
$ vault lease revoke aws/creds/my-ec2-role/J8WHZJ5NItdH23KYYHdORv3K

When the credentials generated by Vault for an AWS IAM user are revoked, Vault will also delete the 
corresponding IAM user in AWS. This process is part of Vault's dynamic secret management, 
where credentials (and the associated entities like IAM users) are temporary and are meant to 
be short-lived.

Here's how the process typically works:

1. Credential Generation: When you use a command like `vault read aws/creds/my-ec2-role`, 
Vault creates a new IAM user in AWS and generates access credentials for this user.

2. Credential Lease: The credentials provided by Vault have a lease associated with them, meaning 
they are valid for a certain period. This lease duration can be configured in Vault.

3. Revocation: Once the lease expires, or if the credentials are revoked manually before the 
lease ends, Vault will automatically delete the IAM user in AWS. This deletion is part of Vault's 
built-in cleanup process to ensure that the temporary credentials do not remain active beyond their 
intended lifespan.

This automatic revocation and deletion mechanism is a key aspect of Vault's approach to maintaining 
tight security and preventing the proliferation of unused or unnecessary credentials.


In this section we will be taking a more deeper look onto HashiCorp vault policy:
ref: https://developer.hashicorp.com/vault/tutorials/getting-started/getting-started-policies
youtube: https://www.youtube.com/watch?v=Opdq8YPRLBQ&list=PL7iMyoQPMtAP7XeXabzWnNKGkCex1C_3C&index=6
Here are the topics we will be covering during the session 
1. What is HashiCorp vault policy
2. How to create Policy
3. What is Policy format
4. How to apply policy
5. Attach Vault policy with role
6. Generate access_id and secret_id for vault policy

▬▬▬▬▬▬ ⭐️ CLI command for handling vault policy⭐️ ▬▬▬▬▬▬ 

1. List vault policies 
$ vault policy list

2. Write your custom policy 
$ vault policy write my-policy - << EOF
# Dev servers have version 2 of KV secrets engine mounted by default, so will
# need these paths to grant permissions:
path "secret/data/*" {
  capabilities = ["create", "update"]
}

path "secret/data/foo" {
  capabilities = ["read"]
}
EOF


3. Read Vault policy details 
$ vault policy read my-policy

4. Delete Vault policy by policy name 
$ vault policy delete my-policy

5. Attach token to policy 
$ export VAULT_TOKEN="$(vault token create -field token -policy=my-policy)"
$ vault kv put -mount=secret creds password="my-long-password"  (to test)

$ vault auth list (to list the authentication methods)
$ vault auth enable approle (to enable a new role)

6. Associate auth method with policy 
$ vault write auth/approle/role/my-role \
    secret_id_ttl=10m \
    token_num_uses=10 \
    token_ttl=20m \
    token_max_ttl=30m \
    secret_id_num_uses=40 \
    token_policies=my-policy

7. Generate and Export Role ID
export ROLE_ID="$(vault read -field=role_id auth/approle/role/my-role/role-id)"

8. Generate and Export Secret ID
export SECRET_ID="$(vault write -f -field=secret_id auth/approle/role/my-role/secret-id)"

9. uthenticate to AppRole with vault write by specifying the role path and passing the role ID and secret ID values with the respective options.
$ vault write auth/approle/login role_id="$ROLE_ID" secret_id="$SECRET_ID"

In this section of HashiCorp Vault for Token Authentication & GitHub Authentication, we are gonna take a look on: 
1. How to generate Token
2. How to do vault login using Root Token
3. How to use GithHub Access token for Authentication and login into Vault

▬▬▬▬▬▬ ⭐️ Token and GitHub Authentication commands ⭐️ ▬▬▬▬▬▬ 

1. Create token 
$ vault token create

2. Vault login
$ vault login 

3. Revoke token
$ vault token revoke YOUR_TOKEN_STRING

4. List all authentication methods
$ vault auth list

5. Enable GitHub Authentication
$ vault auth enable gitHub

6. Create Organization in HashiCorp vault
$ vault write auth/github/config organization=jhooq-test-org-2

7. Create team
$ vault write auth/github/map/teams/my-teams value=default,application

8. Vault login using Github Method
$ vault login -method=github

9. Revoke Github Authentication
$ vault token revoke -mode path auth/github

10. Disable Github Authentication
$ vault auth disable github


In this section we are gonna take look on Deployment of Vault along with UI as well as HTTP API. Here are the list of topic we are gonna cover - 

1. How to deploy vault in production
2. Create config.hcl for vault's storage, listner, api_address, cluster and UI
3. Starting the Vault server with server config
4. What are seal and unseal tokens
5. How to access the UI of vault
6. Rest HTTP API of vault from command line interface

▬▬▬▬▬▬ ⭐️ Dynamic Secrets generation commands ⭐️ ▬▬▬▬▬▬ 

1. Unset development token
$ unset VAULT_TOKEN

2. Vault's config.hcl 
storage "raft" {
  path    = "./vault/data"
  node_id = "node1"
}

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = "true"
}

api_addr = "http://127.0.0.1:8200"
cluster_addr = "https://127.0.0.1:8201"
ui = true


3. Create "RAFT" storage backend directory
$ mkdir -p ./vault/data

4. Starting vault server using config.hcl 
$ vault server -config=config.hcl

5. Export VAULT_ADDR
$ export VAULT_ADDR='http://127.0.0.1:8200'

6. Initialize vault
$ vault operator init

7. Unseal vault
$ vault operator unseal

Unseal Key 1: xxxxxxxxx
Unseal Key 2: xxxxxxxxx
Unseal Key 3: xxxxxxxxx
Unseal Key 4: xxxxxxxxx
Unseal Key 5: xxxxxxxxx

Initial Root Token: hvs.xxxxxxxxx




Vault demo youtube: https://www.youtube.com/watch?v=BI8ZlflTWfs

repo: https://github.com/joatmon08/getting-into-vault/tree/main/configure

architecture: https://developer.hashicorp.com/vault/docs/internals/architecture 

installation: https://developer.hashicorp.com/vault/docs/configuration

cert: openssl -new newkey -x509 -keyout vault.key -sha256 -days 365 -nodes -out vault.crt

