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
        else {Write-Error "Invalid IP address format: $ipIN"}
    }
    [void]Validate(){
        $InvalidProps = @()
        foreach($prop in @("Oct1","Oct2","Oct3","Oct4")){
            if($this.$prop -lt 0 -or $this.$prop -gt 255){
                $InvalidProps += $prop
            }
        }
        if ($InvalidProps) {
            $Message = "Invalid IP address values for properties: $($InvalidProps -join ', ')`nValues must be between 0 and 255."
            throw $Message
        }
    }
    [string]toBITS(){
        $bits1 = [Convert]::ToString($this.Oct1, 2).PadLeft(8, '0')
        $bits2 = [Convert]::ToString($this.Oct2, 2).PadLeft(8, '0')
        $bits3 = [Convert]::ToString($this.Oct3, 2).PadLeft(8, '0')
        $bits4 = [Convert]::ToString($this.Oct4, 2).PadLeft(8, '0')
        return "$bits1 $bits2 $bits3 $bits4"
    }
    [string]toString(){return "$($this.Oct1).$($this.Oct2).$($this.Oct3).$($this.Oct4)"}
    [string]Before([ipv4]$that){
        if($this.Oct1 -lt $that.Oct1){return $true}
        elseif($this.Oct1 -eq $that.Oct1){
            if($this.Oct2 -lt $that.Oct2){return $true}
            elseif($this.Oct2 -eq $that.Oct2){
                if($this.Oct3 -lt $that.Oct3){return $true}
                elseif($this.Oct3 -eq $that.Oct3){
                    return $($this.Oct4 -lt $that.Oct4)
                }
            }
        }
        return $false
    }
    [string]same([ipv4]$that){
        return $(($this.Oct1 -eq $that.Oct1) -and `
                ($this.Oct2 -eq $that.Oct2) -and `
                ($this.Oct3 -eq $that.Oct3) -and `
                ($this.Oct4 -eq $that.Oct4))
    }
    [string]After([ipv4]$that){
        if($this.Oct1 -gt $that.Oct1){return $true}
        elseif($this.Oct1 -eq $that.Oct1){
            if($this.Oct2 -gt $that.Oct2){return $true}
            elseif($this.Oct2 -eq $that.Oct2){
                if($this.Oct3 -gt $that.Oct3){return $true}
                elseif($this.Oct3 -eq $that.Oct3){
                    return $($this.Oct4 -gt $that.Oct4)
                }
            }
        }
        return $false
    }
    [string] clear(){
        $this.Oct1 = $null
        $this.Oct2 = $null
        $this.Oct3 = $null
        $this.Oct4 = $null
        RETURN [VOID]
    }
}


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