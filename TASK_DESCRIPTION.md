# AZ-900 Certification Task: Healthcare Website Deployment on Azure VM

## Task Overview

**Objective:** Deploy a healthcare clinic website to an Azure Virtual Machine using GitHub Actions for automated CI/CD deployment.

**Duration:** 2-3 hours

**Difficulty Level:** Intermediate

**Azure Services Used:**
- Azure Virtual Machines (IaaS)
- Azure Virtual Networks
- Network Security Groups
- Public IP Addresses
- Azure Resource Manager (ARM) Templates

**DevOps Tools:**
- GitHub Actions
- SSH
- Nginx Web Server
- Linux (Ubuntu)

## Scenario Description

You are a cloud engineer working for HealthCare Plus, a medical clinic that needs to establish an online presence. The clinic requires a professional website that showcases their services, provides information about their medical team, and allows patients to contact them for appointments.

The clinic's IT requirements are:
1. **Reliability:** The website must be hosted on a robust cloud infrastructure
2. **Scalability:** The solution should be able to handle increased traffic
3. **Automation:** Deployments should be automated to reduce manual errors
4. **Security:** The infrastructure must follow security best practices
5. **Cost-Effectiveness:** The solution should be cost-optimized for a small clinic

Your task is to deploy this website using Azure Virtual Machines and implement a CI/CD pipeline using GitHub Actions.

## Learning Outcomes

Upon completion of this task, you will have demonstrated proficiency in:

### Azure Fundamentals (AZ-900 Aligned)
- **Cloud Concepts:** Understanding IaaS vs PaaS deployment models
- **Core Azure Services:** Working with VMs, VNets, NSGs, and Public IPs
- **Azure Pricing:** Understanding cost implications of different VM sizes
- **Security:** Implementing network security and access controls
- **Management Tools:** Using Azure CLI and ARM templates

### DevOps and Automation
- **Infrastructure as Code:** Using ARM templates for resource provisioning
- **CI/CD Pipelines:** Implementing automated deployment with GitHub Actions
- **Configuration Management:** Setting up and configuring web servers
- **Version Control:** Managing code and infrastructure configurations

### Practical Skills
- **Linux Administration:** Basic Ubuntu server management
- **Web Server Configuration:** Setting up and configuring Nginx
- **SSH Key Management:** Secure remote access to cloud resources
- **Troubleshooting:** Diagnosing and resolving deployment issues

## Task Components

### 1. Website Application
- **Technology Stack:** HTML5, CSS3, JavaScript (Static Website)
- **Pages:** Home, Services, Contact
- **Features:** Responsive design, professional healthcare theme
- **Assets:** High-quality medical images, optimized for web

### 2. Azure Infrastructure
- **Virtual Machine:** Ubuntu 20.04 LTS (Standard_B2s)
- **Virtual Network:** Isolated network environment (10.0.0.0/16)
- **Network Security Group:** Configured for HTTP, HTTPS, and SSH access
- **Public IP:** Static IP with DNS name label
- **Storage:** Premium SSD for OS disk

### 3. Deployment Automation
- **ARM Templates:** Infrastructure as Code for reproducible deployments
- **GitHub Actions:** Two workflows for infrastructure and application deployment
- **SSH Automation:** Secure file transfer and remote command execution
- **Nginx Configuration:** Automated web server setup and optimization

## Implementation Phases

### Phase 1: Infrastructure Setup (45 minutes)
1. **Azure CLI Configuration**
   - Install and configure Azure CLI
   - Authenticate with Azure subscription
   - Verify permissions and quotas

2. **SSH Key Generation**
   - Generate RSA key pair for VM access
   - Configure proper file permissions
   - Understand public/private key concepts

3. **Resource Provisioning**
   - Deploy ARM template using provided script
   - Create resource group and all required resources
   - Verify successful deployment

### Phase 2: Application Deployment (30 minutes)
1. **Initial Website Setup**
   - Deploy website files to VM
   - Configure Nginx web server
   - Test website accessibility

2. **Security Configuration**
   - Configure firewall rules
   - Implement security headers
   - Enable gzip compression

### Phase 3: CI/CD Pipeline Setup (60 minutes)
1. **GitHub Repository Setup**
   - Create repository and push code
   - Understand repository structure
   - Configure branch protection (optional)

2. **Service Principal Creation**
   - Create Azure service principal
   - Assign appropriate permissions
   - Understand role-based access control

