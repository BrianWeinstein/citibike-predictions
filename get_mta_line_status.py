import urllib2
from bs4 import BeautifulSoup
from datetime import date, timedelta
import ast
import csv

lines = frozenset(('1','2','3','4','5','6','7','A','B','C','D','E','F','G','J','L','M','N','Q','R','S','Z'))
pull_date = date(2014,1,1)
max_date = date(2015,1,1)

labels = ["", "Good Service", "Delays", "Planned Work", "Service Change", "Suspended"]

base_url = 'http://subwaystats.com/status-{line}-train-on-{date}.html'

all_data = []


while pull_date < max_date:
    for line in lines:
        url = base_url.format(line=line, date=pull_date.isoformat())
        try:
            page = urllib2.urlopen(url)
            soup = BeautifulSoup(page.read())
            # this is super brittle, but this site is very well organized so it works
            script = soup.find_all('script')[10]
            data = script.text.split("data: ")[1].split("\r\n")[0].replace("null","None")
            data = ast.literal_eval(data)

            prev_d = None
            for i in range(len(data)):
                if data[i] is None:
                    data[i] = prev_d if prev_d else 1
                temp_d = data[i]
            # rows = create_rows(data)
            all_data.append((pull_date.isoformat(), line, data))
            print pull_date.isoformat(), line
        except:
            print "error with url {}".format(url)
    pull_date += timedelta(1)


for dt, line, data in all_data:
    # save raw data
    with open ('datasets/mta_status_full_day.csv', 'ab') as f:
        csvwriter = csv.writer(f, delimiter=',', quotechar='"')
        csvwriter.writerow((dt, line, data))

    dailyvals = []
    # one for each hour
    for h in range(24):
        hour_list = data[h*4:h*4+4]
        hour_status = max(set(hour_list), key=hour_list.count)
        hour_dt = datetime.strptime(dt,'%Y-%m-%d').replace(hour=h)
        dailyvals.append((hour_dt.isoformat(), line, hour_status))
    
    #save daily data
    with open('datasets/mta_status_hourly.csv', 'ab') as f:
        csvwriter = csv.writer(f, delimiter=',', quotechar='"')
        csvwriter.writerows(dailyvals)