#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jul 28 12:21:17 2017

@author: robert
"""

import json
import csv
from collections import defaultdict

def dict_count(mm):    
    mismatch_dict = defaultdict(int)
    
    for k in mm:
        mismatch_dict[k] += 1
    return mismatch_dict

#create dictionaries that count number of particular mismatches by country
dar = dict_count(year_dict[key]['authorRepresentation'])
dam = dict_count(year_dict[key]['allMismatch'])
dmm = dict_count(year_dict[key]['mismatch'])
dfamm = dict_count(year_dict[key]['firstAuthorMismatch'])
dlamm = dict_count(year_dict[key]['lastAuthorMismatch'])
dsam = dict_count(year_dict[key]['singleAuthorMismatch'])
dmam = dict_count(year_dict[key]['middleAuthorMismatch'])

# add mismatch dictionaries to nested dictionary
for key in unsdAll:
    for country, value in dar.items():
        if country == key:
            unsdAll[key]['authorRepresentation'] = value
    for country, value in dam.items():
        if country == key:
            unsdAll[key]['allMismatch'] = value
    for country, value in dmm.items():
        if country == key:
            unsdAll[key]['mismatch'] = value
    for country, value in dfamm.items():
        if country == key:
            unsdAll[key]['firstAuthorMismatch'] = value
    for country, value in dlamm.items():
        if country == key:
            unsdAll[key]['lastAuthorMismatch'] = value
    for country, value in dmam.items():
        if country == key:
            unsdAll[key]['middleAuthorMismatch'] = value
    for country, value in dsam.items():
        if country == key:
            unsdAll[key]['singleAuthorMismatch'] = value

#print dictionary as csv
for key in unsdAll:
    ar =''
    if 'authorRepresentation' in unsdAll[key]:
        ar = unsdAll[key]['authorRepresentation']
    am =''
    if 'allMismatch' in unsdAll[key]:
        am = unsdAll[key]['allMismatch']    
    mm =''
    if 'mismatch' in unsdAll[key]:
        mm = unsdAll[key]['mismatch']
    fam =''
    if 'firstAuthorMismatch' in unsdAll[key]:
        fam = unsdAll[key]['firstAuthorMismatch']
    lam =''
    if 'lastAuthorMismatch' in unsdAll[key]:
        lam = unsdAll[key]['lastAuthorMismatch']
    mam =''
    if 'middleAuthorMismatch' in unsdAll[key]:
        mam = unsdAll[key]['middleAuthorMismatch']
    sam =''
    if 'singleAuthorMismatch' in unsdAll[key]:
        sam = unsdAll[key]['singleAuthorMismatch']
    print(key, ',',
          unsdAll[key]['development'],',',
          unsdAll[key]['region'],',',
          unsdAll[key]['subregion'],',',
          ar,',',
          am,',',
          mm,',',
          fam,',',
          lam,',',
          mam,',',
          sam)