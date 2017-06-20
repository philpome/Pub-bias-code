#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jun  2 13:04:03 2017

@author: robert
"""
import json
from collections import defaultdict

with open("pgc-copy.json", 'rb') as readfile:
    extracted_data = json.load(readfile)

country_list = []
for entry in range(len(extracted_data)):
    for i in range(len(extracted_data[entry]['focalspeciesCOO'])):
        for country in extracted_data[entry]['focalspeciesCOO'][i]:
            if country not in country_list:
                country_list.append(country)
    for country in extracted_data[entry]['authorsCOO']:
        if country not in country_list:
                country_list.append(country)

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
