<#
.TITLE
    Fro's Functions (FrozFxns)

.DESCRIPTION
    A collection of useful functions created and curated by da Fro

.NOTES
    Author      :   Fro
    Date        :   23 October 2025
    Git         :   https://github.com/BigBobFro
    Version     :   1.0

.CHANGELOG
    1.0         = [23 Oct 2025] Module created
    1.5         = [01 Jun 2026] Added StdDeviation function

.USAGE
    Include "Include-module '<path>\FrozFxns.psm1'" near the beginning 
    of any script and call these functions as if they were defined within your own code.

    See code for individual function usage

.LICENSE
    Free to use as long as it is kept whole to preserve authorship
    If includes are impossible in a secure environment, sections of code may be used, so long as
        they are cited via comments in the code where they are used.

#>


Function JustTheName{
    param([string]$inPath)
    # Takes a full file path and returns just the name of the file with no extension (.xxx)

    $finalIndex = $inPath.LastIndexOf("\")
    $onlyName = $inPath.substring($finalIndex + 1, $inPath.Length - $finalIndex - 5)

    RETURN $onlyName
}

Function JustTheFileName{
    param([string]$inPath)
    # Takes a full file path and returns just the name of the file with no extension (.xxx)

    $finalIndex = $inPath.LastIndexOf("\")
    $onlyName = $inPath.substring($finalIndex + 1, $inPath.Length - $finalIndex - 1)

    RETURN $onlyName
}

Function JustTheNumbers{
    # Returns array of integers from a text string provided.  May include other text as well
    param(
        [string]$inString = $null
    )
    [array]$outputArray = @()

    if($null -eq $instring){
        # ERROR
        RETURN $null
    }
    else {
        # The minus 1 in string length is to account for counting from zero
        for($i=0; $i -le $($inString.Length - 1); $i++){
            if(($inString[$i]) -match '^\d+$'){
                # char is a number
                [string]$tempString = $inString[$i]

                do{     # Grabbing for multi-digit numbers
                    $i++
                    if(($inString[$i]) -match '^\d+$'){
                        $tempString += $inString[$i]
                    }
                } until( !$($($inString[$i]) -match '^\d+$'))
                $outputArray += [int]$tempString

            }# ELSE {Char is a non-number; do nothing}
        }
    }
    RETURN $outputArray
}

function CompArray{
    # Search for items against included and excluded lists
	param($items = $null, $iWClist = $null, $xWCList = $null)
    [array]$retlist = $null
    
	"Include: $iwclist" | out-file -filepath $logfile -append
	"Exclude: $xwclist" | out-file -filepath $logfile -append
	
    if (($null -eq $items) -or ($null -eq $iWClist) -or ($null -eq $xWCList))
        {$retlist = $null}
    else
    {
		
        foreach($item in $items)
        {
            $included = $false
            $excluded = $false
            foreach ($inc in $iWClist) {if (!$included) {$included = $($item.name -like $inc)}}
            foreach ($x in $xWCList)   {if (!$excluded) {$excluded = $($item.name -like $x)}}
            if ($included -and $(!$excluded) -and $($retlist -notcontains $item)) {$retlist += $item}
        }
    }
    return $retlist
}

Function ExpandAll{
	# Expand all archives in a given directory
	param([string]$inPath = $null)
	$items = Get-ChildItem $inPath | ? {$_.name -like "*.zip"}
	$items | % { expand-archive -path $($_.name) -DestinationPath ".\$($($_.name).substring(0,$_.name.length -4))"}
}
	

Function StdDeviation{
    # Returns the standard deviation of an array of numbers
    param([array]$dataSet = $null)

    $decPlaces = 2
    $decFactor = [math]::Pow(10, $decPlaces)
    if($dataSet -eq $null){
        RETURN $null
    }
    else {
        $mean = ($dataSet | Measure-Object -Average).Average
        $stdDev = [math]::Sqrt( $( $( $dataSet | % { [math]::pow( $([math]::abs( $_ - $mean ) ), 2) }) | measure-object -sum ).sum )

        ## Trunc to DecPlaces above
        $stdDev = $([math]::Truncate($($stdDev * $decfactor)))/ $decFactor
        RETURN $stdDev
    }

    <#      FOR DEBUGGING THIS FUNCTION ONLY
        [array]$nums = @()
        for($i=0; $i -le 100; $i++){
            $nums += get-random -Minimum 1 -Maximum 1000
        }

        $Calcs = $nums | Measure-Object -Average -Minimum -Maximum
        stdDeviation -dataSet $nums
    #>

}