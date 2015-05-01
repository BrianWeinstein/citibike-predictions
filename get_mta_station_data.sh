curl https://data.ny.gov/api/views/i9wp-a4ja/rows.csv |  cut -d , -f 2-16 > datasets/mta_station_data_raw.csv
(head -n 1 datasets/mta_station_data_raw.csv && tail -n +2 datasets/mta_station_data_raw.csv | sort | uniq) > datasets/mta_station_data.csv
rm datasets/mta_station_data_raw.csv

awk -F',' 'NR==1 {print "Station ID,"$2","$3","$4} NR>1 {print NR-1","$1": "$2","$3","$4}' OFS=, datasets/mta_station_data.csv > datasets/mta_station_location.csv
awk -F',' 'NR==1 {print "Station ID,Line"} NR>1 {for (i=5; i<=15; i++) {if (length($i) > 0) {print NR-1","$i}}}' OFS=, datasets/mta_station_data.csv > datasets/mta_station_lines.csv
rm datasets/mta_station_data.csv