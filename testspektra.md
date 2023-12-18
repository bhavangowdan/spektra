   <div style="margin-right: 50px; margin-left: 30px;">

# Task: Vulnerability and Network Exposure Queries
---

## Overview
In this lab, you will:
- Gain hands on experience with the  **Explorer > Security Graph** page to find specific information.
- Learn to filter on vulnerability and network exposure findings.
- Learn to answer interesting questions about your resources related to these concepts.

## Exercise 1. Asking Queries of the Graph

We start with some inventory questions that can only be answered using the Security graph. From there, we layer in resource exposure, such as what is reachable from the internet. 

A solid understanding of the basic query structure, properties, and clauses helps realize extra value from Wiz. The objective of these questions is to illustrate that you can answer many customer questions using the graph and build a solid foundation for you to continue your learning. It also touches on optimizing queries, a good practice to learn from the start. 

Let's get to querying! 

### Overview 
You need to find key data that addresses specific questions. The Explorer > Security Graph page can surface highly correlated, normalized context. Use the page to find the following information. The answers should be in the form of condition and filter settings, though order of these can vary. There are multiple ways to address many of these questions.  This exercise is to give you a chance to move around the interface and accomplish specific goals. The Security Graph has many hidden secrets. We'll reveal some all in due time!

Review each task and navigate to the answer in the Wiz portal. Because the cloud is dynamic and new findings are inevitable, answers should not be "specific." Instead, they should be in the form  of navigation **Condition + Property filter(s) + narrowing condition + property filter(s) + etc.** (if helpful).  You may use any accelerators or tips to initiate your queries.

**Note:** Many paths to a right answer exist. If you find a different answer, raise it up during the session review and let's unpack it.  

### Tasks

- Find all VMs hosting a technology that has a vulnerability finding.

    1. On the Explorer > Security Graph page, click **Cloud Resource** in the root Select clause, and add **Virtual Machine**. 
    1. Click the **+** (Add filter) or type **F**, and select **Hosted Technology** that runs on it. 
        
        This result identifies all VMs hosting technology, as well as what that technology is. 
    1. To identify the vulnerabilties, click **+** and then select **Vulnerabilites** *that exists on it*.

- Find all containers with an application endpoint.

    1. On the Explorer > Security Graph page, click **Cloud Resource** in the root Select clause, and add **Container**. 
    1. Click the **+** (Add filter) or type **F**, and select **Application Endpoint** *is served by it*. 
    
        This result identifies all containers with an application endpoint running on it.
     
        **Note:** Even if you wanted to use Container Image, you cannot. That node type does not have a vertex to application endpoint! So if you notice that an expected option is not available, check your root node type.

- How many VMs are running MongoDB and are exposed to the Internet?

    1. On the Explorer > Security Graph page, click **Cloud Resource** in the root Select clause, and add **Virtual Machine**. 
    
    1. Click the **+** (Add filter) or type **F**, and select **Hosted Technology** that runs on it. 
    
    1. To filter to just those VMs where Mongo is running, click **+** and then select **Technology ID**, and then select **equals MongoDB**.
    
    1. To filter to see only those VMs with internet exposure, click **+** and then select the **Internet Exposure** property.
    **Note: The "Internet Exposure == True" flag is not equal to Application Endpoint. A single port open to one public IP would match the Internet Exposure flag. So it's a subset of Application Endpoint, which is equivalent to 0.0.0.0/0 exposure for at least one protocol/port pair. 
    
    1. How many VMs with exposed services and running MongoDB are exposed to the Internet, where those exposed services are verified to have open ports?

- Your customer says they have connected all of their subscriptions. How can Wiz help the customer to verify that assumption?

    1. Select **Subscription** as the root node of your query.
    1. Click **+** and select the **Name** property. Enter the following value:
    
            Discovered:  
<br>
        
***Discovered:*** is a special prefix applied to resources when their existence can be inferred from information gathered from other sources, but the resources themselves cannot be accessed or scanned directly by Wiz. In this scenario, review the list of discovered subscriptions with your customer to ensure they have not missed any Subscriptions.

### Self-paced Tasks
Write down your answers/queries and debrief with your classmates and instructor.

1. Find all VMs, containers, and serverless functions with open ports as validated by the dynamic scanner.
        <details>
         <summary>Q1-Answer</summary>
        When we consider the dynamic scanner, we know that the finding with the dynamic scanner enrichments is the "Application Endpoint". So we will select our workloads and then ensure they have an exposed Application Endpoint. We can check for validation using a filter called "Validated Open Ports by the Dynamic Scanner". 
