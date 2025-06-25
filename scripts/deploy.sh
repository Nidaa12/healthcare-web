#!/bin/bash

# Azure VM Deployment Script for Healthcare Website
# This script creates the Azure infrastructure and deploys the healthcare website

set -e

# Configuration
RESOURCE_GROUP_NAME="healthcare-web"
LOCATION="East US"
VM_NAME="healthcare-vm"
ADMIN_USERNAME="azureuser"
DEPLOYMENT_NAME="healthcare-vm-deployment"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Azure CLI is installed
check_azure_cli() {
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed. Please install it first."
        print_status "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
        exit 1
    fi
    print_success "Azure CLI is installed"
}

# Function to check if user is logged in to Azure
check_azure_login() {
    if ! az account show &> /dev/null; then
        print_error "You are not logged in to Azure. Please run 'az login' first."
        exit 1
    fi
    print_success "Azure login verified"
}

# Function to generate SSH key pair if it doesn't exist
generate_ssh_key() {
    SSH_KEY_PATH="$HOME/.ssh/healthcare_vm_key"
    
    if [ ! -f "$SSH_KEY_PATH" ]; then
        print_status "Generating SSH key pair for VM access..."
        ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N "" -C "healthcare-vm-key"
        print_success "SSH key pair generated at $SSH_KEY_PATH"
    else
        print_status "SSH key already exists at $SSH_KEY_PATH"
    fi
    
    # Read the public key
    SSH_PUBLIC_KEY=$(cat "${SSH_KEY_PATH}.pub")
    print_status "SSH public key: ${SSH_PUBLIC_KEY:0:50}..."
}

# Function to create resource group
create_resource_group() {
    print_status "Creating resource group: $RESOURCE_GROUP_NAME"
    
    if az group show --name "$RESOURCE_GROUP_NAME" &> /dev/null; then
        print_warning "Resource group $RESOURCE_GROUP_NAME already exists"
    else
        az group create \
            --name "$RESOURCE_GROUP_NAME" \
            --location "$LOCATION" \
            --output table
        print_success "Resource group created successfully"
    fi
}

# Function to deploy VM infrastructure
deploy_vm_infrastructure() {
    print_status "Deploying VM infrastructure..."
    
    # Update parameters file with SSH public key
    TEMP_PARAMS_FILE=$(mktemp)
    cat azure-templates/vm-parameters.json | \
        sed "s|YOUR_SSH_PUBLIC_KEY_HERE|$SSH_PUBLIC_KEY|g" > "$TEMP_PARAMS_FILE"
    
    # Deploy the ARM template
    az deployment group create \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$DEPLOYMENT_NAME" \
        --template-file azure-templates/vm-template.json \
        --parameters @"$TEMP_PARAMS_FILE" \
        --output table
    
    # Clean up temporary file
    rm "$TEMP_PARAMS_FILE"
    
    print_success "VM infrastructure deployed successfully"
}

