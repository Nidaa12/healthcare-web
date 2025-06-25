# AZ-900 Certification Lab: Deploying a Healthcare Website to an Azure VM with GitHub Actions

**Author:** Manus AI  
**Date:** June 21, 2025  

## 1. Introduction

This lab provides a hands-on experience with deploying a static website to an Azure Virtual Machine (VM) using a CI/CD pipeline powered by GitHub Actions. It is designed to align with the learning objectives of the AZ-900 Microsoft Azure Fundamentals certification, focusing on core concepts such as Infrastructure as a Service (IaaS), resource management, and automated deployments.

### 1.1. Lab Scenario

As a cloud engineer for a healthcare provider, you are tasked with deploying a new public-facing website. The website is a static HTML, CSS, and JavaScript application that provides information about the clinic's services, doctors, and contact details. To ensure reliability and scalability, the website will be hosted on a Linux-based Azure Virtual Machine. To streamline the development and deployment process, you will implement a CI/CD pipeline using GitHub Actions to automate the deployment of the website whenever changes are pushed to the main branch of the GitHub repository.

### 1.2. Learning Objectives

Upon completing this lab, you will be able to:

*   **Provision Azure Resources:** Understand and use Azure Resource Manager (ARM) templates to provision a complete set of infrastructure resources, including a Virtual Machine, Virtual Network, Network Security Group, and Public IP address.
*   **Configure a Virtual Machine:** Perform basic configuration of a Linux VM, including installing and configuring a web server (Nginx).
*   **Implement CI/CD with GitHub Actions:** Create a GitHub Actions workflow to automate the deployment of a web application to an Azure VM.
*   **Manage Security and Credentials:** Use GitHub Secrets to securely store and manage sensitive information, such as Azure credentials and SSH keys.
*   **Understand IaaS vs. PaaS:** Gain practical experience with the Infrastructure as a Service (IaaS) model by managing a VM, and contrast this with the Platform as a Service (PaaS) model (e.g., Azure Web Apps).

### 1.3. Prerequisites

To successfully complete this lab, you will need the following:

