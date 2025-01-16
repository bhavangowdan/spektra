 Task: Verify and Analyze your Cloud Environment

---

## Overview

In this lab we will look into findings and discoveries made by the Workload Scanner triggered by the deployment of the Wiz Cloud connectors (AWS, Azure, OCI, GCP). More specifically, we will look into resources discovered, its technologies, vulnerabilities, and network insights.

---

<aside class="time">If you have just finished the Wiz OCI Connector deployment, you may have to wait until resources are fetched and ingested into the Graph. (approximately 30min)</aside>

---

## Exercise 1. Seek & Find

Once the Cloud connector is deployed, Wiz begins to scan the environment using its agentless read-only APIs approach. With that, if during the Cloud scan the connector finds VMs, Functions, and Containers, it will trigger a workload scan for further analysis.
In this lab we will navigate through the scan findings, its details, how to analyze and address issues identified by the workload scanner.

### Time Requirements

This lab is expected to take approximately 20-30 minutes.

### Instructions

1. In Wiz, navigate to **Settings > Deployments**.

1. Find your Cloud connector on the list, or use the Search by name field

   <p align="left">
      <img style="width:780px;" img src="images/settings-deployments.png"/>
      </p>

1. Here you can already see some information about your Cloud connector:

    - Health Issues: usually tied to permission errors in the Cloud account. Some are informational and don't affect the connector operations, but some (High/Critical) may prevent the connector to work properly. 
    - Status: Active/Inactive
    - Source: Cloud account (AWS Account, Azure Subscription, OCI, GCP Project, etc)
    - Last Activity: last time the Cloud account was scanned

1. Click on the connector to expand the details

   <p align="left">
      <img style="width:580px;" img src="images/connector-details.png"/>
      </p>    

    - The **Details** show more information about the connector including its ID, creation date, Cloud Subscription details, and the Wiz Managed Identity used to make the API calls.

1. Still in the Details tab of your connector, and click on Subscriptions

1. The portal will show all of the Subscriptions attached to the connector

   <p align="left">
      <img style="width:780px;" img src="images/subs.png"/>
      </p>

    <aside class="tip">It can take some time for all aspects of the connector findings to populate through the Wiz UI. If you do not see your subscription listed at this point, expand the following *Manual query to locate your subscription* section for a direct link to a Security Graph query to locate it.</aside>

   <details>
   <summary>Manual query to locate your subscription</summary>

   To manually locate your subscription on the Security Graph, copy the following URL and paste it into the web browser tab where you are viewing the Wiz console.

   <div style="margin-right: 150px;">

   ```plain
   https://app.wiz.io/explorer/graph#%7E%28view%7E%27table%7Equery%7E%28type%7E%28%7E%27SUBSCRIPTION%29%7Eselect%7Etrue%7Ewhere%7E%28subscriptionId%7E%28CONTAINS%7E%28%7E%27<inject key="SubscriptionId" enableCopy="false" />%29%29%29%29%29
   ```

   </div>

   </details>

1. Click on your Subscription to open the details drawer, navigate through its details. Here you can begin to see the power of Wiz, where in a matter of minutes, you have visibility into your Cloud environment.

    ---

    **Details**

   <p align="left">
      <img style="width:780px; height:495px; border:black; border-width:1px; border-style:solid;" img src="images/acct-details.png"/>
      </p>

   ---

    **Issues**

   <p align="left">
      <img style="width:780px; height:402px; border:black; border-width:1px; border-style:solid;" img src="images/acct-issues.png"/>
      </p>

   ---

    **Configuration**

   <p align="left">
      <img style="width:780px; height:402px; border:black; border-width:1px; border-style:solid;" img src="images/acct-config.png"/>
      </p>

   ---

