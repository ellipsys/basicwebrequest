function Invoke-BasicWebRequest {
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

    $request = [System.Net.WebRequest]::Create($URL)
    $request.UserAgent = $UserAgent
    $request.Accept = "*/*"

    # Proxy settings
    if ($ProxyURL) { 
        $proxy = New-Object System.Net.WebProxy
        $proxy.Address = $ProxyURL
        $request.Proxy = $proxy

        if ($ProxyUser) {
            if ($ProxyDefaultCredentials) {
                $request.UseDefaultCredentials = $true
                Write-Verbose "Established proxy URL to $ProxyURL and using default credentials"
            }
            else {
                $secure_password    = ConvertTo-SecureString $ProxyPassword -AsPlainText -Force;
                $proxy.Credentials  = New-Object System.Management.Automation.PSCredential ($ProxyUser, $secure_password);

                Write-Verbose "Established proxy URL to $ProxyURL and using $ProxyUser credentials"
            }
        }
        else { Write-Verbose "Established proxy URL to $ProxyURL" }
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