from selenium import webdriver
from selenium.webdriver.support.select import Select
from selenium.webdriver.common.keys import Keys

import csv

# initialize webdriver instance and visit url
url = 'http://archive.mymtaalerts.com/messagearchive.aspx'
browser = webdriver.Firefox()
browser.get(url)

# set start date
start_date = browser.find_element_by_id('RadDatePickerStart_dateInput')
start_date.send_keys(Keys.COMMAND, 'a')
start_date.send_keys('1/1/2014')
start_date.send_keys(Keys.ENTER)

# set end date
end_date = browser.find_element_by_id('RadDatePickerEnd_dateInput')
end_date.send_keys(Keys.COMMAND, 'a')
end_date.send_keys('12/31/2014')
end_date.send_keys(Keys.ENTER)

# max results per page
results_per_page = browser.find_element_by_id('RadGrid1_ctl00_ctl03_ctl01_PageSizeComboBox_Input')
results_per_page.click()
results_per_page.send_keys('5')
results_per_page.send_keys(Keys.ENTER)

# order by "Agency" descending so all Subway entries come to the top
# first click orders ascending, so do it twice
for _ in range(2):
    agency = browser.find_element_by_xpath("//*[contains(text(), 'Agency')]")
    agency.click()

with open("subway_status_2014.csv", "wb") as f:
    writer = csv.writer(f, delimiter='|', quotechar='"', quoting=csv.QUOTE_ALL)
    writer.writerow(["ID", "Alert Timestamp", "Sent Date", "Agency", "Subject", "Message"])

i = 0
alert_type = 'Subway'
while alert_type == 'Subway':
    notices = []
    table = browser.find_elements_by_class_name('rgRow')
    table.extend(browser.find_elements_by_class_name('rgAltRow'))

    for row in table:
        contents = [cell.text.encode('ascii', 'ignore') for cell in row.find_elements_by_tag_name('td')]
        # notice type is column 3
        if contents[2] == 'Subway':
            i += 1
            contents[0] = i
            notices.append(contents)
        else:
            # since this has been sorted by the website already, we can break if we leave Subway section
            alert_type = contents[2]

    with open("datasets/subway_status_2014.csv", "ab") as f:
        writer = csv.writer(f, delimiter='|', quotechar='"', quoting=csv.QUOTE_ALL)
        writer.writerows(notices)

    print i
    browser.find_element_by_xpath("//input[@title='Next Page']").click()