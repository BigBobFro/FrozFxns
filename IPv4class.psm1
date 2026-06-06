<#
.TITLE
    IPv4 Class and useful functions; Part of Fro's Functions (FrozFxns)

.DESCRIPTION
    A collection of useful functions created and curated by da Fro

.NOTES
    Author      :   Fro
    Date        :   01 June 2026
    Git         :   https://github.com/BigBobFro
    Version     :   1.0

.CHANGELOG
    1.0         = [01 Jun 2026] Module created
    1.1         = [05 Jun 2026] Text to List Function added

.USAGE
    Include "Include-module '<path>\IPv4class.psm1'" near the beginning 
    of any script and call these functions as if they were defined within your own code.

    See code for individual function usage

.LICENSE
    Free to use as long as it is kept whole to preserve authorship
    If includes are impossible in a secure environment, sections of code may be used, so long as
        they are cited via comments in the code where they are used.

#>

Class IPv4{
    [int]$Oct1
    [int]$Oct2
    [int]$Oct3
    [int]$Oct4

    IPv4([string]$ipIN){
        $octets = $ipIN.Split(".")
        if ($octets.Count -eq 4) {
            $this.Oct1 = [int]$octets[0]
            $this.Oct2 = [int]$octets[1]
            $this.Oct3 = [int]$octets[2]
            $this.Oct4 = [int]$octets[3]
        } 
        else { Write-Error "Invalid IP address format: $ipIN" }
    }
    [void] Validate(){
        $InvalidProps = @()
        foreach($prop in @("Oct1","Oct2","Oct3","Oct4")){
            if($this.$prop -lt 0 -or $this.$prop -gt 255){ $InvalidProps += $prop }
        }
        if ($InvalidProps) {
            $Message = "Invalid IP address values for properties: $($InvalidProps -join ', ')`nValues must be between 0 and 255."
            throw $Message
        }
    }
    [string] ToBITS(){
        $bits1 = [Convert]::ToString($this.Oct1, 2).PadLeft(8, '0')
        $bits2 = [Convert]::ToString($this.Oct2, 2).PadLeft(8, '0')
        $bits3 = [Convert]::ToString($this.Oct3, 2).PadLeft(8, '0')
        $bits4 = [Convert]::ToString($this.Oct4, 2).PadLeft(8, '0')
        return "$bits1 $bits2 $bits3 $bits4"
    }
    [string] ToString(){ return "$($this.Oct1).$($this.Oct2).$($this.Oct3).$($this.Oct4)" }
    [bool] Before([ipv4]$that){
        if($this.Oct1 -lt $that.Oct1){ return $true }
        elseif($this.Oct1 -eq $that.Oct1){
            if($this.Oct2 -lt $that.Oct2){ return $true }
            elseif($this.Oct2 -eq $that.Oct2){
                if($this.Oct3 -lt $that.Oct3){ return $true }
                elseif($this.Oct3 -eq $that.Oct3){
                    return $($this.Oct4 -lt $that.Oct4)
                }
            }
        }
        return $false
    }
    [bool] Same([ipv4]$that){
        return $(($this.Oct1 -eq $that.Oct1) -and `
                ($this.Oct2 -eq $that.Oct2) -and `
                ($this.Oct3 -eq $that.Oct3) -and `
                ($this.Oct4 -eq $that.Oct4))
    }
    [bool] After([ipv4]$that){
        if($this.Oct1 -gt $that.Oct1){ return $true }
        elseif($this.Oct1 -eq $that.Oct1){
            if($this.Oct2 -gt $that.Oct2){ return $true }
            elseif($this.Oct2 -eq $that.Oct2){
                if($this.Oct3 -gt $that.Oct3){ return $true }
                elseif($this.Oct3 -eq $that.Oct3){
                    return $($this.Oct4 -gt $that.Oct4)
                }
            }
        }
        return $false
    }
    [IPv4] Increment([int]$num){
        $debug = $false
        [ipv4]$current = $this
        
        if($debug){ write-host "Current IP: $current | Num: $num" }
        if($num -lt 0){ 
            <# Subtraction #> 
            for($i = 0; $i -gt $num; $i--){
                if($debug){ write-host "Current IP: $current | Num: $num | Counter: $i" }
                if($current.Oct4 -eq 0) {
                    $current.Oct4 = 255
                    if($current.Oct3 -eq 0){
                        $current.Oct3 = 255
                        if($current.Oct2 -eq 0){
                            $current.Oct2 = 255
                            if($current.oct1 -eq 0){ $current.Oct1 = 0}
                            else{ $current.Oct1-- }
                        }
                        else { $current.Oct2-- }
                    } else { $current.Oct3-- }
                } else { $current.Oct4-- }
            }
            RETURN $($current)
        } else { 
            <# Addition #> 
            for($i = 0; $i -lt $num; $i++){
                if($debug){ write-host "Current IP: $current | Num: $num | Counter: $i" }
                if($current.Oct4 -eq 255) {
                    $current.Oct4 = 0
                    if($current.Oct3 -eq 255){
                        $current.Oct3 = 0
                        if($current.Oct2 -eq 255){
                            $current.Oct2 = 0
                            if($current.oct1 -eq 255){ $current.Oct1 = 255}
                            else{ $current.Oct1++ }
                        }
                        else { $current.Oct2++ }
                    } else { $current.Oct3++ }
                } else { $current.Oct4++ }
            }
            RETURN $($current)
        }
    }
    [string] Clear(){
        $this.Oct1 = $null
        $this.Oct2 = $null
        $this.Oct3 = $null
        $this.Oct4 = $null
        RETURN [VOID]
    }
}

Function TextToList{
    # Takes a string and returns an array of the IPv4 addresses contained within it
    param([string]$inString = $null)
    
    [array]$outputArray = @()
    
    if([string]::IsNullOrEmpty($inString)){ write-host "Nothing passed.  Nothing to do."; exit 37 }
    else {
        $workingString = $inString.replace("`n",",")
        $units = $workingString.split(",")

        $SingleHost = 0
        $RangeCount = 0

        foreach($unit in $units){
            if($unit.IndexOf("-") -lt 0){
                ## Single IP address
                if($unit -as [ipv4]){
                    $outputArray += [ipv4]$unit
                    $singleHost++
                } else { write-host "Invalid IP address format: $unit" }
            } else {
                if($debug){ write-host "IP Range: $unit";$rangecount++ }
                ## Range of IP Addresses
                $RangeParts = $Unit.split("-")
                [ipv4]$startIP = $RangeParts[0]
                [ipv4]$endIP = $RangeParts[1]
                [ipv4]$current = $StartIP
                
                $exitLoop = $false
                do{
                    if($debug){ write-host "Current IP: $current" }
                    if($current.Oct1 -eq $endIP.Oct1){
                        if($debug){write-host "Oct1 Match"}
                        if($current.Oct2 -eq $endIP.Oct2){
                            if($debug){write-host "Oct1-2 Match"}
                            if($current.Oct3 -eq $endIP.Oct3){
                                if($debug){ write-host "Oct1-3 Match" }
                                $outputArray += $current
                                $current.Oct4++
                            } else {
                                if($debug){ write-host "Oct3 no Match" }
                                $outputArray += $current
                                if($current.Oct4 -eq 255){
                                    $current.Oct3++
                                    $current.Oct4 = 0
                                } else { $current.Oct4++ }
                            }
                        } else {
                            if($debug){ write-host "Oct2 no Match" }
                            $outputArray += $current
                            if($current.Oct4 -eq 255){
                                if($current.Oct3 -eq 255){
                                    $current.Oct2++
                                    $current.Oct3 = 0
                                } else { $current.Oct3++}
                                $current.Oct4 = 0
                            } else { $current.Oct4++ }
                        }
                    } else{
                        if($debug){ write-host "Oct1 no Match" }
                        $outputArray += $current
                        if($current.Oct4 -eq 255){
                            if($current.Oct3 -eq 255){
                                if($current.Oct2 -eq 255){
                                    $current.Oct1++
                                    $current.Oct2 = 0
                                } else { $current.Oct2++ }
                                $current.Oct3 = 0
                            } else { $current.Oct3++}
                            $current.Oct4 = 0
                        }
                    }

                    ## Loop Breakers
                    $tempb4 = $($current.Before($endIP))
                    $tempSA = $($current.Same($endIP))
                    if($debug){ write-host "Before: $tempb4 | Same: $tempSA" }
                    if($tempb4){
                        if($debug){ write-host "Running B4" }
                        $ExitLoop = $false
                    } elseif($tempSA){
                        if($debug){ write-host "Running Same" }
                        $outputArray += $current
                        $ExitLoop = $true
                    } else { $ExitLoop = $true }
                } until ($ExitLoop)
            }
        }
    }
    if($debug){ write-host "Stats == Single Hosts: $singleHost | Ranges: $RangeCount" }
    RETURN $outputArray
}