1. Close the Subscription details drawer. In the Resources column, click on the **"view virtual machines on the graph"** link.

   <p align="left">
      <img style="width:194px;" img src="images/vmlink.png"/>
      </p>  

    <aside class="tip">If you do not see your subscription on the **Subscriptions** page and you used the previous manual link to locate your subscription on the Security Graph, expand the following *Manual query to locate your VM* section for a direct link to a Security Graph query to locate the VM for the following steps.</aside>

   <details>
   <summary>Manual query to locate your VM</summary>

   <div style="margin-right: 150px;">

   To manually locate all virtual machines in your subscription on the Security Graph, copy the following URL and paste it into the web browser tab where you are viewing the Wiz console.

   ```plain
   https://app.wiz.io/explorer/graph#%7E%28view%7E%27table%7Equery%7E%28type%7E%28%7E%27VIRTUAL_MACHINE%29%7Eselect%7Etrue%7Erelationships%7E%28%7E%28type%7E%28%7E%28type%7E%27CONTAINS%7Ereverse%7Etrue%29%29%7Ewith%7E%28type%7E%28%7E%27SUBSCRIPTION%29%7Eselect%7Etrue%7Ewhere%7E%28subscriptionId%7E%28CONTAINS%7E%28%7E%27<inject key="SubscriptionId" enableCopy="false" />%29%29%29%29%29%29%29%7Ecolumns%7E%28%7E%28%7E%270%7E35%29%7E%28%7E%270cloudPlatform%7E16%29%7E%28%7E%270status%7E16%29%7E%28%7E%271%7E24%29%7E%28%7E%271subscriptionId%7E14%29%7E%28%7E%271cloudPlatform%7E14%29%29%29
   ```

   </div>

1. Note that this graph query is tailored to your environment, using the Virtual Machine as the root object, filtering by an specific Subscription ID (in this case an AWS Account).

   <p align="left">
      <img style="width:780px;" img src="images/vmquery.png"/>
      </p>  

1. Click on MyVM to open the details drawer. In the Overview tab, you begin to see all the information collected by the Cloud Connector scanner, workload scanner, plus the Wiz enrichments.

   <p align="left">
      <img style="width:780px;" img src="images/vm-overview.png"/>
      </p>  

1. Scroll down to the **Technologies** section and click on **Linux Ubuntu**

1. Here we see Linux Ubuntu as a **Hosted Technology** and all of the information collected by the workload scanner.

1. Click on the Vulnerability tab, and see that the Hosted Technology's version, which happens to be MYVM's Operating System, is End-of-Life.

   <p align="left">
      <img style="width:780px;" img src="images/ht.png"/>
      </p>  

1. You can further investigate by clicking on the Finding (End-of-Life Linux Ubuntu 18.04.6).

   <p align="left">
      <img style="width:780px;" img src="images/ht-finding.png"/>
      </p> 

1. Go back to the VM's detail drawer and browse other details. Try to find:
    - the workload scan results;
    - all technologies installed in the VM;
    - network exposure paths;
    - VM's data inventory

## Troubleshooting Your Connector

<aside class="tip">Since this is a fresh deployment, your connector should not have any health issues. If you see errors, refer to [Troubleshooting Your Connector](#troubleshooting-your-connector) for guidance on resolving them.</aside>

   <p align="left">
      <img style="width:680px;" img src="images/connector-healthissues.png"/>
      </p> 

- The **Health Issues** tab shows the list of issues, severities, and total count.
- Some factors that lead to issues include:
  - SCP policies in AWS: strict policies disallowing API calls needed for the connector;
  - Outdated Wiz Role: as Wiz adds the ability to scan news services, existing Cloud roles, service accounts, service principal permissions need to be updated accordingly;
  - Resource-based policies: AWS KMS Vault, S3 Buckets, Azure Key Vaults, are a good example of it.
- If you have any issues listed, click in one of them and examine the details.

   <p align="left">
      <img style="width:640px;" img src="images/issue-detail1.png"/>
      </p>

   <p align="left">
      <img style="width:640px;" img src="images/issue-detail2.png"/>
      </p>

- The issue details will always have a description, along with severity, status, and region impacted. It will also have a Remediation section where you can see possible causes and initiate your troubleshooting.
