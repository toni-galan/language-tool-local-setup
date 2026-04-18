# Install LanguageTool on Windows (script)

This guide explains how to install LanguageTool locally on Windows using the
script `install.ps1`. It also covers how to install and configure the browser
extension to use your local server.

## Script

Download the script located at `windows/install.ps1`.

### Opening PowerShell as administrator

Click the **Start menu**, search for **PowerShell**, right-click on it and
select **Run as administrator**

![Open Powershell as administrator](windows/image-3.png)

Now run the script. It will automatically:
- Install Java if not already installed
- Download and extract LanguageTool
- Start the local server on port 8081
- Configure LanguageTool to start automatically on every login

## Extension

Once the server is running, you need to configure the LanguageTool browser
extension to use your local server instead of the cloud.

If you don't have the extension installed yet, get it from the
[Chrome Web Store](https://chromewebstore.google.com/detail/corrector-ortogr%C3%A1fico-y-g/oldceeleldhonbafppcapldpdifcinji?hl=es).

### Configuring the extension

Click on the extension icon → **three dots** → **Options**

![Extension options menu](windows/image.png)

Scroll to the bottom of the page and click **Advanced settings**

![Advanced settings button](windows/image-1.png)

Change **Cloud server** to **Local server** and click **Save**

![Local server setting](windows/image-2.png)

That's it. The extension will now use your local LanguageTool server.

> **Note:** make sure the LanguageTool server is running before using the
> extension. After the first reboot it will start automatically on login.