<br><br>
    <a href="https://app.wiz.io/p/jdazureownertagdelete/graph#~(view~'table~query~(type~(~'VIRTUAL_MACHINE~'SERVERLESS~'CONTAINER)~select~true~relationships~(~(type~(~(type~'SERVES))~with~(type~(~'ENDPOINT)~select~true~where~(portValidationResult~(EQUALS~(~'Open))))))))">https://app.wiz.io/p/jdazureownertagdelete/graph#~(view~'table~query~(type~(~'VIRTUAL_MACHINE~'SERVERLESS~'CONTAINER)~select~true~relationships~(~(type~(~(type~'SERVES))~with~(type~(~'ENDPOINT)~select~true~where~(portValidationResult~(EQUALS~(~'Open))))))))</a>
    </details>

1. Find all workloads hosting technology that is end of life.
       <details>
        <summary>Q2-Answer</summary>
        When we talk about Workloads in Wiz, especially in a query, we are referring to the big three: VMs, containers, and serverless. But this is a great example for us to use to consider what do we want to look for and where? Is end of life technology something we can find on a container image? Yes! On the Explorer > Security Graph page, click Cloud Resource in the root Select clause, and add Virtual Machine and add Container Image and add Serverless. Click the + (Add filter) or type F, and select End of life technologies runs on it. This accelerator is a built-in conditional branch that applies all of the details "Runs Hosted Technology" with the property "Is Version End of Life equals True". if we hide the technologies, we see what the workloads are. So clicking on the little eye and hiding these entities get us the real answer we want.​
 <br><br>
    <a href="https://app.wiz.io/p/jdazureownertagdelete/graph#~(view~'table~query~(type~(~'VIRTUAL_MACHINE~'SERVERLESS~'CONTAINER_IMAGE~'CONTAINER)~select~true~relationships~(~(type~(~(type~'RUNS))~with~(type~(~'HOSTED_TECHNOLOGY)~select~true~where~(isVersionEndOfLife~(EQUALS~true)))))))">https://app.wiz.io/p/jdazureownertagdelete/graph#~(view~'table~query~(type~(~'VIRTUAL_MACHINE~'SERVERLESS~'CONTAINER_IMAGE~'CONTAINER)~select~true~relationships~(~(type~(~(type~'RUNS))~with~(type~(~'HOSTED_TECHNOLOGY)~select~true~where~(isVersionEndOfLife~(EQUALS~true)))))))</a>
    </details>

1. Find all virtual machines running an unpatched OS that has not been updated in over a year.
       <details>
        <summary>Q3-Answer</summary>
        On the Explorer > Security Graph page, click Cloud Resource in the root Select clause, and add Virtual Machine. Click the + (Add filter) or type F, and select Hosted Technology that runs on it. Click the + (Add filter) or type F, and select Detection Method and select equals and Operating System. To test whether it is the latest version running, click the + (Add filter) or type F, and select and select Is Latest Version and select equals and False. Last, let's zero in on the versions release date of this version. Click the + (Add filter) or type F, and select Version Release Date and select the values of Before the last 12 months.​
<br><br>    <b>Tip:</b> The OS is a hosted technology on a VM, which represents the compute instance. Since we scan the OS volume, we know a lot about the OS. These types of queries are really related to inventory management, but simple abstract questions about an environment is a great way demonstrate the power of the graph relative to other technologies. The ability to understand what is actually happening in an environment is so simple and logical with Wiz.​
 <br><br>
    <a href="https://app.wiz.io/graph#~(query~(type~(~'VIRTUAL_MACHINE)~select~true~relationships~(~(type~(~(type~'RUNS))~with~(blockName~'Runs*20unpatched*20OS~type~(~'HOSTED_TECHNOLOGY)~where~(detectionMethods~(EQUALS~(~'DetectionMethodOS))~isLatestVersion~(EQUALS~false)~versionReleaseDate~(BEFORE_THE_LAST~(amount~12~unit~'months)))~blockExpanded~true~select~true~aggregate~true))))~view~'table~columns~(~(~'0~30)~(~'0cloudPlatform~14)~(~'0status~14)~(~'0externalId~14)~(~'0accessibleFrom.internet~14)~(~'_aggregateCount_~15)))​">https://app.wiz.io/graph#~(query~(type~(~'VIRTUAL_MACHINE)~select~true~relationships~(~(type~(~(type~'RUNS))~with~(blockName~'Runs*20unpatched*20OS~type~(~'HOSTED_TECHNOLOGY)~where~(detectionMethods~(EQUALS~(~'DetectionMethodOS))~isLatestVersion~(EQUALS~false)~versionReleaseDate~(BEFORE_THE_LAST~(amount~12~unit~'months)))~blockExpanded~true~select~true~aggregate~true))))~view~'table~columns~(~(~'0~30)~(~'0cloudPlatform~14)~(~'0status~14)~(~'0externalId~14)~(~'0accessibleFrom.internet~14)~(~'_aggregateCount_~15)))​</a>
    </details>

