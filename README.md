# SQL Server Modernisation Hack #

Awesome Trading inc. is an online trading company. Founded in 2008, the company has experience exponential growth since releasing its online trading platform. As part of their monitoring of ongoing trades, the company uses a legacy Application called the “Online Transaction Monitor”, which was originally written in VB6 and developed against a SQL Server 2008r2 Databases.
Awesome Trading have started to find that the management of the SQL Server 2008 database is becoming too much to manage with the current support staff, and would like to reduce this burden on their support teams. As their service has also increased in popularity, the Stand-alone SQL server this database currently uses does not meet the 99.99% SLA for availability required, and they would prefer to use supported Windows and OS versions.

Awesome Trading would like to run a Proof of Concept (PoC) the “Online Transaction Monitor” and using PaaS Data Services in Azure. As the Trading platform is only used during business hours, Awesome Trading are happy for the PoC to be migrated with downtime over a weekend. However, there is a complication in that Awesome Trading do not have the latest up to date source code for this application, so the only thing that can be changed is the connection strings for this application. There is also a set of SSIS packages that feed a Datawarehouse that need to be factored. Additionally databases contain sensitive data, these  will need to be marked and encrypted during the migration and any other vulnerabilities assessed and resolved.

## Target audience ##

Up to 20 Teams of:

* Database administrators
* SQL/Database developers
* Application developers

## Hands-on labs ##
In these hands-on labs, you will implement a proof-of-concept (PoC) for migrating an on-premises SQL Server 2008 R2 database into Azure SQL Database Managed Instance (SQL MI). You will perform assessments to reveal any feature parity and compatibility issues between the on-premises SQL Server 2008 R2 database and the managed database offerings in Azure. You will then migrate the customer's on-premises databases into Azure, using migration services. Additionally, you will migrate SSIS packages from on premise into Azure PaaS Services. Finally, you will enable some of the advanced SQL features available in SQL MI to improve security and performance in the customer's application.
At the end of this hands-on lab, you will be better able to implement a cloud migration solution for business-critical applications and databases.

## Lab Architecture ##

The following diagram provides an overview of the Lab environment that will be built.

**This architecture is designed for a classroom environment of up to 20 teams within a single subscription.**

![SQL Hack Architecture](https://github.com/markjones-msft/SQL-Hackathon/raw/master/Hands-On%20Lab/SQLHack%20Architecture.png "SQL Hack Architecture")

***NOTE: There are up to 20 workshop environments using a SHARED source SQL Server and Target Azure SQL Database. Please be respectful of only migrating your teams Databases and Logins.***

## Azure services and related products ##
* Azure SQL Database Managed Instance (SQL MI)
* Azure SQL Database (SQL DB)
* Azure Database Migration Service (DMS)
* Microsoft Data Migration Assistant (DMA)
* SQL Server 2008
* SQL Server on VM
* SQL Server Management Studio (SSMS)
* Azure virtual machines
* Visual Studio SSDT
* Azure virtual network
* Azure virtual network gateway
* Azure Blob Storage account
* Azure Key Vault
* Azure Data Factory
* Integration Runtime SSIS

## Instructions to Install ##

***NOTE This repositry will install a number of components within the designated subscription at an estimated cost of around $20 per day***

To install please complete the following:
1. Go to the BUILD folder and download the ARM Deployment - SQL Hackathon v2.ps1 powershell script.
2. Within Powershell ISE or VSCode - load the ARM Deployment - SQL Hackathon v2.ps1
3. Execute the ARM Deployment - SQL Hackathon v2.ps1 script, following the on screen prompts (Note only select 1 TEAM VM when prompted)


## Known Issues ##

