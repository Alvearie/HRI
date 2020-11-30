# Monitoring, logging

- [Logging with LogDNA](#log-files-with-logdna)
- [About Management API monitoring tools](#about-management-api-monitoring-tools)
- [Using the New Relic synthetic monitor](#new-relic-synthetic-monitor)
- [About user data access logging](#about-user-data-access-logging)

## Logging with LogDNA  
For application logging purposes, the Health Record Ingestion service uses the IBM&reg; Cloud LogDNA service. In the Health Record Ingestion service, there are two sources of logs: 

- The [Management API ](glossary.md#management-api) (IBM Functions) 
- The Document Store [(Elastic Search)](glossary.md#elasticsearch)

Both send logs to the LogDNA instance designated for Platform Logs in your particular IBM Cloud Region for your [IBM Cloud Functions](glossary.md#ibm-cloud-functions) account. For more information about LogDNA, see [IBM Cloud LogDNA](https://cloud.ibm.com/docs/Log-Analysis-with-LogDNA)

To use LogDNA:

1. Open the correct instance of LogDNA. Use the LogDNA instance associated with your Resource Group. Use the group that's located in the region where your IBM Cloud Functions instance is located, for example, `Dallas(US-South)`.
2. Click **View LogDNA**. 

### Using LogDNA to view the Health Record Ingestion service logs
After you open the correct instance of LogDNA, you'll typically use filtering to find logs of interest. 

**To filter logs:**
- Try filtering by source. Select from the menus in the menu bar (Figure 1). 
- To filter for IBM Functions log messages, go to the **All Sources** menu and select **functions**.
- To filter for Elastic Search logs, you would select `ibm-cloud-database-prod`. 
- To filter to a specific instance, go to **All Apps** menu and use the Cloud Resource Name (CRN) identifier. 

**Figure 1: Filtering logs by function**

![filtering-by-functions](assets/img/filter_by_functions.jpg)   

In addition, you can filter by keyword in the log. For example, the keyword **batches/** is in the path of the REST API request for many Management API operations. 

## About Management API monitoring tools
IBM Cloud Functions also provides some build-in monitoring tools to help those supporting an application identify potential issues. The Cloud Functions Monitor page is the place to start any monitoring investigation or search for potential issues.

**To monitor activities and functions:**

 1. Sign in to your [IBM Cloud account](https://cloud.ibm.com/login).
 2. Next to **IBM Cloud**, click the navigation menu and select **Functions**.

**Figure 2: Navigation menu**

![ibm-cloud-nav-icon](assets/img/ibm_cloud_nav_icon.png)

<br><br>
**Figure 3: The Functions option**

![ibm-cloud-nav-menu](assets/img/ibm_cloud_nav_menu.png)

 3. On the IBM Cloud Functions page, at the upper right, select the appropriate namespace for your particular functions deployment for the Health Record Ingestion service. For example, in Figure 4, the integration instance for the Health Record Ingestion service is deployed to the **"HRI-API"** namespace. 

To learn about namespaces and cloud functions, see [Managing namespaces](https://cloud.ibm.com/docs/openwhisk?topic=openwhisk-namespaces). 

**Figure 4: Selecting a namespace**

![ibm-functions-choose-namespace](assets/img/ibm_functions_choose_namespace.jpg)

 4. On the IBM Functions main page, on the **Functions** menu, click **Monitor**.

**Figure 5: Accessing monitoring**

![ibm-functions-nav-menu](assets/img/ibm_functions_nav_menu.png)

 5. On the IBM Functions Monitor page, note the **Activity Summary** panel, the **Activity Log** panel, and the **Activity Timeline** panel. Check the **Activity Log** panel when investigating possible Health Record Ingestion service errors or performance issues.

**To review details of a function call instance:**

 1. Click the activationId for any given function activity. In Figure 6, for the `create_batch` function call, the activationId is the alphanumeric string starting with **9ca17c7b4acc**.

**Figure 6: An activationId in the Activity Log panel**

![functions-monitor-page](assets/img/functions_monitor_page.jpg)   

 2. To display details of a particular function call, click the activationId link. On the tab that opens, review details that include the path and any possible error event or description. 

**Figure 7: Details for a function call**

![fx-activity-detail](assets/img/fx_activity_detail.jpg) 

**Tip:** You can use the activationId to search for the event in LogDNA log files. 

**Methods of monitoring**

- To determine what occurred around an error or other issue, check other messages logged at approximately the same time as the event, for example, slightly before and slightly after. 
- Every error response from the Management API includes the request's activationId. This ID should match the value in the [errorEventId](https://github.com/Alvearie/hri-api-spec/tree/master/management-api/management.yml#L821) field. In Figure 7, the activationId appears at the top of the JSON output. So, if a client receives an error response, you can use the **errorEventId** value to find the details about that specific API invocation.

## Using the New Relic&copy; Synthetic Monitor
To configure a New Relic Monitoring instance for your deployed Health Record Ingestion service, access the health check endpoint. For information about how we configure New Relic, see the new-relic-healthcheck.js in the [mgmt-api GitHub repository](https://github.com/Alvearie/hri-mgmt-api/tree/master/monitors).   

## About user data access logging
Health Insurance Portability and Accountability Act (HIPAA) regulations require logging all access to [Protected Health Information, PHI](glossary.md#phi) data. In the Health Record Ingestion service, PHI is only persisted in Event Streams, which automatically logs access to Activity Tracker. To learn more, see [Activity Tracker events](https://cloud.ibm.com/docs/services/EventStreams?topic=eventstreams-at_events). 

To view these access logs, go to the [Activity Tracker](https://cloud.ibm.com/observe/activitytracker) instance for your account. It has the same LogDNA interface mentioned in this topic. You can filter logs by either or both source and application.