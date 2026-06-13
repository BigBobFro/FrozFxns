<#
.TITLE
    Fro's Functions (FrozFxns)

.DESCRIPTION
    A collection of useful functions created and curated by da Fro

.NOTES
    Author      :   Fro
    Date        :   23 October 2025
    Git         :   https://github.com/BigBobFro/FrozFxns
    Version     :   1.6

.CHANGELOG
    1.0         = [23 Oct 2025] Module created
    1.5         = [01 Jun 2026] Added StdDeviation function
    1.6         = [13 Jun 2026] Added RandomizeAssignment Function

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
    if($dataSet -eq $null){ RETURN $null }
    elseif($dataset.count -le 1){ RETURN 0 }
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


Function RandomizeAssignment{
    ## Requires StdDeviation
    param( 
        $ListLength     = 300,
        $DontRepeat     = 5,
        $sdThreshold    = 3,
        $SeedList       = @(),
        $previousSkips  = @()
    )
    
    if($seedlist.count -le $DontRepeat){
        THROW "DontRepeat cannot exceed the quantity of values in SeedList."
        RETURN $null
    }

    if($previousSkips.Count -gt 0){ $OutputList = $previousSkips; $startSeed = $previousSkips.count - 1}
    else { $OutputList = @();$startSeed = 0 }

    $stats = $null
    $RepeatIcounter = 0
    $totalRepeats   = 0
    $BreakStuckCount = 0
    $MaxRepeatCounter = $RepeatIcounter
    for ($i = $startSeed; $i -lt $($ListLength + $startSeed); $i++) {
        $GoodOutput = $false
        $breakStuck = $false
        do{
            $getRand = $SeedList | get-random
            if( $($OutputList[$($i-$DontRepeat)..$($i-1)]) -notcontains $getRand){ ## Not Repeated
                ## Calculate Current Statistics
                $valueList = @{} ## Recreate valueList eachtime for accurate stats  ## Rebuild later to add stats directly
                foreach ($item in $($OutputList | select -unique)){ $valueList.add($item, $($($OutputList | ? {$_ -eq $item}).count))}
                $stats = $($($valueList.Values) | Measure-Object -Average -Maximum -Minimum -Sum)
                $sd = stdDeviation -dataSet $valueList.Values

                if($debug){         ## Output variable calculations for debugging
                    if($sd -ge $sdThreshold){ 
                        write-host "SD too high: $sd" 
                    }
                    write-host "Iteration: $i"
                    write-host "OutputList: $($outputlist.count)"
                    write-host "Random: $getRand ( $($valueList[$getRand]) )"
                    write-host "Min/Avg/Max: $($stats.Minimum) $($valuelist.keys|?{$($valuelist[$_]) -eq $stats.Minimum})" -nonewline
                    write-host " / $($stats.Average) / $($stats.Maximum) $($valuelist.keys|?{$($valuelist[$_]) -eq $stats.Maximum})"
                    write-host "SD: $sd ($sdThreshold)"
                    write-host "`n"
                }

                if($breakStuck){                
                    ## used only when over SD threshold and all non-Max values are within dontrepeat range
                    $OutputList += $getRand
                    $breakstuck = $false
                    $GoodOutput = $true
                }elseif($($valueList[$getRand] -ne $stats.Maximum) -and $($sd -ge $sdThreshold)){ 
                    ## Add if getRand is not a max count value when SD is over sdThreshold
                    $outputList += $getRand
                    $GoodOutput = $true
                    $RepeatIcounter = 0
                } elseif($($valueList[$getRand] -le $($stats.Average + $sd)) -and $($sd -lt $sdThreshold)){ 
                    ## Add only if less than average and sd count is under sdThreshold
                    $outputList += $getRand
                    $GoodOutput = $true
                    $RepeatIcounter = 0
                } elseif($i -gt ($listLength * 0.75) -and $($valueList[$getRand] -eq $stats.Maximum)){ ## Don't Add to max if in last 25% of list
                    $GoodOutput = $false
                } else { $GoodOutput = $false}
            } else { $GoodOutput = $false }
            if(!$GoodOutput){ ## Can't add RandValue
                $RepeatIcounter++;$totalRepeats++
                if($MaxRepeatCounter -lt $RepeatIcounter){$MaxRepeatCounter = $RepeatIcounter}
                if ($RepeatIcounter -ge 30){
                    write-host "Stuck. Rand: $getRand"
                    $breakStuck = $true; $BreakStuckCount++
                }
            }
        } until ($GoodOutput)
    }
    if($debug){write-host "Max Repeat Counter: $maxrepeatcounter`nTotal Repeats: $totalrepeats`nBreakStuck: $breakstuckcount"}
    RETURN $OutputList
    <# FOR TESTING AND DEBUGGING THIS FUNCTION
        
        $SeedList = $('Alan','Bob','Charlie','David','Edd','Frank','Gordon','Hank','Ian','Joe','Kevin','Lenny','Mike')
        $startTime = Get-Date
        $AssignmentList = RandomizeAssignment -ListLength 300 -DontRepeat 7 -SeedList $SeedList -sdThreshold 3
        write-host "Time Elapsed: $($($(get-date) - $startTime).ToString())`n"

        $valueList = @{}
        foreach ($num in $($AssignmentList | select -unique)){
            $valueList.add($num, $($($AssignmentList | ? {$_ -eq $num}).count))
        }
        $stats = $valuelist.Values | Measure-Object -Average -Maximum -Minimum
        $sd = stdDeviation -dataSet $valueList.Values

        write-host "$($stats.Minimum) \ $($stats.Average) \ $($stats.Maximum)`n$sd`n"
        foreach ($num in $($AssignmentList | select -unique)){
            write-host "$num : $($($AssignmentList | ? {$_ -eq $num}).count) "
        }
    #>

}


