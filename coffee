#!/bin/bash
# Script to create daily logs and push to Google Drive for review

# Store line break
lineBreak="-------------------------------------------------------------"

# Store date as a variable in the format mm-dd-yy
dateOnly=$(date +%m-%d-%y)

# Store date and time as a variable in the format yyyy_mm_dd_HH:MM
dateTime=$(date +%Y_%m_%d_%R)

# Store drive path (edit with config file)
drivePath=/home/kyle/gdrive/"IT Documents"/Legacy/Logs/MorningCoffee

# Create unique name for system health log
logName=$dateTime"_Daily_Log_Report.log"
# Creat unique name for log scan report
logScanName=$dateTime"_Daily_Log_Scan.log" 

# Create save path for log text file
savePath="$drivePath/$logName"
# Create save path for log scan report
logScanSavePath="$drivePath/LogScans/$logScanName"

# Create report URLs
reportUrl="https://drive.google.com/drive/u/0/folders/1ijvVYEwb5aRu4rNoM79UeKwXGBHdMSvP"
reportUrlLogScan="https://drive.google.com/drive/u/0/folders/1yIvVib7FMDFiufnHppWca-gYzJDGvpg3"

# Change directory to use drive
# cd "$drivePath"

echo "Kyle, please stand by for your morning report"
echo "$lineBreak"
echo "Time of report: $dateTime"
echo ""
echo "Access report locally:"
pwd
echo "$lineBreak"

# Run CWdskscan and create/append to log
echo "Performing CloudWatch Disk Utilization scan..."
echo $(cwdskscan_auto) >> "$savePath"
echo "...Disk Utilization scan complete"
echo ""

# Run CWmemscan and create/append to log
echo "Performing CloudWatch Memory Utilization scan..."
echo $(cwmemscan_auto) >> "$savePath"
echo "...Memory Utilization scan complete"
echo ""

# Run CWcpuscan and create/append to log
echo "Performing CloudWatch CPU Utilization scan..."
echo $(cwcpuscan_auto) >> "$savePath"
echo "...CPU Utilization scan complete"
echo ""

# Run CWAVscan and append to log
echo "Performing CloudWatch ClamAV scan..."
echo "...this may take a few minutes..."
echo $(cwavscan_auto) >> "$savePath"
echo "...CloudWatch ClamAV scan complete"
echo ""

# Run CWlogscan and create/append to log scan log
echo "Performing CloudWatch Log Stream scan..."
echo "...this may take a few minutes..."
echo $(cwlogscan_auto) >> "$logScanSavePath"
echo "...CloudWatch Log Stream scan complete"
echo ""

# Push log report to Google Drive with no user prompt
drive push -quiet "$logName"
# Push log scan to Google Drive with no user prompt
drive push -quiet "LogScans/$logScanName"

# Change files to read only
chmod -w "$logName"
chmod -w "LogScans/$logScanName"

echo "Your reports are complete"
echo "$lineBreak"
echo "Access system health report online:"
echo "$reportUrl"
echo "Access log scan report online:"
echo "$reportUrlLogScan"

# Email reports to productionalerts@evericheck.atlassian.net
cat "$logName" | mail -s "System Health Report" productionalerts@evericheck.atlassian.net
cat "LogScans/$logScanName" | mail -s "Log Scan Report" productionalerts@evericheck.atlassian.net

# Automatically open base folder to view log:
firefox -new-tab -url https://drive.google.com/drive/u/0/folders/1ijvVYEwb5aRu4rNoM79UeKwXGBHdMSvP
