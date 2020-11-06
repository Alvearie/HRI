# HRI Monitoring & Logging

### Outline
* [Log files with LogDNA](#log-files-with-logdna)
* [HRI Management API Monitoring Tools](#hri-management-api-monitoring-tools)
* [New Relic Synthetic Monitor](#new-relic-synthetic-monitor)
* [User Data Access Logging](#user-data-access-logging)

## Log files with LogDNA  
[HRI](glossary.md#hri) uses the [IBM Cloud LogDNA](https://cloud.ibm.com/docs/Log-Analysis-with-LogDNA) service for application logging purposes. There are two sources of logs within the HRI: the Management API (IBM Functions) and the Document Store [(Elastic Search)](glossary.md#elasticsearch). Both send logs to the LogDNA instance designated for "Platform Logs" in your particular IBM Cloud Region for your [IBM Cloud Functions](glossary.md#ibm-cloud-functions) account. 
   
You click on the "View LogDNA" button for the LogDNA instance associated with your Resource Group located in the region where your IBM Cloud Functions instance is located, e.g. `Dallas(US-South)`.

### Using LogDNA to View HRI Logs
Once you have opened the correct instance of LogDNA, you will likely want to use the filtering feature to be able to identify the logs of interest to you. First you may want to filter by Source. There are 3 filter drop-down menus you can choose at the top of your screen. Choose the "All Sources" menu and select the "functions" checkbox to filter only on IBM Functions log messages as seen in this Screen Cap: 

![filtering-by-functions](assets/img/filter_by_functions.jpg)   


You would select `ibm-cloud-database-prod` for Elastic Search logs. You may also want to filter to a specific instance, which can be done with the Apps dropdown, using the CRN. 

You are also able to filter by keyword in the log, such as "batches/" which will be on the path of the REST API request for many of the HRI Management API operations. 

## HRI Management API Monitoring Tools
IBM Cloud Functions also provides some build-in monitoring tools to help those supporting an application identify potential issues. The Cloud Functions _Monitor_ page is the place to start any monitoring investigation or search for potential issues. 

To reach the Monitor page, in your [IBM Cloud account](https://cloud.ibm.com/login), navigate to the IBM Cloud Functions dashboard page -> click on the IBM Cloud Navigation menu icon in the Top Left of the screen (this is the 4 horizontal bars icon to the left of the words "IBM Cloud"), and click on "Functions": 

![ibm-cloud-nav-icon](assets/img/ibm_cloud_nav_icon.png)


![ibm-cloud-nav-menu](assets/img/ibm_cloud_nav_menu.png)

<br>

On the IBM Cloud Functions main page, on the upper right-hand side of the screen, you will need to choose the correct/appropriate [_Namespace_](https://cloud.ibm.com/docs/openwhisk?topic=openwhisk-namespaces) for your particular HRI functions deployment. For example, in the ScreenShot below, the HRI integration instance is deployed to the **"HRI-API"** namespace. 
 
![ibm-functions-choose-namespace](assets/img/ibm_functions_choose_namespace.jpg)

<br>
This will take you to the IBM Functions main page. On the left-hand side, you will see a _Functions navigation menu_. You will click on the "Monitor" link in the Functions Nav menu:

![ibm-functions-nav-menu](assets/img/ibm_functions_nav_menu.png)

<br>

On the IBM Functions Monitor page, you can see an _Activity Summary_ panel, and _Activity Log_ panel and an _Activity Timeline_ panel. The **Activity Log** view will be particularly helpful for investigating possible HRI errors or performance issues.
In particular, you can click on the _`activationId` link_ for any given function activity to view a screen with the details of this function call instance. In the example below, for the `create_batch` function call, the `activationId` is the alpha-numeric identifier string starting with "9ca17c7b4acc":  

![functions-monitor-page](assets/img/functions_monitor_page.jpg)   

<br>

Clicking the `activationId` link will open up a new tab showing the details of that particular function call, including the path and any possible error event or description. 

![fx-activity-detail](assets/img/fx_activity_detail.jpg) 

Note that you can use the `activationId` to search for the event in LogDNA (log files). Other messages logged around the same time as your event may be useful to determine what took place.  In addition, every error response from the HRI Management API includes the request's `activationId` which should match the value in the [errorEventId](https://github.com/Alvearie/hri-api-spec/tree/master/management-api/management.yml#L821) field (see example image just above with `activationId` at the top of the JSON output). So, if a client receives an error response, you can use the `errorEventId` value to find the details about that specific API invocation.

## New Relic Synthetic Monitor
You can also configure a New Relic Monitoring instance for your deployed HRI service by accessing the health check endpoint. Please refer to the _new-relic-healthcheck.js_ inside of our [mgmt-api Repo](https://github.com/Alvearie/hri-mgmt-api/tree/master/monitors) for details on how we configure New Relic.   

## User Data Access Logging
HIPAA regulations require logging all access to [PHI data](glossary.md#phi). In the HRI, PHI is only persisted in Event Streams, which will automatically log access to Activity Tracker, see [Activity Tracker events](https://cloud.ibm.com/docs/services/EventStreams?topic=eventstreams-at_events) for more information. 

To view these access logs, go to the [Activity Tracker](https://cloud.ibm.com/observe/activitytracker) instance for your account. It has the same LogDNA interface mentioned above where you can filter logs by source and/or application.