1. Find all unpatched applications more than a year out of date running on VMs or containers.
       <details>
        <summary>Q4-Answer</summary>
        The documentation has great use cases to highlight the value of Wiz queries. This one can be found directly in the Use Cases of Inventory, see https://docs.wiz.io/wiz-docs/docs/using-the-inventory.​
<br><br>      
        <a href=" https://app.wiz.io/graph#~(query~(type~(~'VIRTUAL_MACHINE~'CONTAINER_IMAGE)~select~true~relationships~(~(type~(~(type~'RUNS))~with~(select~true~blockName~'Runs*20unpatched*20OS~type~(~'HOSTED_TECHNOLOGY)~where~(isLatestVersion~(EQUALS~false)~latestVersionReleaseDate~(BEFORE_THE_LAST~(amount~12~unit~'months)))~blockExpanded~true)))))​">https://app.wiz.io/graph#~(query~(type~(~'VIRTUAL_MACHINE~'CONTAINER_IMAGE)~select~true~relationships~(~(type~(~(type~'RUNS))~with~(select~true~blockName~'Runs*20unpatched*20OS~type~(~'HOSTED_TECHNOLOGY)~where~(isLatestVersion~(EQUALS~false)~latestVersionReleaseDate~(BEFORE_THE_LAST~(amount~12~unit~'months)))~blockExpanded~true)))))​</a>
<br><br>
        The query above just identifies whether a VM or container image has an outdated technology. To be able to assess how many outdated technologies are running on it, we can expand the query to include the instance of technology. A node will display on the graph with a counter aggregated. This is the preferred approach from our policy experts, to aggregate the view.​
<br><br>
        <a href="https://app.wiz.io/graph#~(query~(type~(~'VIRTUAL_MACHINE~'CONTAINER_IMAGE)~select~true~relationships~(~(type~(~(type~'RUNS))~with~(blockName~'Runs*20unpatched*20OS~type~(~'HOSTED_TECHNOLOGY)~where~(isLatestVersion~(EQUALS~false)~latestVersionReleaseDate~(BEFORE_THE_LAST~(amount~12~unit~'months)))~blockExpanded~true~relationships~(~(type~(~(type~'HAS_TECH))~with~(type~(~'TECHNOLOGY)~select~true~aggregate~true)))~select~true)))))​">https://app.wiz.io/graph#~(query~(type~(~'VIRTUAL_MACHINE~'CONTAINER_IMAGE)~select~true~relationships~(~(type~(~(type~'RUNS))~with~(blockName~'Runs*20unpatched*20OS~type~(~'HOSTED_TECHNOLOGY)~where~(isLatestVersion~(EQUALS~false)~latestVersionReleaseDate~(BEFORE_THE_LAST~(amount~12~unit~'months)))~blockExpanded~true~relationships~(~(type~(~(type~'HAS_TECH))~with~(type~(~'TECHNOLOGY)~select~true~aggregate~true)))~select~true)))))​</a>
<br><br>    
        One last view. Run the full query and hide the hosted technology and root node columns so you can see the technologies that are out of date!​
    </details>

1. How many resources are exposed to ' 0.0.0.0/0 '? Use 'All Projects' for this query.
       <details>
        <summary>Q5-Answer</summary>
        When we think about that phrase "all resources", what could we mean? We want to see all cloud resources and anything running on workloads that could host a network service. Since Wiz also integraions partially supported cloud services in various stages, we should also include those; though it is unklikely that we will see that but we include it for sake of being thorugh. So to query everything possible in the environment, we want to look for "Cloud Resources", "Hosted Technologies", and "Technology Usage" (anything that is partially covered).
