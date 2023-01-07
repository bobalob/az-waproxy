# Az-WAProxy

Terraform config for a [WhatsApp Proxy server](https://github.com/WhatsApp/proxy/) in Azure using a Ubuntu 22.04 VM.

## Usage

Use normal terraform flow to run, you'll need to set a few variables. You will need [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed and [terraform](https://developer.hashicorp.com/terraform/downloads) in your path.

```management_range``` is the public IP of your current machine, it will open up SSH and the HAProxy management port (tcp/8199) to your public IP.

    git clone https://github.com/bobalob/az-waproxy
    cd az-waproxy
    terraform init
    az login
    az account set --subscription "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    terraform apply -var 'ssh_public_key=ssh-rsa AAAA...' -var 'username=bob' -var 'management_range=1.2.3.4'

Terraform will output the public IP and FQDN of the new server. For some reason, I've been unable to enter the FQDN into WhatsApp, it will only accept an IP.

If you're on Windows in PowerShell you can connect to the VM like this

    ssh (terraform show --json | ConvertFrom-Json).Values.outputs.ssh_string.value
