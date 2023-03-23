# Dev Environment on EC2 using Terraform

### Deployed Services : 
1. EC2 instance (t2.micro)
2. Virtual Private Cloud (VPC)
3. Internet Gateway
4. Security Groups
5. Route Table



To connect to the Environment : 
* Generate your keys for the EC2 instance
* Then, type the below command
```
ssh -i <path to .ssh>\.ssh\<key-name> <instance_os>@<instace_public_ip>
```
To connect to the Environment via vscode :
* Install the Remote-SSH extension
* Run the provisioner provided in main.tf
  * Mention your path for respective ./ssh/config file
  * Note , now we have added the public IP of the instace in ./ssh/config
* Now, connected to the public ip using the extension

All resource in AWS have been allocated using terraform :fire:

*You need to have a AWS account*
 
