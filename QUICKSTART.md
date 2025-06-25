# Quick Setup Guide

## Prerequisites

1. **Azure Subscription** - Active Azure subscription
2. **GitHub Account** - GitHub account for repository hosting
3. **Azure CLI** - Installed and configured on your local machine
4. **Git** - Installed on your local machine

## Quick Start (5 Steps)

### Step 1: Clone and Setup
```bash
# Clone this repository
git clone <your-repo-url>
cd healthcare-website

# Login to Azure
az login
```

### Step 2: Deploy Infrastructure
```bash
# Run the automated deployment script
./scripts/deploy.sh
```

This script will:
- Generate SSH keys
- Create Azure resource group
- Deploy VM infrastructure
- Configure Nginx web server
- Deploy the website

### Step 3: Create GitHub Repository
1. Create a new repository on GitHub
2. Push this code to your repository:
```bash
git remote add origin <your-repo-url>
git push -u origin main
```

### Step 4: Configure GitHub Secrets
In your GitHub repository, go to Settings > Secrets and variables > Actions, and add:

- **`AZURE_CREDENTIALS`**: Service principal JSON (see below)
- **`VM_SSH_PRIVATE_KEY`**: Content of `~/.ssh/healthcare_vm_key`
- **`VM_PUBLIC_IP`**: Your VM's public IP address

To create the service principal:
```bash
az ad sp create-for-rbac --name "healthcare-website-deploy" \
  --role contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/healthcare-rg \
  --sdk-auth
```

### Step 5: Test Deployment
1. Make a small change to any file
2. Commit and push to main branch
3. Check GitHub Actions tab for deployment status
4. Visit your website at `http://<vm-public-ip>`

## Manual Infrastructure Provisioning (Alternative)

If you prefer to use GitHub Actions for infrastructure provisioning:

1. Set up GitHub Secrets first (Step 4 above)
2. Go to Actions tab in your repository
3. Run "Provision Azure VM Infrastructure" workflow manually
4. Follow the prompts to select VM size and Ubuntu version

## Troubleshooting

### Common Issues:

**SSH Connection Failed:**
- Check if VM is running: `az vm show -g healthcare-rg -n healthcare-vm -d`
- Verify SSH key permissions: `chmod 600 ~/.ssh/healthcare_vm_key`

**Website Not Loading:**
- Check Nginx status: SSH to VM and run `sudo systemctl status nginx`
- Verify firewall rules in Azure NSG

**GitHub Actions Failing:**
- Verify all secrets are correctly set
- Check if service principal has proper permissions
- Ensure VM public IP is current in secrets

### Getting Help:

1. Check the full README.md for detailed instructions
2. Review GitHub Actions logs for specific error messages
3. Use Azure CLI to check resource status: `az resource list -g healthcare-rg`

## Resource Cleanup

To delete all resources when done:
```bash
az group delete --name healthcare-rg --yes --no-wait
```

## Next Steps

- Configure custom domain
- Set up SSL certificate
- Implement monitoring
- Explore Azure Web Apps (PaaS alternative)

