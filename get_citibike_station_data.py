import urllib
import json

url = 'http://www.citibikenyc.com/stations/json/'
response = urllib.urlopen(url)
data = json.loads(response.read()).get('stationBeanList')

stations = [','.join(('station_id','station_name','latitude','longitude'))]

for d in data:
    stations.append((','.join((str(d['id']), str(d['stationName']), str(d['latitude']).replace(',',''), str(d['longitude'])))))

with open('datasets/citibike_station_data.csv', 'wb') as f:
    f.writelines(line + '\n' for line in stations)