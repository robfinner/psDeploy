Set-StrictMode -Version 2
$ErrorActionPreference = 'Stop'

<#
    Deployment parameters
#>

$script:psDeploy = @{}
$script:psDeploy.Log = @{}

$script:psDeploy.Log.Name = 'MyApplication'
$script:psDeploy.Log.Journal = $null        # Path to the journal file (one entry per deployment)
$script:psDeploy.Log.Transcripts = $null    # Folder that holds the deployment transcripts


function deploy
{
    param
    (
        [object] $script,
        [object] $success,
        [object] $failure,
        [switch] $transcript,
        [switch] $journal
    )
    
    try
    {           
        if ($transcript) { startTranscript }
        
        execute $script 'deployment'
        execute $success 'success'
        
        if ($journal) { writeJournal 'SUCCESS' }
        Write-Host "`n-----Deployment sucessful`n"
    }
    catch
    {
        showErrorDetails $_
        execute $failure 'failure'
        
        if ($journal) { writeJournal 'FAILED' }
        
        Write-Host ''
        Write-Warning "`n-----Deployment failed`n"
        
        Write-Host ''
        Write-Error "`n-----Deployment failed`n"
        
    } 
    finally
    {
        if ($transcript) { stopTranscript }
        Write-Host ''
    }   
}


function execute($code, $name)
{
    if ($code -ne $null)
    {
        if ($code.GetType() -eq [scriptblock])
        {
            Write-Host "`n----- Executing $name script`n"
            & $code
        }
        elseif ($code.GetType() -eq [string])
        {
            Write-Host "`n----- Executing $name function`n"
            
            try
            {
                $function = gi function:$code
            }
            catch [System.Management.Automation.ItemNotFoundException]
            {
                throw "Cannot find function '$code'"
            }
            
            & $function
        }
        else
        {
            Write-Error "Could not execute the following object: $code"
        }
    }
}


function startTranscript
{
    if ($script:psDeploy.Log.Transcripts -ne $null)
    {
        Start-UniqueTranscript -Path $script:psDeploy.Log.Transcripts -Name $script:psDeploy.Log.Name -AppendDate
    }
}


function stopTranscript
{
    if ($script:psDeploy.Log.Transcripts -ne $null)
    {
        Stop-UniqueTranscript
    }
}


function writeJournal($status)
{
    $entry = Get-JournalEntry -Application $script:psDeploy.Log.Name -Status $status -ScriptName $myInvocation.ScriptName
    
    if ($script:psDeploy.Log.Journal -ne $null)
    {
        $entry | Out-File $script:psDeploy.Log.Journal
    }
}


function showErrorDetails($error)
{
    $message = "`n`n" + ('-' * 20)
    $message += "`nAt line:       " + $error.InvocationInfo.Line.Trim()
    $message += "`nError details: " + $error
    $message += "`n" + ('-' * 20)
    
    Write-Warning $message
}


Export-ModuleMember -Variable 'psDeploy'
Export-ModuleMember -Function 'deploy'
