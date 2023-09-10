# Getting started

Start Azurite in VSCode
 
```powershell
$env:WEBAPP_URI="https://<domain>.azurewebsites.net"
```

To run Functions App as part of your Inner-loop:

```powershell
func start --debug
```

To record site navigation:

```powershell
pwsh ./node_modules/.bin/playwright.ps1 codegen $env:WEBAPP_URI
```

👆 to write navigation out to a file, include `-o filename` flag

To redeploy changes to Functions App:

```powershell
azd deploy func --debug
```