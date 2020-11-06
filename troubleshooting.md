# Troubleshooting

#### Index

[Management API Issues](#management-api-issues)
* [Authentication is possible but has failed or not yet been provided](#authentication-is-possible-but-has-failed-or-not-yet-been-provided)

[Event Streams Issues](#event-streams-issues)
* [SSL Certificate Issues](#ssl-certificate-issues)

## Management API Issues

### Authentication is possible but has failed or not yet been provided
**Issue:** the Management API responds with this error: 
```json
{
  "code": "2cde977c23b3ab78befed56a6aac3820",
  "error": "Authentication is possible but has failed or not yet been provided."
}
```
**Cause:** the [IBM Functions](glossary.md#ibm-cloud-functions) API Gateway is unable to authenticate with the backend IBM Function Actions. Actions have an API key and the API Gateway must be configured to use that API key. Typically, this is due to the API Gateway missing or having the wrong API key.

**Fix:** <br>
**Option 1**. Try redeploying the Management API. This will generate a new API key and set it on the Actions and the API Gateway endpoints.

**Option 2**. Manually update the API endpoints.
1. You will need the IBM Cloud CLI and Functions plugin. See these [instructions](https://cloud.ibm.com/docs/openwhisk?topic=openwhisk-cli_install) for installing them.
2. Set the CLI resource group to where the Managment API is deployed. 
   ```
   ibmcloud target -g <resource_group>
   ```
3. Set the CLI Functions namespace to where the Mangement API is deployed.
   ```
   ibmcloud fn property set --namespace <namespace>
   ```
4. Download [updateApi.sh](https://github.com/Alvearie/hri-mgmt-api/blob/master/updateApi.sh), but make sure you change the tag to match your release before downloading.
5. Run the downloaded script.
   ```
   ./updateApi.sh
   ```

**Option 3**. Manually update the API gateway JSON configuration.
1. Follow steps 1-3 above to setup the IBM CLI.
2. Download the API json configuration.
   ```
   ibmcloud fn api get hri-batches > api.json
   ```
3. Get the API key set for the Actions. Run 
   ```
   ibmcloud fn package get hri_mgmt_api
   ```
   and the output should have a `"require-whisk-auth"` entry for each action. It should be the same value for every action. E.g:
   ```json
        {
            "key": "require-whisk-auth",
            "value": "hIadvQ8w4nkJeWa3i7OPDb9WqTAUV9d6"
        },
   ```
4. Edit the `api.json` file and add or replace the API key. There will be a `x-ibm-configuration` element and a couple levels down an array of `execute` elements, one for each endpoint. Each of these needs to have a `set-variable.actions` element that sets `message.headers.X-Require-Whisk-Auth` to the API key. Make sure there is one for every endpoint and that they match the API keys from step 3. 
    ```json
    {
        "execute": [
            {
                "invoke": {
                    "target-url": "https://us-south.functions.cloud.ibm.com/api/v1/web/a98e053a-4a77-46b3-9791-53d4dfa370fb/hri_mgmt_api/get_batches.http$(request.path)",
                    "verb": "keep"
                }
            },
            {
                "set-variable": {
                    "actions": [
                        {
                            "set": "message.headers.X-Require-Whisk-Auth",
                            "value": "hIadvQ8w4nkJeWa3i7OPDb9WqTAUV9d6"
                        }
                    ]
                }
            }
        ],
        "operations": [
            "getTenantsTenantidBatches"
        ]
    }
    ```

## Event Streams Issues

### SSL Certificate Issues
**Issue:** when attempting to connect to [Event Streams](glossary.md#event-streams) you receive SSL errors. In Java you might get this exception `sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target`. With curl you get this error `SSL Certificate: Invalid certificate chain`.  

**Cause:** the Enterprise Event Streams brokers use a certificate signed by` issuer=C = US, O = Let’s Encrypt, CN = Let’s Encrypt Authority X3`  which is different then Standard versions. Whatever client is connecting to Event Streams is missing the Let's Encrypt public certificate. For Java, this certificate was added in version `8u101`.  

**Fix:** add the Let's Encrypt public certificate to your trusted root certificates. This varies depending on what technology you are using. Java comes with it's own 'truststore' with root certificates and all operating systems also store root certificates. The Let's Encrypt certificates can be downloaded [here](https://letsencrypt.org/certificates/). There are several guides online for adding certificates to the Java trust store. Here's [one](https://docs.oracle.com/javase/tutorial/security/toolsign/rstep2.html) from Oracle. Here is a [guide](https://bounca.org/tutorials/install_root_certificate.html) for several operating systems.
