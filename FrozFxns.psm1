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
	
    if (($items -eq $null) -or ($iWClist -eq $null) -or ($xWCList -eq $null))
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