<br><br>    
    Also, what does it mean to be exposed to 0.0.0.0/0 in Wiz?​
        We are talking about either "Wide Internet Exposure" or an "application endpoint” being exposed to on all addresses on all ports. However, spcific enrichments are not aggregated up through catch all objects like Cloud Resources. So we want to find an edge to an application endpoint.  
        The preferred query is as follows:
<br><br>
    <a href="https://app.wiz.io/graph#~(view~'table~query~(type~(~'CLOUD_RESOURCE~'SERVICE_USAGE_TECHNOLOGY~'HOSTED_TECHNOLOGY)~select~true~relationships~(~(type~(~(type~'SERVES))~with~(type~(~'ENDPOINT)~select~true))))~columns~(~(~'0~30)~(~'0cloudPlatform~14)~(~'0status~12)~(~'1~20)~(~'1dynamicScannerScreenshotUrl~12)~(~'1port~12)))">https://app.wiz.io/graph#~(view~'table~query~(type~(~'CLOUD_RESOURCE~'SERVICE_USAGE_TECHNOLOGY~'HOSTED_TECHNOLOGY)~select~true~relationships~(~(type~(~(type~'SERVES))~with~(type~(~'ENDPOINT)~select~true))))~columns~(~(~'0~30)~(~'0cloudPlatform~14)~(~'0status~12)~(~'1~20)~(~'1dynamicScannerScreenshotUrl~12)~(~'1port~12)))</a>  
    </details>

1. Let's complicate the last query a bit and find just those resources exposed to 0.0.0.0/0 that are accepting RDP or SSH requests. How many are there?
       <details>
       <summary>Q6-Answer</summary>
        We don't identify protocols by name, as many applications listen to the same port. For the sake of this query, we assume that SSH uses TCP port 22 and that RDP uses TCP 3389, which are the default TCP assignments by IETF for these protocols. Armed with that data, it is a simple property filter around ports applied to the application endpoint. The application endpoint gives us the "accessible from the Internet" check, and by scoping it to the ports we can make intelligently guess at the possible protocols in use.​
        On the **Explorer > Security Graph** page, click **Cloud Resource** in the root Select clause, and add **Cloud Resources**, **Hosted Technologies**, and **Technology Usage**. Then click the **+** (Add filter) or type **F**, and select **Application Endpoint**, then click the **+** (add property filter) or type **F** and select the **Port** property and add one value equal to <code>22</code> and another for equal to <code>3389</code>. Toggle to the table view to read the results more easily.​
<br><br>
    <a href="https://app.wiz.io/p/jdazureownertagdelete/graph#~(view~'table~query~(type~(~'CLOUD_RESOURCE~'HOSTED_TECHNOLOGY~'SERVICE_USAGE_TECHNOLOGY)~select~true~relationships~(~(type~(~(type~'SERVES))~with~(type~(~'ENDPOINT)~select~true~where~(port~(EQUALS~(~22~3389)))))))~columns~(~(~'0~23)~(~'0cloudPlatform~13)~(~'0status~13)~(~'1~23)~(~'1port~13)~(~'1portValidationResult~13)))">https://app.wiz.io/p/jdazureownertagdelete/graph#~(view~'table~query~(type~(~'CLOUD_RESOURCE~'HOSTED_TECHNOLOGY~'SERVICE_USAGE_TECHNOLOGY)~select~true~relationships~(~(type~(~(type~'SERVES))~with~(type~(~'ENDPOINT)~select~true~where~(port~(EQUALS~(~22~3389)))))))~columns~(~(~'0~23)~(~'0cloudPlatform~13)~(~'0status~13)~(~'1~23)~(~'1port~13)~(~'1portValidationResult~13)))</a>                
 
   </details>
## Exercise 2: Manage Shadow IT​ Use Case

### Overview
As the SecOps or DevOps experience the sprawl of technologies in the cloud, unknown and unwanted technologies often drift into the stack, intentionally or unintentionally. And that creates a problem of unwanted or unknown technologies existing alongside known and approved technologies. Many organizations prefer to control this "shadow IT" by systematically reviewing the technologies and removing or isolating unknown and unwanted technologies. ​

### Task
How would you solve the problem described above. Discuss your solution with your instructor.

#### Hint/Checklist
- Consider how inventory helps you manage Shadow IT.
- How would you create a repeatable search for this scenario?
- How would you ensure that you were alerted to the presence of these technologies identified above? 

Configure your solution/answer in the Wiz Portal and be prepared to review with your classmates and instructors.

</div>
