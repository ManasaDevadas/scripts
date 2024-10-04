#!/bin/bash

# Variables

#startTime=$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ)
#endTime=$(date -u +%Y-%m-%dT%H:%M:%SZ)
startTime=2024-08-29T10:15:00Z
endTime=2024-08-29T11:14:00Z
metricName='Composite Disk Read Bytes/sec'
aggregation="Average"
inputfilename='VMids'
outputfilename="VMDatadiskReadperSec"

n=1
while read line; do
# reading each line

# Get the list of data disks attached to the VM
diskIds=$(az vm show --ids $line --query "storageProfile.dataDisks[].managedDisk.id" -o tsv)


# Loop through each disk and get the "Composite Data Disk Read Bytes/Sec" metric
for diskId in $diskIds; do
    diskName=$(basename $diskId)
    echo "Metrics for disk: $diskName"
    
	maxavgDatadiskReadperSec=$(az monitor metrics list --resource $diskId --metric "$metricName" --aggregation $aggregation --start-time $startTime --end-time $endTime --query "max_by(value[0].timeseries[0].data[?average != null], &average).{maxavgDatadiskReadperSec:average, timeStamp:timeStamp}" -o tsv)
	echo $maxavgDatadiskReadperSec
	vm_maxvalue="${line} ${diskName} ${maxavgDatadiskReadperSec}"
	echo "$vm_maxvalue" >> $outputfilename
done

n=$((n+1))
done < $inputfilename
