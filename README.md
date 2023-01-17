# nemo-arch
nvidia NeMo Terraform architecture and prebuilt image

Resulting AMI : https://us-west-2.console.aws.amazon.com/ec2/home?region=us-west-2#Images:visibility=public-images;search=dept-nemo

## Why create an AMI?
AWS machine images are called AMIs. You can use existing AMIs for general use cases. For example, a clean install of Ubuntu Linux. You can also create custom AMIs for private use or publish it for public use.
NVIDIA actually already has a NeMo AMI image available. I tried using it but I was getting dependency conflicts on certain libraries that I was trying to install. I also just like to understand how the underlying system is built when I'm working on something so I decided to build my own AMI.

## Includes
* NVIDIA GPU Drivers
* CUDA
* Python
* NeMo (NLP)