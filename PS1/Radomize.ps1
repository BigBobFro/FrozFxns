## Set a random order without repeating last $DontRepeat items


Function RandomizeAssignment{
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
}




