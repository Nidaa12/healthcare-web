# Troubleshooting Guide

## Common Issues and Solutions

### 1. Azure CLI and Authentication Issues

#### Issue: "az: command not found"
**Solution:**
```bash
# Install Azure CLI (Ubuntu/Debian)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Azure CLI (macOS)
brew install azure-cli

# Install Azure CLI (Windows)
# Download from: https://aka.ms/installazurecliwindows
```

#### Issue: "Please run 'az login' to setup account"
**Solution:**
```bash
az login
# Follow the browser authentication flow
```

#### Issue: "Insufficient privileges to complete the operation"
**Solution:**
- Ensure your Azure account has Contributor role on the subscription
- Check if you're using the correct subscription:
```bash
az account list --output table
az account set --subscription "Your Subscription Name"
```

### 2. SSH Connection Issues

#### Issue: "Permission denied (publickey)"
**Solution:**
```bash
# Check SSH key permissions
chmod 600 ~/.ssh/healthcare_vm_key
chmod 644 ~/.ssh/healthcare_vm_key.pub

# Test SSH connection
ssh -i ~/.ssh/healthcare_vm_key azureuser@<vm-public-ip>
```

#### Issue: "Connection timed out"
**Solution:**
1. Check if VM is running:
```bash
az vm show -g healthcare-rg -n healthcare-vm -d --query "powerState"
```

2. Verify Network Security Group rules:
```bash
az network nsg rule list -g healthcare-rg --nsg-name healthcare-vm-nsg --output table
```

3. Check if SSH service is running on VM:
```bash
# If you can access via Azure portal console
sudo systemctl status ssh
sudo systemctl start ssh
```

### 3. Website Deployment Issues

#### Issue: Website shows "502 Bad Gateway" or "404 Not Found"
**Solution:**
1. Check Nginx status:
```bash
ssh -i ~/.ssh/healthcare_vm_key azureuser@<vm-public-ip>
sudo systemctl status nginx
sudo systemctl restart nginx
```

2. Verify website files exist:
```bash
ls -la /var/www/healthcare/
```

3. Check Nginx configuration:
```bash
sudo nginx -t
sudo cat /etc/nginx/sites-enabled/healthcare
```

#### Issue: Website files not updating after deployment
**Solution:**
1. Check file permissions:
```bash
sudo chown -R www-data:www-data /var/www/healthcare
sudo chmod -R 755 /var/www/healthcare
```

2. Clear browser cache or test in incognito mode

3. Check if deployment actually completed:
```bash
# Check last modified time of files
ls -la /var/www/healthcare/
```

### 4. GitHub Actions Issues

#### Issue: "Error: The process '/usr/bin/az' failed with exit code 1"
**Solution:**
1. Verify AZURE_CREDENTIALS secret format:
```json
{
  "clientId": "...",
  "clientSecret": "...",
  "subscriptionId": "...",
  "tenantId": "..."
}
```

2. Check service principal permissions:
```bash
az role assignment list --assignee <client-id> --output table
```

#### Issue: "Host key verification failed"
**Solution:**
1. Update VM_PUBLIC_IP secret if VM IP changed
2. Check if SSH private key is correctly formatted in secrets
3. Ensure SSH key doesn't have passphrase

#### Issue: GitHub Actions workflow not triggering
**Solution:**
1. Check if workflow file is in correct location: `.github/workflows/`
2. Verify YAML syntax is correct
3. Ensure you're pushing to the `main` branch
4. Check repository settings for Actions permissions

### 5. Azure Resource Issues

#### Issue: "Resource group 'healthcare-rg' could not be found"
**Solution:**
```bash
# Create resource group manually
az group create --name healthcare-rg --location "East US"
```

#### Issue: "VM size 'Standard_B2s' is not available"
**Solution:**
```bash
# Check available VM sizes in your region
az vm list-sizes --location "East US" --output table

# Update the ARM template parameters with available size
```

