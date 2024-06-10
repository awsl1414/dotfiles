"""
Author: awsl1414 3030994569@qq.com
Date: 2024-06-10 19:49:02
LastEditors: awsl1414 3030994569@qq.com
LastEditTime: 2024-06-10 19:49:05
FilePath: /aria2.conf-master/test.py
Description: 

"""

import os

input_file = "example.txt"
output_file = "temp.txt"

# 逐行读取和修改
with open(input_file, "r") as infile, open(output_file, "w") as outfile:
    for line in infile:
        if "Line 3" in line:
            line = "Line 3: This is the modified last line.\n"
        outfile.write(line)

# 替换原文件
os.replace(output_file, input_file)

print("文件修改完成！")
