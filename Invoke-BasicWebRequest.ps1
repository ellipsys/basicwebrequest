function Invoke-BasicWebRequest {
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [String]
        $URL,

        [Parameter(Mandatory=$false)]
        [String]
        $UserAgent = 'Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; AS; rv:11.0) like Gecko'
    )

    $request = [System.Net.WebRequest]::Create($URL)
    $request.UserAgent = $UserAgent
    $request.Accept = "*/*"
    try {
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
        $response = $_.Exception.Response
        $response_status_code = [int](([regex]::Match($_.Exception.InnerException,"\b\d{3}\b")).value)

        $out = New-Object -TypeName PSObject
        $out | Add-Member -MemberType NoteProperty -Name StatusCode -Value $response_status_code
        $out | Add-Member -MemberType NoteProperty -Name Content -Value $null
        $out
    }
}