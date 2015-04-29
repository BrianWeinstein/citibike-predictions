#!/bin/bash
#
# Description:
#   Fetches trip files from the Citibike site http://www.citibikenyc.com/system-data
#   e.g., https://s3.amazonaws.com/tripdata/201407-citibike-tripdata.zip
#
# Usage: ./download_citibike_trips.sh
#
# Requirements: curl or wget
#
# Source: Adapted from Jake Hofman's https://github.com/jhofman/msd2015/blob/master/lectures/lecture_2/download_trips.sh
#

# Set a relative path for the Citibike data (uses current directory by default)
DATA_DIR=.

# Retrieve list of all 2014 trip data file urls
urls=`curl 'http://www.citibikenyc.com/system-data' | grep '2014.*tripdata.zip' | cut -d'"' -f2` # all 2014 urls

# Change to the data directory
cd $DATA_DIR

# Loop over each month
for url in $urls
do
    # Download the zip file
    curl -O $url

    # Define local file names
    file=`basename $url`
    csv=${file//.zip/}".csv"

    # Unzip the downloaded file, remove header lines, include only relevant columns,
    # remove minute and second from timestamp, group/count each unique line, and save as csv
    unzip -p $file | sed 1d | cut -d, -f2,4 | sed 's/:[0-9][0-9]:[0-9][0-9]//g' | sort | uniq -c > $csv

    # Remove the zip file
    rm $file
done

# Concatenate montly files into one file, insert commas, delete quotes
cat $(ls *tripdata.csv) | sed 's/ "/,/g' | tr -d '"' > all_2014_trips.csv

# Remove the montly csv files
rm *tripdata.csv

