#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    color=$1
    message=$2
    echo -e "${color}${message}${NC}"
}

print_header() {
    echo ""
    print_color "$BLUE" "=========================================="
    print_color "$BLUE" "$1"
    print_color "$BLUE" "=========================================="
    echo ""
}

print_success() {
    print_color "$GREEN" "✓ $1"
}

print_error() {
    print_color "$RED" "✗ $1"
}

print_warning() {
    print_color "$YELLOW" "⚠ $1"
}

print_info() {
    print_color "$BLUE" "ℹ $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    local all_good=true
    
    # Check Terraform
    if command -v terraform &> /dev/null; then
        version=$(terraform version | head -n1)
        print_success "Terraform installed: $version"
    else
        print_error "Terraform not found. Please install Terraform >= 1.0"
        all_good=false
    fi
    
    # Check AWS CLI
    if command -v aws &> /dev/null; then
        version=$(aws --version)
        print_success "AWS CLI installed: $version"
        
        # Check AWS credentials
        if aws sts get-caller-identity &> /dev/null; then
            account_id=$(aws sts get-caller-identity --query Account --output text)
            print_success "AWS credentials configured (Account: $account_id)"
        else
            print_error "AWS credentials not configured. Run: aws configure"
            all_good=false
        fi
    else
        print_error "AWS CLI not found. Please install AWS CLI"
        all_good=false
    fi
    
    # Check for SSH key
    if [ -f "$HOME/.ssh/jenkins-cicd-key.pub" ]; then
        print_success "SSH key found at ~/.ssh/jenkins-cicd-key.pub"
    else
        print_warning "SSH key not found at ~/.ssh/jenkins-cicd-key.pub"
        print_info "Generate one with: ssh-keygen -t rsa -b 4096 -f ~/.ssh/jenkins-cicd-key"
    fi
    
    # Check for terraform.tfvars
    if [ -f "terraform.tfvars" ]; then
        print_success "terraform.tfvars file exists"
    else
        print_warning "terraform.tfvars not found. You need to create it from terraform.tfvars.example"
        all_good=false
    fi
    
    echo ""
    if [ "$all_good" = true ]; then
        print_success "All prerequisites met!"
        return 0
    else
        print_error "Some prerequisites are missing. Please fix the issues above."
        return 1
    fi
}

# Function to validate terraform.tfvars
validate_tfvars() {
    print_header "Validating Configuration"
    
    if [ ! -f "terraform.tfvars" ]; then
        print_error "terraform.tfvars not found"
        return 1
    fi
    
    local issues=0
    
    # Check for ssh_public_key
    if grep -q 'ssh_public_key.*=.*"ssh-rsa AAAAB3NzaC1yc2EA' terraform.tfvars; then
        print_warning "Please update ssh_public_key with your actual SSH public key"
        issues=$((issues + 1))
    fi
    
    # Check for security restrictions
    if grep -q 'allowed_ssh_cidr.*=.*\["0.0.0.0/0"\]' terraform.tfvars; then
        print_warning "SSH access is open to the world! Consider restricting to your IP"
    fi
    
    if grep -q 'allowed_jenkins_cidr.*=.*\["0.0.0.0/0"\]' terraform.tfvars; then
        print_warning "Jenkins access is open to the world! Consider restricting to your IP"
    fi
    
    # Check for Docker Hub credentials
    if grep -q 'docker_hub_username.*=.*"yourdockerhubusername"' terraform.tfvars; then
        print_warning "Please update docker_hub_username with your actual Docker Hub username"
        issues=$((issues + 1))
    fi
    
    if [ $issues -gt 0 ]; then
        print_error "Found $issues configuration issues that need attention"
        return 1
    else
        print_success "Configuration looks good!"
        return 0
    fi
}

# Function to estimate costs
show_cost_estimate() {
    print_header "Estimated Monthly AWS Costs"
    
    echo "Based on us-east-1 region pricing:"
    echo ""
    echo "  EC2 Instances:"
    echo "    • Jenkins (t3.medium):     ~\$30/month"
    echo "    • Staging (t3.micro):      ~\$7/month"
    echo "    • Production (t3.small):   ~\$15/month"
    echo ""
    echo "  Other Resources:"
    echo "    • Elastic IPs (3):         ~\$11/month"
    echo "    • EBS Storage (70 GB):     ~\$7/month"
    echo "    • Data Transfer:           ~\$5/month"
    echo ""
    echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  TOTAL ESTIMATED COST:       ~\$75/month"
    echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    print_info "Actual costs may vary based on usage and region"
    echo ""
}

# Function to deploy infrastructure
deploy_infrastructure() {
    print_header "Deploying Infrastructure"
    
    # Initialize Terraform
    print_info "Initializing Terraform..."
    if terraform init; then
        print_success "Terraform initialized"
    else
        print_error "Terraform initialization failed"
        return 1
    fi
    
    # Validate configuration
    print_info "Validating Terraform configuration..."
    if terraform validate; then
        print_success "Configuration is valid"
    else
        print_error "Configuration validation failed"
        return 1
    fi
    
    # Show plan
    print_info "Generating deployment plan..."
    terraform plan -out=tfplan
    
    echo ""
    print_warning "Review the plan above carefully!"
    echo ""
    read -p "Do you want to proceed with deployment? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_info "Deployment cancelled"
        rm -f tfplan
        return 1
    fi
    
    # Apply
    print_info "Deploying infrastructure... This will take 5-10 minutes"
    if terraform apply tfplan; then
        rm -f tfplan
        print_success "Infrastructure deployed successfully!"
        return 0
    else
        print_error "Deployment failed"
        rm -f tfplan
        return 1
    fi
}