# Function to get VM public IP
get_vm_public_ip() {
    print_status "Retrieving VM public IP address..."
    
    VM_PUBLIC_IP=$(az deployment group show \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$DEPLOYMENT_NAME" \
        --query 'properties.outputs.publicIPAddress.value' \
        --output tsv)
    
    VM_FQDN=$(az deployment group show \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$DEPLOYMENT_NAME" \
        --query 'properties.outputs.publicIPFQDN.value' \
        --output tsv)
    
    print_success "VM Public IP: $VM_PUBLIC_IP"
    print_success "VM FQDN: $VM_FQDN"
}

# Function to wait for VM to be ready
wait_for_vm() {
    print_status "Waiting for VM to be ready for SSH connections..."
    
    SSH_KEY_PATH="$HOME/.ssh/healthcare_vm_key"
    MAX_ATTEMPTS=30
    ATTEMPT=1
    
    while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
        if ssh -i "$SSH_KEY_PATH" -o ConnectTimeout=10 -o StrictHostKeyChecking=no \
           "$ADMIN_USERNAME@$VM_PUBLIC_IP" "echo 'VM is ready'" &> /dev/null; then
            print_success "VM is ready for SSH connections"
            return 0
        fi
        
        print_status "Attempt $ATTEMPT/$MAX_ATTEMPTS - VM not ready yet, waiting 30 seconds..."
        sleep 30
        ((ATTEMPT++))
    done
    
    print_error "VM did not become ready within the expected time"
    exit 1
}

# Function to deploy website to VM
deploy_website() {
    print_status "Deploying healthcare website to VM..."
    
    SSH_KEY_PATH="$HOME/.ssh/healthcare_vm_key"
    
    # Create deployment script
    cat > scripts/deploy-website.sh << 'EOF'
#!/bin/bash

# Website deployment script for VM
set -e

echo "Starting website deployment..."

# Create website directory
sudo mkdir -p /var/www/healthcare
sudo chown -R www-data:www-data /var/www/healthcare

# Copy website files (will be uploaded by rsync)
echo "Website files will be copied by rsync..."

# Configure Nginx
sudo tee /etc/nginx/sites-available/healthcare > /dev/null << 'NGINX_CONFIG'
server {
    listen 80;
    listen [::]:80;
    
    root /var/www/healthcare;
    index index.html index.htm;
    
    server_name _;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss;
    
    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
NGINX_CONFIG

# Enable the site
sudo ln -sf /etc/nginx/sites-available/healthcare /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

echo "Website deployment completed successfully!"
EOF

    # Make deployment script executable
    chmod +x scripts/deploy-website.sh
    
    # Upload website files and deployment script
    print_status "Uploading website files to VM..."
    rsync -avz -e "ssh -i $SSH_KEY_PATH -o StrictHostKeyChecking=no" \
        --exclude='.git' \
        --exclude='azure-templates' \
        --exclude='scripts' \
        --exclude='.github' \
        ./ "$ADMIN_USERNAME@$VM_PUBLIC_IP:/tmp/healthcare-website/"
    
    # Upload and run deployment script
    scp -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no \
        scripts/deploy-website.sh "$ADMIN_USERNAME@$VM_PUBLIC_IP:/tmp/"
    
    ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no \
        "$ADMIN_USERNAME@$VM_PUBLIC_IP" "chmod +x /tmp/deploy-website.sh && /tmp/deploy-website.sh"
    
    # Copy website files to web directory
    ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no \
        "$ADMIN_USERNAME@$VM_PUBLIC_IP" \
        "sudo cp -r /tmp/healthcare-website/* /var/www/healthcare/ && sudo chown -R www-data:www-data /var/www/healthcare"
    
    print_success "Healthcare website deployed successfully!"
}

# Function to display deployment summary
display_summary() {
    echo ""
    echo "=========================================="
    echo "    DEPLOYMENT COMPLETED SUCCESSFULLY"
    echo "=========================================="
    echo ""
    echo "Resource Group: $RESOURCE_GROUP_NAME"
    echo "VM Name: $VM_NAME"
    echo "VM Public IP: $VM_PUBLIC_IP"
    echo "VM FQDN: $VM_FQDN"
    echo ""
    echo "Website URLs:"
    echo "  - http://$VM_PUBLIC_IP"
    echo "  - http://$VM_FQDN"
    echo ""
    echo "SSH Access:"
    echo "  ssh -i ~/.ssh/healthcare_vm_key $ADMIN_USERNAME@$VM_PUBLIC_IP"
    echo ""
    echo "Next Steps:"
    echo "1. Visit your website at http://$VM_PUBLIC_IP"
    echo "2. Configure DNS if you have a custom domain"
    echo "3. Set up SSL certificate for HTTPS (optional)"
    echo "4. Configure monitoring and backups"
    echo ""
}

# Main execution
main() {
    echo "=========================================="
    echo "  Healthcare Website Azure VM Deployment"
    echo "=========================================="
    echo ""
    
    check_azure_cli
    check_azure_login
    generate_ssh_key
    create_resource_group
    deploy_vm_infrastructure
    get_vm_public_ip
    wait_for_vm
    deploy_website
    display_summary
}

# Run main function
main "$@"

