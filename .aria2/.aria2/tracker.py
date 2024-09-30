"""
Author: awsl1414 3030994569@qq.com
Date: 2024-06-10 18:44:54
LastEditors: awsl1414 3030994569@qq.com
LastEditTime: 2024-06-10 18:48:08
FilePath: /aria2.conf-master/tracker.py
Description: 

"""

import os
import httpx

tracker_url_list = [
    "https://cf.trackerslist.com/best.txt",
    "https://ngosang.github.io/trackerslist/trackers_best.txt",
    "https://ngosang.github.io/trackerslist/trackers_best_ip.txt",
]

tracker = ""
for url in tracker_url_list:
    respose = httpx.get(url)
    tracker += (
        ",".join([line for line in respose.text.split("\n") if line.strip() != ""])
        + ","
    )
tracker = tracker[:-1]
print("--------------------[BitTorrent Trackers]--------------------")
print(tracker)
print("--------------------[BitTorrent Trackers]--------------------")

with open("aria2.conf", "r+", encoding="utf-8") as infile, open(
    "temp.txt", "w", encoding="utf-8"
) as outfile:
    for line in infile:
        if "bt-tracker=" in line:
            line = "bt-tracker=" + tracker
        outfile.write(line)

os.replace("temp.txt", "aria2.conf")
print("BT trackers successfully added to Aria2 configuration file !")