# Function to show outputs
show_outputs() {
    print_header "Deployment Information"
    
    echo ""
    print_info "Retrieving infrastructure details..."
    echo ""
    
    # Save outputs to file
    terraform output -json > infrastructure-outputs.json
    print_success "Outputs saved to: infrastructure-outputs.json"
    echo ""
    
    # Display key information
    jenkins_url=$(terraform output -raw jenkins_url 2>/dev/null)
    jenkins_ip=$(terraform output -raw jenkins_public_ip 2>/dev/null)
    sonarqube_url=$(terraform output -raw sonarqube_url 2>/dev/null)
    staging_ip=$(terraform output -raw staging_public_ip 2>/dev/null)
    prod_ip=$(terraform output -raw production_public_ip 2>/dev/null)
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    print_color "$GREEN" "🚀 JENKINS SERVER"
    echo "   URL:       $jenkins_url"
    echo "   Public IP: $jenkins_ip"
    echo "   SSH:       ssh -i ~/.ssh/jenkins-cicd-key ec2-user@$jenkins_ip"
    echo ""
    print_color "$GREEN" "🔍 SONARQUBE"
    echo "   URL:       $sonarqube_url"
    echo "   Login:     admin / admin (change on first login)"
    echo ""
    print_color "$GREEN" "🧪 STAGING SERVER"
    echo "   Public IP: $staging_ip"
    echo "   App URL:   http://$staging_ip:3000"
    echo "   SSH:       ssh -i ~/.ssh/jenkins-cicd-key ec2-user@$staging_ip"
    echo ""
    print_color "$GREEN" "🚢 PRODUCTION SERVER"
    echo "   Public IP: $prod_ip"
    echo "   App URL:   http://$prod_ip:3000"
    echo "   SSH:       ssh -i ~/.ssh/jenkins-cicd-key ec2-user@$prod_ip"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    print_header "Next Steps"
    echo "1. Get Jenkins initial password:"
    echo "   ssh -i ~/.ssh/jenkins-cicd-key ec2-user@$jenkins_ip 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'"
    echo ""
    echo "2. Open Jenkins in browser: $jenkins_url"
    echo ""
    echo "3. Complete Jenkins setup wizard and install plugins"
    echo ""
    echo "4. Configure credentials in Jenkins (see QUICKSTART.md)"
    echo ""
    echo "5. Update Jenkinsfile with server IPs:"
    echo "   STAGING_SERVER_IP = \"$staging_ip\""
    echo "   PROD_SERVER_IP    = \"$prod_ip\""
    echo ""
    echo "6. Create Jenkins multibranch pipeline"
    echo ""
    print_info "See QUICKSTART.md for detailed post-deployment steps"
    echo ""
}

# Function to destroy infrastructure
destroy_infrastructure() {
    print_header "Destroying Infrastructure"
    
    print_warning "WARNING: This will permanently delete all resources!"
    print_warning "This action cannot be undone!"
    echo ""
    read -p "Are you absolutely sure? Type 'destroy' to confirm: " confirm
    
    if [ "$confirm" != "destroy" ]; then
        print_info "Destruction cancelled"
        return 1
    fi
    
    print_info "Destroying infrastructure..."
    if terraform destroy -auto-approve; then
        print_success "Infrastructure destroyed successfully"
        return 0
    else
        print_error "Destruction failed"
        return 1
    fi
}

# Main menu
show_menu() {
    echo ""
    print_header "Jenkins CI/CD Infrastructure Deployment"
    echo ""
    echo "1) Check Prerequisites"
    echo "2) Validate Configuration"
    echo "3) Show Cost Estimate"
    echo "4) Deploy Infrastructure"
    echo "5) Show Deployment Info"
    echo "6) Destroy Infrastructure"
    echo "7) Exit"
    echo ""
}

# Main script
main() {
    # Change to terraform directory if not already there
    if [ ! -f "main.tf" ]; then
        if [ -f "terraform/main.tf" ]; then
            cd terraform
        else
            print_error "Cannot find Terraform configuration files"
            exit 1
        fi
    fi
    
    # If arguments provided, execute directly
    case "$1" in
        check)
            check_prerequisites
            ;;
        validate)
            validate_tfvars
            ;;
        cost)
            show_cost_estimate
            ;;
        deploy)
            check_prerequisites && deploy_infrastructure && show_outputs
            ;;
        info)
            show_outputs
            ;;
        destroy)
            destroy_infrastructure
            ;;
        *)
            # Interactive mode
            while true; do
                show_menu
                read -p "Select option: " choice
                
                case $choice in
                    1)
                        check_prerequisites
                        ;;
                    2)
                        validate_tfvars
                        ;;
                    3)
                        show_cost_estimate
                        ;;
                    4)
                        if check_prerequisites && validate_tfvars; then
                            show_cost_estimate
                            echo ""
                            read -p "Continue with deployment? (yes/no): " confirm
                            if [ "$confirm" = "yes" ]; then
                                deploy_infrastructure && show_outputs
                            fi
                        fi
                        ;;
                    5)
                        show_outputs
                        ;;
                    6)
                        destroy_infrastructure
                        ;;
                    7)
                        print_info "Goodbye!"
                        exit 0
                        ;;
                    *)
                        print_error "Invalid option"
                        ;;
                esac
                
                echo ""
                read -p "Press Enter to continue..."
            done
            ;;
    esac
}

# Run main
main "$@"
