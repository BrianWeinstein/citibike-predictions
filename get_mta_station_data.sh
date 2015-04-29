curl https://data.ny.gov/api/views/i9wp-a4ja/rows.csv |  cut -d , -f 2-16 > mta_station_data_raw.csv
(head -n 1 mta_station_data_raw.csv && tail -n +2 mta_station_data_raw.csv | sort | uniq) > mta_station_data.csv
rm mta_station_data_raw.csv

awk -F',' 'NR==1 {print "Station ID,"$1","$2","$3","$4} NR>1 {print NR-1","$1": "$2","$3","$4}' OFS=, mta_station_data.csv > mta_station_location.csv
awk -F',' 'NR==1 {print "Station ID,Line"} NR>1 {for (i=5; i<=15; i++) {if (length($i) > 0) {print NR-1","$i}}}' OFS=, mta_station_data.csv > mta_station_lines.csv
rm mta_station_data.csv