3. **GitHub Secrets Configuration**
   - Configure Azure credentials
   - Set up SSH private key
   - Store VM connection details

4. **Workflow Testing**
   - Trigger manual deployment
   - Test automated deployment on code changes
   - Verify deployment success

### Phase 4: Testing and Validation (30 minutes)
1. **Functionality Testing**
   - Verify all website pages load correctly
   - Test responsive design on different devices
   - Validate form functionality

2. **Performance Testing**
   - Check website load times
   - Verify gzip compression
   - Test from different geographic locations

3. **Security Validation**
   - Verify HTTPS redirect (if configured)
   - Check security headers
   - Validate firewall rules

## Assessment Criteria

### Technical Implementation (70%)
- **Infrastructure Deployment:** Successful creation of all Azure resources
- **Website Functionality:** All pages accessible and properly styled
- **CI/CD Pipeline:** Automated deployment working correctly
- **Security Configuration:** Proper implementation of security measures

### Documentation and Understanding (20%)
- **Process Documentation:** Clear understanding of deployment steps
- **Troubleshooting:** Ability to diagnose and resolve issues
- **Best Practices:** Following Azure and DevOps best practices

### Innovation and Optimization (10%)
- **Performance Optimization:** Implementation of caching and compression
- **Cost Optimization:** Appropriate resource sizing
- **Additional Features:** Any enhancements beyond basic requirements

## Deliverables

### Required Deliverables
1. **Functional Website:** Accessible via public IP address
2. **GitHub Repository:** Complete source code and workflows
3. **Documentation:** README with setup instructions
4. **Deployment Evidence:** Screenshots or logs of successful deployment

### Optional Deliverables
1. **Custom Domain:** Configure custom domain name
2. **SSL Certificate:** Implement HTTPS with Let's Encrypt
3. **Monitoring:** Set up basic monitoring and alerting
4. **Backup Strategy:** Document backup and recovery procedures

## Extensions and Advanced Scenarios

### For Advanced Learners
1. **High Availability:** Deploy across multiple VMs with load balancer
2. **Auto Scaling:** Implement VM scale sets
3. **Database Integration:** Add backend database for dynamic content
4. **Container Deployment:** Containerize the application with Docker

### Alternative Implementations
1. **Azure Web Apps:** Compare with PaaS deployment
2. **Static Web Apps:** Use Azure Static Web Apps service
3. **CDN Integration:** Add Azure CDN for global content delivery
4. **ARM Templates:** Convert to Bicep templates

## Cost Considerations

### Estimated Monthly Costs (East US region)
- **Standard_B2s VM:** ~$30-40/month
- **Premium SSD (30GB):** ~$5/month
- **Public IP (Static):** ~$3/month
- **Bandwidth:** ~$5-10/month (depending on traffic)
- **Total Estimated Cost:** ~$45-60/month

### Cost Optimization Tips
1. **VM Sizing:** Start with smaller VM and scale up if needed
2. **Auto-shutdown:** Configure VM to shut down during off-hours
3. **Reserved Instances:** Consider reserved pricing for long-term deployments
4. **Monitoring:** Use Azure Cost Management to track spending

## Real-World Applications

This task simulates real-world scenarios where organizations need to:
- **Migrate Legacy Applications:** Moving from on-premises to cloud
- **Implement DevOps:** Establishing CI/CD pipelines for faster deployments
- **Ensure Compliance:** Meeting healthcare industry security requirements
- **Manage Costs:** Balancing performance with budget constraints
- **Scale Operations:** Preparing for business growth and increased demand

## Next Steps and Career Development

### Immediate Next Steps
1. **Explore Azure Web Apps:** Compare IaaS vs PaaS approaches
2. **Implement Monitoring:** Add Azure Monitor and Application Insights
3. **Security Hardening:** Implement additional security measures
4. **Performance Optimization:** Add CDN and caching strategies

### Career Development Paths
1. **Azure Administrator (AZ-104):** Focus on Azure administration and management
2. **Azure Developer (AZ-204):** Develop cloud applications and services
3. **DevOps Engineer (AZ-400):** Implement DevOps practices and tools
4. **Azure Solutions Architect (AZ-305):** Design comprehensive Azure solutions

This task provides a solid foundation for understanding cloud infrastructure, automation, and modern deployment practices that are essential in today's technology landscape.

