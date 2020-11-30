# Troubleshooting

[**Management API issues**](#management-api-issues)
<br>[Authentication is possible but has failed or not yet been provided](#authentication-is-possible-but-has-failed-or-not-yet-been-provided)

[**Event Streams issues**](#event-streams-issues)
<br>[SSL certificate issues](#ssl-certificate-issues)

## Management API issues

### Authentication is possible but either has failed or not yet been provided

**Problem** 

The Management API responds with this error: 
```json
{
  "code": "2cde977c23b3ab78befed56a6aac3820",
  "error": "Authentication is possible but has failed or not yet been provided."
}
```

**Symptom** 

The [IBM&reg; Functions](glossary.md#ibm-cloud-functions) API Gateway is unable to authenticate with the backend IBM Function Actions. Actions have an API key and the API Gateway must be configured to use that API key. Typically, this is due either to the API Gateway missing an API key or to having the wrong API key.

**Resolving the problem** 

**Option 1: Try redeploying the Management API.** 

This generates a new API key and sets it on the Actions endpoint and the API Gateway endpoint.

**Option 2: Manually update the API endpoints.**

1. You'll need the IBM Cloud CLI and Functions plugin. For steps to install them, see [Installing the CLI and plug-in](https://cloud.ibm.com/docs/openwhisk?topic=openwhisk-cli_install).
2. Set the CLI resource group to where the Management API is deployed: 
   ```
   ibmcloud target -g <*resource_group*>
   ```
3. Set the CLI Functions namespace to where the Management API is deployed:
   ```
   ibmcloud fn property set --namespace <*namespace*>
   ```
4. Change the tag to match your release.
5. Download [updateApi.sh](https://github.com/Alvearie/hri-mgmt-api/blob/master/updateApi.sh).
6. Run the downloaded script:
   ```
   ./updateApi.sh
   ```

**Option 3: Manually update the API gateway JSON configuration.**

1. Follow steps 1 - 3 above to set up the IBM CLI.
2. Download the API JSON configuration:
   ```
   ibmcloud fn api get hri-batches > api.json
   ```
3. Get the API key set for the Actions. Run: 
   ```
   ibmcloud fn package get hri_mgmt_api
   ```
   The output should have a `"require-whisk-auth"` entry for each action. It should be the same value for every action. Example:
   ```json
        {
            "key": "require-whisk-auth",
            "value": "hIadvQ8w4nkJeWa3i7OPDb9WqTAUV9d6"
        },
   ```
4. Edit the `api.json` file, and add or replace the API key. There will be a `x-ibm-configuration` element and a couple levels down an array of `execute` elements, one for each endpoint. Each of these needs to have a `set-variable.actions` element that sets `message.headers.X-Require-Whisk-Auth` to the API key. Make sure there is one for every endpoint and that they match the API keys from step 3. 
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

## Event Streams issues

### SSL certificate issues

**Problem** 

When attempting to connect to [Event Streams](glossary.md#event-streams), you receive SSL errors. In Java, you might get this exception:

`sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target`. 

With curl, you get this error:

`SSL Certificate: Invalid certificate chain`.  

**Symptom** 

The Enterprise Event Streams brokers use a certificate signed by` issuer=C = US, O = Let’s Encrypt, CN = Let’s Encrypt Authority X3`, which is different than Standard versions. The client that is connecting to Event Streams is missing the Let's Encrypt public certificate. For Java, this certificate was added in version `8u101`.  

**Resolving the problem** 

Add the Let's Encrypt public certificate to your trusted root certificates. This varies depending on what technology you are using. Java comes with its own truststore, which contains root certificates. In addition, all operating systems store root certificates. 

You can download Let's Encrypt certificates [here](https://letsencrypt.org/certificates/). 

For guidance on adding certificates to the Java truststore, see these guides online:

Oracle&reg;: [Import the Certificate as a Trusted Certificate](https://docs.oracle.com/javase/tutorial/security/toolsign/rstep2.html)  
BounCA: [Guide to add self-generated root certificate authorities for 8 operating systems and browsers](https://bounca.org/tutorials/install_root_certificate.html) 