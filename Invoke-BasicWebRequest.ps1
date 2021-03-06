function Invoke-BasicWebRequest {
    <#

    .SYNOPSIS
        Basic and simple HTTP GET WebRequest. Very similar (but simplest) version of Invoke-WebRequest, which is only available in PowerShell v3+.

    .PARAMETER URL
        [String], required=true, ValueFromPipeline=$true

        URL to download. e.g.: google.com

    .PARAMETER UserAgent
        [String], required=false

        User-Agent custom string. By default it will use 'Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; AS; rv:11.0) like Gecko'

    .PARAMETER ProxyURL
        [String], required=false

        Proxy IP with optional port. E.g.: proxy.domain.corp:8080

    .PARAMETER ProxyUser
        [String], required=false

        Proxy user.

    .PARAMETER ProxyPassword
        [String], required=false

        Proxy user password.

    .PARAMETER ProxyDefaultCredentials
        [Switch], required=false

        Specify that proxy credential will be the default one.

    .OUTPUTS
        [PSObject]

        StatusCode Content
        ---------- -------
               200 <!doctype html><html itemscope="" itemtype="http://schema.org/WebPage" lang="es"><head><meta content="IE=edge" http-equiv="X-UA-Co...

    .EXAMPLE
        PS C:\> . .\Invoke-BasicWebRequest.ps1
        PS C:\> Invoke-BasicWebRequest google.com

        StatusCode Content
        ---------- -------
               200 <!doctype html><html itemscope="" itemtype="http://schema.org/WebPage" lang="es"><head><meta content="IE=edge" http-equiv="X-UA-Co...

    .EXAMPLE
        PS C:\> . .\Invoke-BasicWebRequest.ps1
        PS C:\> Invoke-BasicWebRequest google.com -ProxyURL proxy:8080 -ProxyUser pperez -ProxyPassword P@ssword!

        StatusCode Content
        ---------- -------
               200 <!doctype html><html itemscope="" itemtype="http://schema.org/WebPage" lang="es"><head><meta content="IE=edge" http-equiv="X-UA-Co...
    .LINK
        https://github.com/daniel0x00/basicwebrequest

    #>
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [String]
        $URL,

        [Parameter(Mandatory=$false)]
        [String]
        $UserAgent = 'Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; AS; rv:11.0) like Gecko',

        [Parameter(Mandatory=$false)]
        [String]
        $ProxyURL,

        [Parameter(Mandatory=$false)]
        [String]
        $ProxyUser,

        [Parameter(Mandatory=$false)]
        [String]
        $ProxyPassword,

        [Parameter(Mandatory=$false)]
        [Switch]
        $ProxyDefaultCredentials
    )

    # Ensure URLs contains at least an 'http' protocol:
    if (-not ($URL -match "http")) { $URL = 'http://'+$URL }
    if (($ProxyURL) -and (-not ($ProxyURL -match "http"))) { $ProxyURL = 'http://'+$ProxyURL }

    $request = [System.Net.WebRequest]::Create($URL)
    $request.UserAgent = $UserAgent
    $request.Accept = "*/*"

    # Proxy settings
    if ($ProxyURL) { 
        $proxy = New-Object System.Net.WebProxy
        $proxy.Address = $ProxyURL
        $request.Proxy = $proxy

        if ($ProxyDefaultCredentials) {
            $request.UseDefaultCredentials = $true
            Write-Verbose "Using default proxy credentials"
        }
        elseif ($ProxyUser) {
            $secure_password    = ConvertTo-SecureString $ProxyPassword -AsPlainText -Force;
            $proxy.Credentials  = New-Object System.Management.Automation.PSCredential ($ProxyUser, $secure_password);

            Write-Verbose "Using $ProxyUser proxy credentials"
        }
        else { Write-Verbose "Using proxy $ProxyURL" }
    }

    try {
        Write-Verbose "Trying to get $URL"

        $response               = $request.GetResponse()
        $response_stream        = $response.GetResponseStream();
        $response_stream_reader = New-Object System.IO.StreamReader $response_stream;
        $response_text          = $response_stream_reader.ReadToEnd(); 
        $response_status_code   = ($response.StatusCode) -as [int]

        $out = New-Object -TypeName PSObject
        $out | Add-Member -MemberType NoteProperty -Name StatusCode -Value $response_status_code
        $out | Add-Member -MemberType NoteProperty -Name Content -Value $response_text
        $out
    }
    catch {
        $response = $_.Exception.InnerException
        $response_status_code = [int](([regex]::Match($_.Exception.InnerException,"\((?<status_code>\d{3})\)")).groups["status_code"].value)

        $out = New-Object -TypeName PSObject
        $out | Add-Member -MemberType NoteProperty -Name StatusCode -Value $response_status_code
        $out | Add-Member -MemberType NoteProperty -Name Content -Value $response
        $out
    }
}