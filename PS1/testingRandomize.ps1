<#
Test RandomizeAssignment Function
#>

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