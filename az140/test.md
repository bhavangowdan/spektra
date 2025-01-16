# Task: Connect Wiz to AWS

---

## Overview

In this lab you will setup a vulnerable AWS environment and then connect it to Wiz.

## Exercise 1. Setup a Vulnerable Environment on AWS

In this lab, you will deploy an intentionally vulnerable infrastructure in AWS, including:

- Ubuntu 18.04
  - Apache 2.4.29
  - libssl 1.0.2
  - libcurl3
- S3 bucket that is globally readable

### Tasks

1. Open your AWS console and copy the link below to create a new CloudFormation stack.

    <aside class="note">This lab uses <b>us-east-1</b> as the default region for deploying resources.</aside>

    <inject value="https://us-east-1.console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?stackName=" key="ODLUser" value="&templateURL=https://wizlabs-cl.s3.amazonaws.com/labs/wte/module3/vuln-vm.json" enableCopy="true" />

1. Scroll down and check the option **I acknowledge that AWS CloudFormation might create IAM resources with custom names.**

1. Click on **Create stack**.

1. After the stack is deployed, to validate that the EC2 instance is running. At the top of the AWS Management Console, in the search bar, search for and click <inject value="EC2" enableCopy="true" />.

1. In the navigation pane at the left of the page, click **Instances**.

1. Select the **MyVM** instance, copy the Public IP, and open it in a new tab (http://IPAddress). If you get the Apache Welcome page, the VM is deployed correctly

    <aside class="important">Do not use https:// to verify this step -- we are using an insecure environment.</aside>

1. Now go to **Services > S3**, select your bucket: <inject value="my-public-bucket-ACCOUNT_NUMBER-REGION" enableCopy="false" />

1. Go to the **Permissions** tab, and check if the Block all public access is **Off**.

1. You should be done with setting up with AWS infrastructure, proceed to the next lab.

---

## Exercise 2. Deploying Wiz AWS Connector

In this lab, connect Wiz to your AWS environment by using CloudFormation to grant Wiz read-only (configuration and snapshots) access. 

### Deployment

There are 3 major steps into deploying the Wiz AWS Connector:

- **Step 1:** Add an AWS Connector in Wiz
- **Step 2:** Create the Wiz Role in AWS
- **Step 3:** Finish defining the Connector in Wiz

We will go over all of the major steps and its substeps in the below section.

### Tasks

1. In Wiz, navigate to the Settings > Deployments page.

1. At the top right, click **Add Deployment**.

1. Select **Amazon Web Services (AWS)**.

1. For **Connector Scope**, select **Account**.

1. For **Installation Type**, leave **Standard** selected.

1. For **Deployment Method**, select **CloudFormation**.

1. If you haven't done so yet, in a different browser tab, log in to the lab's AWS account.

1. Change the Amazon region in the upper right corner to and switch to **N. Virginia (us-east-1)**.

1. Back to the Wiz tab, click Launch CloudFormation Stack. The AWS console opens in a new tab with the necessary details pre-populated.

    <p align="left">
    <img style="width:750px" img src="images/awsconn.png"/>
      </p>

1. On the Quick create stack page:

    - In the Parameters section, change the DataScanning option to Enabled.
    - Tick the checkbox under Capabilities: I acknowledge that AWS CloudFormation might create IAM resources. This is required to create the service account for Wiz.
    - Click Create stack.
    - After the stack creation completes, copy the Wiz-Access Role ARN from the Outputs tab to a local file for use below. 

1. Return to the Connect to Amazon Web Services (AWS) page in Wiz.

1. For **Wiz Role ARN**, paste the ARN you copied from the output of CloudFormation.

1. Click **Continue**.

1. On the Details page:
    - Connector name: <inject key="ODLUser" value="-aws-connector" enableCopy="false" />
    - Leave everything else as-is.

1. Click **Finish**. Wiz will initialize the AWS scanner and run the assessment.

1. You should see your Deployment in _Initializing_ status.
