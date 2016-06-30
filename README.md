# Invoke-BasicWebRequest (@daniel0x00)
Basic HTTP GET implementation, similar (but very basic) to Invoke-WebRequest native PowerShell function (which is only available on PowerShell v3+).

## Description

It will return a PSObject with StatusCode and Content.

## Usage

Using the function in a computer with no proxy or proxy with no authentication
```
PS C:\> . .\Invoke-BasicWebRequest.ps1
PS C:\> Invoke-BasicWebRequest google.com

StatusCode Content
---------- -------
       200 <!doctype html><html itemscope="" itemtype="http://schema.org/WebPage" lang="es"><head><meta content="IE=edge" http-equiv="X-UA-Co...
``` 

Using the function in a computer with proxy authentication required
```
PS C:\> . .\Invoke-BasicWebRequest.ps1
PS C:\> Invoke-BasicWebRequest google.com -ProxyURL proxy:8080 -ProxyUser pperez -ProxyPassword P@ssword!

StatusCode Content
---------- -------
        200 <!doctype html><html itemscope="" itemtype="http://schema.org/WebPage" lang="es"><head><meta content="IE=edge" http-equiv="X-UA-Co...

``` 

![Invoke-BasicWebRequest](http://ferreira.fm/github/invoke-basicwebrequest/invoke-basicwebrequest.png "powershell basic webrequest statuscode")