#### Issue: "Quota exceeded" error
**Solution:**
1. Check your subscription quotas:
```bash
az vm list-usage --location "East US" --output table
```

2. Request quota increase through Azure portal or try smaller VM size

### 6. Network and Firewall Issues

#### Issue: Cannot access website from internet
**Solution:**
1. Check Network Security Group rules:
```bash
az network nsg rule list -g healthcare-rg --nsg-name healthcare-vm-nsg --output table
```

2. Verify public IP is assigned:
```bash
az network public-ip show -g healthcare-rg -n healthcare-vm-pip --query "ipAddress"
```

3. Check VM firewall (UFW):
```bash
ssh -i ~/.ssh/healthcare_vm_key azureuser@<vm-public-ip>
sudo ufw status
sudo ufw allow 'Nginx Full'
```

### 7. Performance Issues

#### Issue: Website loads slowly
**Solution:**
1. Check VM performance metrics in Azure portal
2. Consider upgrading VM size:
```bash
az vm resize --resource-group healthcare-rg --name healthcare-vm --size Standard_B4ms
```

3. Enable Nginx gzip compression (already configured in our setup)

#### Issue: High CPU usage on VM
**Solution:**
1. Monitor processes:
```bash
ssh -i ~/.ssh/healthcare_vm_key azureuser@<vm-public-ip>
top
htop  # if available
```

2. Check Nginx access logs:
```bash
sudo tail -f /var/log/nginx/access.log
```

## Diagnostic Commands

### Azure Resources
```bash
# List all resources in resource group
az resource list -g healthcare-rg --output table

# Get VM details
az vm show -g healthcare-rg -n healthcare-vm -d

# Check VM power state
az vm get-instance-view -g healthcare-rg -n healthcare-vm --query "instanceView.statuses[1].displayStatus"

# Get public IP
az network public-ip show -g healthcare-rg -n healthcare-vm-pip --query "ipAddress" -o tsv
```

### VM Diagnostics
```bash
# SSH to VM
ssh -i ~/.ssh/healthcare_vm_key azureuser@<vm-public-ip>

# Check system status
systemctl status nginx
systemctl status ssh
df -h  # Disk usage
free -h  # Memory usage
uptime  # System uptime and load

# Check logs
sudo journalctl -u nginx -f  # Nginx logs
sudo tail -f /var/log/nginx/error.log  # Nginx error log
sudo tail -f /var/log/nginx/access.log  # Nginx access log
```

### Network Diagnostics
```bash
# Test connectivity from local machine
ping <vm-public-ip>
telnet <vm-public-ip> 80
curl -I http://<vm-public-ip>

# Test from VM
ssh -i ~/.ssh/healthcare_vm_key azureuser@<vm-public-ip>
curl -I http://localhost
netstat -tlnp | grep :80
```

## Getting Additional Help

### Azure Support
- Azure documentation: https://docs.microsoft.com/en-us/azure/
- Azure support: https://azure.microsoft.com/en-us/support/
- Azure community: https://techcommunity.microsoft.com/t5/azure/ct-p/Azure

### GitHub Actions Support
- GitHub Actions documentation: https://docs.github.com/en/actions
- GitHub community: https://github.community/

### Emergency Procedures

#### Complete Resource Cleanup
```bash
# Delete entire resource group (WARNING: This deletes everything!)
az group delete --name healthcare-rg --yes --no-wait
```

#### Reset VM
```bash
# Restart VM
az vm restart -g healthcare-rg -n healthcare-vm

# Deallocate and start VM (full reset)
az vm deallocate -g healthcare-rg -n healthcare-vm
az vm start -g healthcare-rg -n healthcare-vm
```

#### Redeploy from Scratch
```bash
# Delete resource group
az group delete --name healthcare-rg --yes

# Wait for deletion to complete, then run deployment script again
./scripts/deploy.sh
```

