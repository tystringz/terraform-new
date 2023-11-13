# pso-azure-theValleyHospital-927453

This project is based on Transit VNET Common firewall model. A standard public LB placed for the inbound traffic and an internal LB for the egress traffic.

* `brownfield` folder contains a mock code to create RGs and a VNET that will be already available in the customer's env.
* `deployment/vmseries` folder contains a greenfield deployment.

Steps to deploy in a lab:

```bash
cd brownfield
terraform init
terraform apply -var-file ../deployment/vmseries/terraform.tfvars

cd - ; cd deployment/vmseries
terraform init
terraform apply
```
