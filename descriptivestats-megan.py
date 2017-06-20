#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jun  2 13:04:03 2017

@author: robert
"""
import json
from collections import defaultdict

#changed pgc to a copy to avoid fucking the original file
with open("pgc-copy.json", 'rb') as readfile:
    extracted_data = json.load(readfile)

country_list = []
for entry in range(100):
    for i in range(len(extracted_data[entry]['focalspeciesCOO'])):
        for country in extracted_data[entry]['focalspeciesCOO'][i]:
            if country not in country_list:
                country_list.append(country)
    for country in extracted_data[entry]['authorsCOO']:
        if country not in country_list:
                country_list.append(country)


#to create dictionary
import csv
reader = csv.reader(open('UNSD_region.csv'))
region = {}
for row in reader:
    key = row[0]
    if key in region:
        pass
    region[key] = row[1:]

#to convert countries (keys) to upper case
#BUT this leaves the lower case to, what to do?? (do it in excel instead :))
#continents.update({k.upper(): v for k, v in continents.items()})

#convert country_list to a set
country_set = set(country_list)

#returns a dictionary of countries in country_list as keys with region as value
region_dict = dict((k, region[k]) for k in country_set if k in region)
#returns a list of regions for each country in country_list
region_list = list(region[k] for k in country_set if k in region)

mismatch = []
firstAuthorMismatch = []
for entry in range(len(extracted_data)):
    for i in range(len(extracted_data[entry]['focalspeciesCOO'])):
        for auth_country in extracted_data[entry]['authorsCOO']:
            if auth_country not in extracted_data[entry]['focalspeciesCOO'][i]:
                mismatch.append(auth_country)
        if len(extracted_data[entry]['authorsCOO']) != 0:
            if extracted_data[entry]['authorsCOO'][0] not in extracted_data[entry]['focalspeciesCOO'][i]:
                firstAuthorMismatch.append(extracted_data[entry]['authorsCOO'][0])


def oppressor(mismatch):
    mismatch_dict = defaultdict(int)
    for k in mismatch:
        mismatch_dict[k] += 1
    return mismatch_dict
