```

2 Analytics Services
    2.1 Azure Databricks
        2.1.1        L1  Automated   Ensure that Azure Databricks is deployed in a customer-managed virtual network (VNet) 
        2.1.2        L1  Automated   Ensure that Network Security Groups are Configured for Databricks Subnets 
        2.1.3        L2  Manual      Ensure that Traffic is Encrypted Between Cluster Worker Nodes 
        2.1.4        L1  Manual      Ensure that Users and Groups are Synced from Microsoft Entra ID to Azure Databricks 
        2.1.5        L1  Manual      Ensure that Unity Catalog is Configured for Azure Databricks 
        2.1.6        L1  Manual      Ensure that Usage is Restricted and Expiry is Enforced for Databricks Personal Access Tokens 
        2.1.7        L1  Automated   Ensure that Diagnostic Log Delivery is Configured for Azure Databricks 
        2.1.8        L2  Manual      Ensure Critical Data in Azure Databricks is Encrypted with Customer-managed Keys (CMK) 
        2.1.9        L1  Automated   Ensure 'No Public IP' is Set to 'Enabled' 
        2.1.10       L1  Automated   Ensure 'Allow Public Network Access' is set to 'Disabled' 
        2.1.11       L2  Automated   Ensure Private Endpoints are used to access Azure Databricks workspaces 
        2.1.12       L1  Manual      Ensure Azure Databricks groups are reviewed periodically 

3 Compute Services
    3.1 Virtual Machines
        3.1.1        L2  Manual      Ensure only MFA Enabled Identities can Access Privileged Virtual Machine 

4 Database Services

5 Identity Services
    5.1 Security Defaults (Per-User MFA)
        5.1.1        L1  Automated   Ensure that 'security defaults' is Enabled in Microsoft Entra ID 
        5.1.2        L1  Manual      Ensure that 'Require Multifactor Authentication to register or join devices with
                                     Microsoft Entra' is set to 'Yes' 
        5.1.3        L1  Automated   Ensure that 'multifactor authentication' is 'enabled' For All Users 
        5.1.4        L1  Manual      Ensure that 'Allow users to remember multifactor authentication on devices they
                                     trust' is Disabled 
        
    5.2 Conditional Access
                   Legacy Section

    5.3 Periodic Identity Reviews
        5.3.1        L1  Manual      Ensure that Azure Admin Accounts Are Not Used for Daily Operations 
        5.3.2        L1  Automated*  Ensure that Guest Users are Reviewed on a Regular Basis 
        5.3.3        L1  Automated   Ensure That Use of the 'User Access Administrator' Role is Restricted 
        5.3.4        L1  Manual      Ensure that All 'Privileged' Role Assignments are Periodically Reviewed 
        5.3.5        L1  Manual      Ensure Disabled User Accounts do not Have Read, Write, or Owner Permissions 
        5.3.6        L1  Automated*  Ensure 'Tenant Creator' Role Assignments are Periodically Reviewed 
        5.3.7        L1  Manual      Ensure All Non-privileged Role Assignments are Periodically Reviewed 

    5.4              L1  Automated   Ensure that No Custom Subscription Administrator Roles Exist 
    5.5              L2  Manual      Ensure that a Custom Role is Assigned Permissions for Administering Resource Locks 
    5.6              L2  Manual      Ensure that 'Subscription leaving Microsoft Entra tenant' and 'Subscription entering
                                     Microsoft Entra tenant' is set to 'Permit no one' 
    5.7              L1  Automated   Ensure there are between 2 and 3 Subscription Owners 

6 Management and Governance Services
    6.1 Logging and Monitoring
        6.1.1 Configuring Diagnostic Settings
            6.1.1.1  L1  Automated   Ensure that a 'Diagnostic Setting' Exists for Subscription Activity Logs 
            6.1.1.2  L1  Automated   Ensure Diagnostic Setting Captures Appropriate Categories 
            6.1.1.3  L2  Manual      Ensure the Storage Account Containing the Container with Activity Logs is Encrypted
                                     with Customer-managed Key (CMK) 
            6.1.1.4  L1  Automated   Ensure that Logging for Azure Key Vault is 'Enabled' 
            6.1.1.5  L2  Manual      Ensure that Network Security Group Flow Logs are Captured and Sent to Log Analytics 
            6.1.1.6  L2  Manual      Ensure that Virtual Network Flow Logs are Captured and Sent to Log Analytics 
            6.1.1.7  L2  Manual      Ensure that a Microsoft Entra Diagnostic Setting Exists to Send Microsoft Graph
                                     Activity Logs to an Appropriate Destination 
            6.1.1.8  L2  Manual      Ensure that a Microsoft Entra Diagnostic Setting Exists to Send Microsoft Entra
                                     Activity Logs to an Appropriate Destination 
            6.1.1.9  L2  Manual      Ensure that Intune Logs are Captured and Sent to Log Analytics 

        6.1.2 Monitoring Using Activity Log Alerts
            6.1.2.1  L1  Automated   Ensure that Activity Log Alert Exists for Create Policy Assignment 
            6.1.2.2  L1  Automated   Ensure that Activity Log Alert exists for Delete Policy Assignment 
            6.1.2.3  L1  Automated   Ensure that Activity Log Alert Exists for Create or Update Network Security Group 
            6.1.2.4  L1  Automated   Ensure that Activity Log Alert Exists for Delete Network Security Group 
            6.1.2.5  L1  Automated   Ensure that Activity Log Alert Exists for Create or Update Security Solution 
            6.1.2.6  L1  Automated   Ensure that Activity Log Alert Exists for Delete Security Solution 
            6.1.2.7  L1  Automated   Ensure that Activity Log Alert Exists for Create or Update SQL Server Firewall Rule 
            6.1.2.8  L1  Automated   Ensure that Activity Log Alert Exists for Delete SQL Server Firewall Rule 
            6.1.2.9  L1  Automated   Ensure that Activity Log Alert Exists for Create or Update Public IP Address rule 
            6.1.2.10 L1  Automated   Ensure that Activity Log Alert Exists for Delete Public IP Address rule 
            6.1.2.11 L1  Automated   Ensure that an Activity Log Alert Exists for Service Health 

        6.1.3 Configuring Application Insights
            6.1.3.1  L2  Automated   Ensure Application Insights are Configured 

        6.1.4        L1  Manual      Ensure that Azure Monitor Resource Logging is Enabled for All Services that Support it 
        6.1.5        L2  Manual      Ensure Basic, Free, and Consumption SKUs are not used on Production artifacts requiring
                                     monitoring and SLA 

    6.2              L2  Manual      Ensure that Resource Locks are set for Mission-Critical Azure Resources 


7 Networking Services
        7.1          L1  Automated   Ensure that RDP Access from the Internet is Evaluated and Restricted 
        7.2          L1  Automated   Ensure that SSH Access from the Internet is Evaluated and Restricted 
        7.3          L1  Automated   Ensure that UDP Port Access from the Internet is Evaluated and Restricted 
        7.4          L1  Automated   Ensure that HTTP(S) Access from the Internet is Evaluated and Restricted 
        7.5          L2  Automated   Ensure that Network Security Group Flow Log Retention Days is Set to Greater than or equal to 90 
        7.6          L2  Automated   Ensure that Network Watcher is 'Enabled' for Azure Regions That are in Use 
        7.7          L1  Manual      Ensure that Public IP Addresses are Evaluated on a Periodic Basis 
        7.8          L2  Automated   Ensure that Virtual Network Flow Log Retention Days is Set to Greater than or Equal to 90 
        7.9          L2  Automated   Ensure 'Authentication type' is Set to 'Azure Active Directory' only for Azure
                                     VPN Gateway Point-to-Site Configuration 
        7.10         L2  Automated   Ensure Azure Web Application Firewall (WAF) is Enabled on Azure Application Gateway 
        7.11         L1  Automated   Ensure Subnets Are Associated with Network Security Groups 
        7.12         L1  Automated   Ensure the SSL Policy's 'Min protocol version' is Set to 'TLSv1_2' or Higher on
                                     Azure Application Gateway 
        7.13         L1  Automated   Ensure 'HTTP2' is Set to 'Enabled' on Azure Application Gateway 
        7.14         L2  Automated   Ensure Request Body Inspection is Enabled in Azure Web Application Firewall
                                     policy on Azure Application Gateway 
        7.15         L2  Automated   Ensure Bot Protection is Enabled in Azure Web Application Firewall Policy on Azure
                                     Application Gateway 
        7.16         L2  Manual      Ensure Azure Network Security Perimeter is Used to Secure Azure Platform-as-a-service Resources 


8 Security Services
    8.1 Microsoft Defender for Cloud
        8.1.1    Microsoft Cloud Security Posture Management (CSPM)
            8.1.1.1  L2  Automated   Ensure Microsoft Defender CSPM is Set to 'On' 
        
        8.1.2 Defender Plan: APIs
            8.1.2.1  L2  Automated   Ensure Microsoft Defender for APIs is Set to 'On' 

        8.1.3 Defender Plan: Servers
            8.1.3.1  L2  Automated   Ensure that Defender for Servers is Set to 'On' 
            8.1.3.2  L2  Manual      Ensure that 'Vulnerability assessment for machines' Component Status is set to 'On' 
            8.1.3.3  L2  Automated   Ensure that 'Endpoint protection' Component Status is set to 'On' 
            8.1.3.4  L2  Manual      Ensure that 'Agentless scanning for machines' Component Status is Set to 'On' 
            8.1.3.5  L2  Manual      Ensure that 'File Integrity Monitoring' Component Status is Set to 'On' 

        8.1.4 Defender Plan: Containers
            8.1.4.1  L2  Automated   Ensure That Microsoft Defender for Containers Is Set To 'On' 

        8.1.5 Defender Plan: Storage
            8.1.5.1  L2  Automated   Ensure That Microsoft Defender for Storage Is Set To 'On' 
            8.1.5.2  L2  Manual      Ensure Advanced Threat Protection Alerts for Storage Accounts Are Monitored 

        8.1.6 Defender Plan: App Service
            8.1.6.1  L2  Automated   Ensure That Microsoft Defender for App Services Is Set To 'On' 

        8.1.7 Defender Plan: Databases
            8.1.7.1  L2  Automated   Ensure That Microsoft Defender for Azure Cosmos DB Is Set To 'On' 
            8.1.7.2  L2  Automated   Ensure That Microsoft Defender for Open-Source Relational Databases Is Set To 'On' 
            8.1.7.3  L2  Automated   Ensure That Microsoft Defender for (Managed Instance) Azure SQL Databases Is Set To 'On' 
            8.1.7.4  L2  Automated   Ensure That Microsoft Defender for SQL Servers on Machines Is Set To 'On' 
        
        8.1.8 Defender Plan: Key Vault
            8.1.8.1  L2  Automated   Ensure That Microsoft Defender for Key Vault Is Set To 'On' 

        8.1.9 Defender Plan: Resource Manager
            8.1.9.1  L2  Automated   Ensure That Microsoft Defender for Resource Manager Is Set To 'On' 

        8.1.10       L1  Automated   Ensure that Microsoft Defender for Cloud is Configured to Check VM Operating Systems for Updates 
        8.1.11       L1  Manual      Ensure that non-deprecated Microsoft Cloud Security Benchmark policies are not set to 'Disabled' 
        8.1.12       L1  Automated   Ensure That 'All users with the following roles' is Set to 'Owner' 
        8.1.13       L1  Automated   Ensure 'Additional email addresses' is Configured with a Security Contact Email 
        8.1.14       L1  Automated   Ensure that 'Notify about alerts with the following severity (or higher)' is Enabled 
        8.1.15       L1  Automated   Ensure that 'Notify about attack paths with the following risk level (or higher)' is Enabled 
        8.1.16       L2  Manual      Ensure that Microsoft Defender External Attack Surface Monitoring (EASM) is Enabled 

    8.2 Microsoft Defender for IoT
        8.2.1        L2  Manual      Ensure That Microsoft Defender for IoT Hub Is Set To 'On' 

    8.3 Key Vault
        8.3.1        L1  Automated   Ensure that the Expiration Date is Set for all Keys in Key Vaults using RBAC 
        8.3.2        L1  Automated   Ensure that the Expiration Date is set for All Keys in Key Vaults using access policies (legacy)
        8.3.3        L1  Automated   Ensure that the Expiration Date is set for All Secrets in Key Vaults using RBAC 
        8.3.4        L1  Automated   Ensure that the Expiration Date is set for All Secrets in Key Vaults using access policies (legacy) 
        8.3.5        L1  Automated   Ensure 'Purge protection' is Set to 'Enabled' 
        8.3.6        L2  Automated   Ensure that Role Based Access Control for Azure Key Vault is Enabled 
        8.3.7        L1  Automated   Ensure Public Network Access is Disabled 
        8.3.8        L2  Automated   Ensure Private Endpoints are Used to Access Azure Key Vault 
        8.3.9        L2  Automated   Ensure Automatic Key Rotation is Enabled within Azure Key Vault 
        8.3.10       L2  Manual      Ensure that Azure Key Vault Managed HSM is Used when Required 
        8.3.11       L1  Automated   Ensure Certificate 'Validity Period (in months)' is Less Than or Equal to '12' 
    
    8.4 Azure Bastion
        8.4.1        L2  Automated   Ensure an Azure Bastion Host Exists 

    8.5              L2  Automated   Ensure Azure DDoS Network Protection is Enabled on Virtual Networks 

9 Storage Services
    9.1 Azure Files
        9.1.1        L1  Automated   Ensure Soft Delete for Azure File Shares is Enabled 
        9.1.2        L1  Automated   Ensure 'SMB protocol version' is Set to 'SMB 3.1.1' or Higher for SMB file shares 
        9.1.3        L1  Automated   Ensure 'SMB channel encryption' is Set to 'AES-256-GCM' or Higher for SMB file shares 

    9.2 Azure Blob Storage
        9.2.1        L1  Automated   Ensure That Soft Delete for Blobs on Azure Blob Storage Storage Accounts is Enabled 
        9.2.2        L1  Automated   Ensure that Soft Delete for Containers on Azure Blob Storage Storage Accounts is Enabled 
        9.2.3        L2  Automated   Ensure 'Versioning' is Set to 'Enabled' on Azure Blob Storage Storage Accounts 

    9.3 Storage Accounts
        9.3.1 Secrets and Keys
            9.3.1.1  L1  Automated   Ensure That 'Enable key rotation reminders' is Enabled for Each Storage Account 
            9.3.1.2  L1  Automated   Ensure That Storage Account Access keys are Periodically Regenerated 
            9.3.1.3  L1  Automated   Ensure 'Allow storage account key access' for Azure Storage Accounts is 'Disabled' 

        9.3.2 Networking
            9.3.2.1  L2  Automated   Ensure Private Endpoints are Used to Access Storage Accounts 
            9.3.2.2  L1  Automated   Ensure that 'Public Network Access' is 'Disabled' for Storage Accounts 
            9.3.2.3  L1  Automated   Ensure Default Network Access Rule for Storage Accounts is Set to Deny 

        9.3.3 Identity and Access Management
            9.3.3.1  L1  Automated   Ensure that 'Default to Microsoft Entra authorization in the Azure portal' is Set to 'Enabled' 
        
        9.3.4        L1  Automated   Ensure that 'Secure transfer required' is Set to 'Enabled' 
        9.3.5        L2  Automated   Ensure 'Allow trusted Microsoft services to access this resource' is Enabled for Storage Account Access 
        9.3.6        L1  Automated   Ensure the 'Minimum TLS version' for Storage Accounts is Set to 'Version 1.2' 
        9.3.7        L1  Automated   Ensure 'Cross Tenant Replication' is Not Enabled 
        9.3.8        L1  Automated   Ensure that 'Allow Blob Anonymous Access' is Set to 'Disabled' 
        9.3.9        L1  Manual      Ensure Azure Resource Manager Delete Locks are Applied to Azure Storage Accounts 
        9.3.10       L2  Manual      Ensure Azure Resource Manager ReadOnly Locks are Considered for Azure Storage Accounts 
        9.3.11       L2  Automated   Ensure Redundancy is Set to 'geo-redundant storage (GRS)' on Critical Azure Storage Accounts 
```