*   **Azure Subscription:** An active Azure subscription. If you don't have one, you can create a [free account](https://azure.microsoft.com/en-us/free/).
*   **GitHub Account:** A GitHub account. If you don't have one, you can create one for free at [github.com](https://github.com/).
*   **Azure CLI:** The Azure Command-Line Interface (CLI) installed on your local machine. You can find installation instructions [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
*   **Git:** Git installed on your local machine. You can download it from [git-scm.com](https://git-scm.com/).
*   **VS Code (Optional):** Visual Studio Code or any other code editor for reviewing the website and configuration files.

## 2. Solution Architecture

This lab utilizes a straightforward yet powerful architecture that combines several key Azure services and DevOps practices:

*   **Azure Virtual Machine (VM):** A Linux-based VM (Ubuntu Server) serves as the web server, hosting the static website content. This represents the IaaS component of the solution.
*   **Azure Virtual Network (VNet):** The VM is deployed within a VNet, providing a secure and isolated network environment.
*   **Network Security Group (NSG):** An NSG is used to control inbound and outbound traffic to the VM, allowing only necessary ports (SSH, HTTP, HTTPS).
*   **Public IP Address:** A static public IP address is assigned to the VM, making the website accessible from the internet.
*   **GitHub:** The source code for the website and the GitHub Actions workflow are stored in a GitHub repository.
*   **GitHub Actions:** A CI/CD pipeline automates the deployment process. When code is pushed to the `main` branch, the workflow is triggered, which then securely connects to the Azure VM and updates the website content.
*   **Nginx:** A lightweight and high-performance web server installed on the VM to serve the static website files.

### 2.1. Architectural Diagram

```mermaid
graph TD
    subgraph GitHub
        A[GitHub Repository] --> B{GitHub Actions}
    end

    subgraph Azure
        subgraph "Resource Group: healthcare-rg"
            C[Azure VM (Ubuntu + Nginx)]
            D[Virtual Network]
            E[Network Security Group]
            F[Public IP Address]
        end
    end

    B -- Deploy --> C
    G[User] --> H((Internet))
    H --> F
    F --> C

    style A fill:#f9f9f9,stroke:#333,stroke-width:2px
    style B fill:#f9f9f9,stroke:#333,stroke-width:2px
    style C fill:#f9f9f9,stroke:#333,stroke-width:2px
    style D fill:#f9f9f9,stroke:#333,stroke-width:2px
    style E fill:#f9f9f9,stroke:#333,stroke-width:2px
    style F fill:#f9f9f9,stroke:#333,stroke-width:2px
    style G fill:#f9f9f9,stroke:#333,stroke-width:2px
    style H fill:#f9f9f9,stroke:#333,stroke-width:2px
```

## 3. Step-by-Step Implementation Guide

This section provides a detailed walkthrough of the steps required to complete the lab. It is divided into three main parts: infrastructure provisioning, GitHub repository setup, and CI/CD configuration.

### 3.1. Part 1: Provisioning the Azure Infrastructure

In this part, you will use the Azure CLI and the provided ARM template to create the necessary Azure resources.

#### Step 1: Log in to Azure

Open your terminal or command prompt and log in to your Azure account:

```bash
az login
```

Follow the on-screen instructions to complete the login process.

#### Step 2: Generate SSH Key Pair

To securely connect to the Azure VM, you will use an SSH key pair. The provided deployment script (`scripts/deploy.sh`) will automatically generate a new SSH key pair for you if one doesn't already exist at `~/.ssh/healthcare_vm_key`.

Alternatively, you can generate one manually:

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/healthcare_vm_key -N "" -C "healthcare-vm-key"
```

This will create a private key (`~/.ssh/healthcare_vm_key`) and a public key (`~/.ssh/healthcare_vm_key.pub`).

#### Step 3: Run the Deployment Script

The `scripts/deploy.sh` script automates the creation of the resource group and the deployment of the VM infrastructure using the ARM template. It also performs some initial configuration on the VM.

Navigate to the root of the `healthcare-website` directory and run the script:

```bash
cd healthcare-website
./scripts/deploy.sh
```

The script will perform the following actions:

1.  **Check for Azure CLI and login status.**
2.  **Generate an SSH key pair** (if needed).
3.  **Create a resource group** named `healthcare-rg`.
4.  **Deploy the ARM template** (`azure-templates/vm-template.json`) to create the VNet, NSG, Public IP, and VM.
5.  **Install Nginx** on the VM using a custom script extension.
6.  **Wait for the VM to be ready** for SSH connections.
7.  **Deploy the initial website content** to the VM.
8.  **Display a summary** of the deployed resources, including the VM's public IP address.

At the end of the script execution, you will have a fully functional Azure VM hosting the healthcare website.

### 3.2. Part 2: Setting Up the GitHub Repository

Now that the infrastructure is in place, you need to set up a GitHub repository to host the website code and the GitHub Actions workflow.

#### Step 1: Create a New GitHub Repository

1.  Go to [github.com](https://github.com/) and create a new repository. You can name it `healthcare-website` or something similar.
2.  Initialize the repository with a README file.

#### Step 2: Push the Code to the Repository

1.  Clone the newly created repository to your local machine.
2.  Copy all the files from the `healthcare-website` directory (the one you've been working in) to your cloned repository.
3.  Commit and push the changes to the `main` branch:

    ```bash
    git add .
    git commit -m "Initial commit of healthcare website and deployment files"
    git push origin main
    ```

### 3.3. Part 3: Configuring the GitHub Actions CI/CD Pipeline

In this final part, you will configure the GitHub Actions workflow to automate the deployment of the website to your Azure VM.

#### Step 1: Create a Service Principal for Azure

To allow GitHub Actions to securely connect to your Azure subscription, you need to create a service principal. A service principal is an identity created for use with applications, hosted services, and automated tools to access Azure resources.

Run the following command in your terminal:

```bash
az ad sp create-for-rbac --name "healthcare-website-deploy" --role contributor --scopes /subscriptions/{your-subscription-id}/resourceGroups/healthcare-rg --sdk-auth
```

Replace `{your-subscription-id}` with your actual Azure subscription ID.

The command will output a JSON object containing the service principal's credentials. **Copy this entire JSON object to your clipboard.**

#### Step 2: Configure GitHub Secrets

GitHub Secrets are used to store sensitive information in your repository, such as credentials and keys. You will create the following secrets in your GitHub repository:

1.  Go to your GitHub repository and click on `Settings` > `Secrets and variables` > `Actions`.
2.  Click `New repository secret` to add the following secrets:

    *   **`AZURE_CREDENTIALS`**: Paste the entire JSON object you copied in the previous step as the value for this secret.
    *   **`VM_SSH_PRIVATE_KEY`**: Paste the content of your private SSH key (`~/.ssh/healthcare_vm_key`) as the value for this secret. You can get the content by running `cat ~/.ssh/healthcare_vm_key` in your terminal.
    *   **`VM_PUBLIC_IP`**: Paste the public IP address of your Azure VM (you can get this from the output of the `deploy.sh` script or from the Azure portal) as the value for this secret.

#### Step 3: Understand the GitHub Actions Workflows

This project includes two GitHub Actions workflows:

1.  **`provision-infrastructure.yml`**: This workflow is for manually provisioning the Azure infrastructure. It is triggered by a `workflow_dispatch` event, meaning you have to run it manually from the GitHub Actions tab. It's useful for setting up the initial environment.
2.  **`deploy.yml`**: This is the main CI/CD workflow. It is triggered automatically whenever you push changes to the `main` branch. It connects to the Azure VM and deploys the latest version of the website.

#### Step 4: Trigger the Deployment

Now that everything is configured, you can trigger a deployment by making a small change to the website code and pushing it to the `main` branch.

1.  Open `healthcare-website/index.html` in your code editor.
2.  Make a small change, for example, change the text in the `<h1>` tag.
3.  Commit and push the change:

    ```bash
    git add .
    git commit -m "Test deployment from GitHub Actions"
    git push origin main
    ```

4.  Go to the `Actions` tab in your GitHub repository. You should see the `Deploy Healthcare Website to Azure VM` workflow running.
5.  Click on the workflow to see the logs in real-time. If everything is configured correctly, the workflow will complete successfully, and your website will be updated on the Azure VM.

### 3.4. Verification

To verify that the deployment was successful, open your web browser and navigate to the public IP address of your Azure VM (`http://<your-vm-public-ip>`). You should see the updated version of the healthcare website.

## 4. Understanding the Code and Configuration

This section provides a brief overview of the key files in this project.

### 4.1. Website Files (`index.html`, `services.html`, `contact.html`, `assets/`)

These files constitute the static website. They are standard HTML, CSS, and JavaScript files that can be served by any web server.

### 4.2. ARM Template (`azure-templates/vm-template.json`)

This is a declarative JSON file that defines the Azure resources to be deployed. It specifies the properties of the VNet, NSG, Public IP, and VM.

### 4.3. Deployment Script (`scripts/deploy.sh`)

This shell script automates the process of provisioning the Azure infrastructure. It uses the Azure CLI to create the resource group and deploy the ARM template.

### 4.4. GitHub Actions Workflows (`.github/workflows/`)

*   **`provision-infrastructure.yml`**: Defines the workflow for provisioning the Azure infrastructure. It uses the `azure/login` action to authenticate with Azure and the `azure/arm-deploy` action to deploy the ARM template.
*   **`deploy.yml`**: Defines the CI/CD workflow for deploying the website. It uses the `appleboy/ssh-action` to connect to the VM and run commands to update the website content.

## 5. Conclusion

Congratulations! You have successfully deployed a static website to an Azure Virtual Machine using a fully automated CI/CD pipeline with GitHub Actions. You have gained practical experience with key Azure services and DevOps practices, which are essential skills for any cloud engineer.

### 5.1. Next Steps and Further Learning

*   **Custom Domain and SSL:** Configure a custom domain for your website and enable HTTPS using a free SSL certificate from Let's Encrypt.
*   **Monitoring and Logging:** Explore Azure Monitor to set up monitoring and logging for your VM to track performance and diagnose issues.
*   **High Availability:** Learn how to deploy your website across multiple VMs in an availability set or availability zone for high availability.
*   **PaaS vs. IaaS:** Compare this IaaS deployment with a PaaS deployment using Azure Web Apps. Try deploying the same website to an Azure Web App to understand the differences.

## 6. References

*   [Azure Virtual Machines documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/)
*   [Azure Resource Manager documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/)
*   [GitHub Actions documentation](https://docs.github.com/en/actions)
*   [Azure CLI documentation](https://docs.microsoft.com/en-us/cli/azure/)


