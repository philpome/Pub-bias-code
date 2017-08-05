#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jul 28 11:08:22 2017

@author: robert
"""

import json
import csv
from collections import defaultdict

readfile = open("/home/robert/Documents/PubBiasJazz/pgc_data/pgc_extracted_1-12014.json", 'rb')
extracted_data = json.load(readfile)

reader_region = csv.reader(open('UNSD_region.csv'))
region = {}
for row in reader_region:
    key = row[0]
    if key in region:
        pass
    region[key] = row[1:]

reader_development = csv.reader(open('UNSD_development.csv'))
development = {}
for row in reader_development:
    key = row[0]
    if key in development:
        pass
    development[key] = row[1:]

reader_subregion = csv.reader(open('UNSD_subregion.csv'))
subregion = {}
for row in reader_subregion:
    key = row[0]
    if key in subregion:
        pass
    subregion[key] = row[1:]

#reader_all = csv.reader(open('UNSD_all.csv'))
#unsdAll = {}
#for row in reader_all:
#    key = row[0]
#    if key in unsdAll:
#        pass
#    unsdAll[key] = {}
#    unsdAll[key]['development'] = row[1]
#    unsdAll[key]['region'] = row[2]
#    unsdAll[key]['subregion'] = row[3]


reader_all = csv.reader(open('UNSD_all.csv'))
unsdAll = {}
unsdAll['country'] = list()
for row in reader_all:
    key = row[0]
    temp = {}
    
    temp['country'] = key 
    temp['development'] = row[1]
    temp['region'] = row[2]
    temp['subregion'] = row[3]
    unsdAll['country'].append(temp)

def dict_count(mm):    
    mismatch_dict = defaultdict(int)
    
    for k in mm:
        mismatch_dict[k] += 1
    return mismatch_dict


mismatch = []
mmSpecies = []
authorRepresentation = []
allMismatch = []
mmPapercount = 0
paperCount = 0

for entry in extracted_data:
    if len(entry['focalspecies']) > 0:
        
        paperCount += 1
        ac = []
        mmc = []
        mmspp = []
        
        for auth_country in entry['authorsCOO']:
            if auth_country not in ac:
                ac.append(auth_country)
        
        for i in range(len(entry['focalspeciesCOO'])):
            for country in ac:
                if country not in entry['focalspeciesCOO'][i]:
                    if country not in mmc:
                        mmc.append(country)
                        mmspp.append(entry['focalspecies'][i])
        
        if len(mmc) > 0: mmPapercount += 1
        
        if len(mmc) == len(ac):
            for country in mmc:
                allMismatch.append(country)
              
        for country in mmc:
            mismatch.append(country)
        
        for species in mmspp:
            mmSpecies.append(species)
        
        for country in ac:
            authorRepresentation.append(country)
            

#Mismatch for single author papers. If the author country does not match any of the countries for at least one of the species, the country is counted once.
singleAuthorMismatch = []
sAMcount = 0
sAcount = 0
for entry in extracted_data:
    if len(entry['focalspecies']) > 0:
        if len(entry['authorsCOO']) == 1:
            
            sAcount += 1
            auth_country = []
            
            for i in range(len(entry['focalspeciesCOO'])):
                for country in entry['authorsCOO']:
                    if country not in entry['focalspeciesCOO'][i]:
                        if country not in auth_country:
                            auth_country.append(country)
                            sAMcount += 1
                            #print(entry['focalspecies'][i],country,'\n', entry['focalspeciesCOO'][i])
            #print(sAMcount, auth_country, entry['focalspecies'])
            for country in auth_country:
                singleAuthorMismatch.append(country)

firstAuthorMismatch = []
lastAuthorMismatch = []
middleAuthorMismatch = []
for entry in extracted_data:
    if len(entry['focalspecies']) > 0:
        if len(entry['authorsCOO']) > 1:
            
            fAC = []
            lAC = []
            mAC = []
            middleMismatch = []
            
            fA = entry['authorsCOO'][0]
            lA = entry['authorsCOO'][len(entry['authorsCOO'])-1]
            
            for mA in range(1,len(entry['authorsCOO'])-1):
                if entry['authorsCOO'][mA] not in mAC:
                    mAC.append(entry['authorsCOO'][mA])
            
            for i in range(len(entry['focalspecies'])):
                if fA not in entry['focalspeciesCOO'][i]:
                    if fA not in fAC:
                        fAC.append(fA)
                        
                if lA not in entry['focalspeciesCOO'][i]:
                    if lA not in lAC:
                        lAC.append(lA)
                        
                for country in mAC:
                    if country not in entry['focalspeciesCOO'][i]:
                        if country not in middleMismatch:
                            if country != fA:
                                if country != lA:
                                    middleMismatch.append(country)
                        
            for country in middleMismatch: middleAuthorMismatch.append(country)            
            for country in fAC: firstAuthorMismatch.append(country)
            for country in lAC: lastAuthorMismatch.append(country)
            
dar = dict_count(authorRepresentation)
dam = dict_count(allMismatch)
dmm = dict_count(mismatch)
dfamm = dict_count(firstAuthorMismatch)
dlamm = dict_count(lastAuthorMismatch)
dsam = dict_count(singleAuthorMismatch)
dmam = dict_count(middleAuthorMismatch)

# add mismatch dictionaries to nested dictionary
for key in unsdAll['country']:
    for country, value in dar.items():
        if country == key['country']:
            key['authorRepresentationTotal'] = value
    for country, value in dam.items():
        if country == key['country']:
            key['allMismatchTotal'] = value
    for country, value in dmm.items():
        if country == key['country']:
            key['mismatchTotal'] = value
    for country, value in dfamm.items():
        if country == key['country']:
            key['firstAuthorMismatchTotal'] = value
    for country, value in dlamm.items():
        if country == key['country']:
            key['lastAuthorMismatchTotal'] = value
    for country, value in dmam.items():
        if country == key['country']:
            key['middleAuthorMismatchTotal'] = value
    for country, value in dsam.items():
        if country == key['country']:
            key['singleAuthorMismatchTotal'] = value
               


year_dict = {}
for year in range(1980,2018):
    year_dict[year] = {}

for key in year_dict:
    year_dict[key]['mismatch'] = []
    year_dict[key]['mmSpecies'] = []
    year_dict[key]['authorRepresentation'] = []
    year_dict[key]['allMismatch'] = []
    year_dict[key]['mmPapercount'] = 0
    year_dict[key]['paperCount'] = 0
    year_dict[key]['singleAuthorMismatch'] = []
    year_dict[key]['sAMcount'] = 0
    year_dict[key]['sAcount'] = 0
    year_dict[key]['firstAuthorMismatch'] = []
    year_dict[key]['lastAuthorMismatch'] = []
    year_dict[key]['middleAuthorMismatch'] = []
    
    for entry in extracted_data:
        if entry['year'] == key:
            if len(entry['focalspecies']) > 0:
                
                year_dict[key]['paperCount'] += 1
                ac = []
                mmc = []
                mmspp = []
                
                for auth_country in entry['authorsCOO']:
                    if auth_country not in ac:
                        ac.append(auth_country)
                
                for i in range(len(entry['focalspeciesCOO'])):
                    for country in ac:
                        if country not in entry['focalspeciesCOO'][i]:
                            if country not in mmc:
                                mmc.append(country)
                                mmspp.append(entry['focalspecies'][i])
                
                if len(mmc) > 0: year_dict[key]['mmPapercount'] += 1
                
                if len(mmc) == len(ac):
                    for country in mmc:
                        year_dict[key]['allMismatch'].append(country)
                      
                for country in mmc:
                    year_dict[key]['mismatch'].append(country)
                
                for species in mmspp:
                    year_dict[key]['mmSpecies'].append(species)
                
                for country in ac:
                    year_dict[key]['authorRepresentation'].append(country)
                    
                if len(entry['authorsCOO']) == 1:
                    
                    year_dict[key]['sAcount'] += 1
                    auth_country = []
                    
                    for i in range(len(entry['focalspeciesCOO'])):
                        for country in entry['authorsCOO']:
                            if country not in entry['focalspeciesCOO'][i]:
                                if country not in auth_country:
                                    auth_country.append(country)
                                    year_dict[key]['sAMcount'] += 1
                                    #print(entry['focalspecies'][i],country,'\n', entry['focalspeciesCOO'][i])
                    #print(year_dict[key]['sAMcount'], auth_country, entry['focalspecies'])
                    for country in auth_country:
                        year_dict[key]['singleAuthorMismatch'].append(country)
                    
                if len(entry['authorsCOO']) > 1:
                    
                    fAC = []
                    lAC = []
                    mAC = []
                    middleMismatch = []
                    
                    fA = entry['authorsCOO'][0]
                    lA = entry['authorsCOO'][len(entry['authorsCOO'])-1]
                    
                    for mA in range(1,len(entry['authorsCOO'])-1):
                        if entry['authorsCOO'][mA] not in mAC:
                            mAC.append(entry['authorsCOO'][mA])
                    
                    for i in range(len(entry['focalspecies'])):
                        if fA not in entry['focalspeciesCOO'][i]:
                            if fA not in fAC:
                                fAC.append(fA)
                                
                        if lA not in entry['focalspeciesCOO'][i]:
                            if lA not in lAC:
                                lAC.append(lA)
                                
                        for country in mAC:
                            if country not in entry['focalspeciesCOO'][i]:
                                if country not in middleMismatch:
                                    if country != fA:
                                        if country != lA:
                                            middleMismatch.append(country)
                                
                    for country in middleMismatch: year_dict[key]['middleAuthorMismatch'].append(country)            
                    for country in fAC: year_dict[key]['firstAuthorMismatch'].append(country)
                    for country in lAC: year_dict[key]['lastAuthorMismatch'].append(country)
                    
for key in year_dict:
    year_dict[key]['dar'] = dict_count(year_dict[key]['authorRepresentation'])
    year_dict[key]['dam'] = dict_count(year_dict[key]['allMismatch'])
    year_dict[key]['dmm'] = dict_count(year_dict[key]['mismatch'])
    year_dict[key]['dfamm'] = dict_count(year_dict[key]['firstAuthorMismatch'])
    year_dict[key]['dlamm'] = dict_count(year_dict[key]['lastAuthorMismatch'])
    year_dict[key]['dsam'] = dict_count(year_dict[key]['singleAuthorMismatch'])
    year_dict[key]['dmam'] = dict_count(year_dict[key]['middleAuthorMismatch'])
    
#for year in year_dict:
#    for key in unsdAll:
#        for country, value in year_dict[year]['dar'].items():
#            if country == key:
#                unsdAll[key]['authorRepresentation%s' % year] = value 
#        for country, value in year_dict[year]['dam'].items():
#            if country == key:
#                unsdAll[key]['allMismatch%s' % year] = value 
#        for country, value in year_dict[year]['dmm'].items():
#            if country == key:
#                unsdAll[key]['mismatch%s' % year] = value 
#        for country, value in year_dict[year]['dfamm'].items():
#            if country == key:
#                unsdAll[key]['firstAuthorMismatch%s' % year] = value 
#        for country, value in year_dict[year]['dlamm'].items():
#            if country == key:
#                unsdAll[key]['lastAuthorMismatch%s' % year] = value 
#        for country, value in year_dict[year]['dmam'].items():
#            if country == key:
#                unsdAll[key]['middleAuthorMismatch%s' % year] = value 
#        for country, value in year_dict[year]['dsam'].items():
#            if country == key:
#                unsdAll[key]['singleAuthorMismatch%s' % year] = value 
 
#for year in year_dict:
#    for key in unsdAll['country']:
#        for country, value in year_dict[year]['dar'].items():
#            if country == key['country']:
#                key['authorRepresentation%s' % year] = value 
#        for country, value in year_dict[year]['dam'].items():
#            if country == key['country']:
#                key['allMismatch%s' % year] = value 
#        for country, value in year_dict[year]['dmm'].items():
#            if country == key['country']:
#                key['mismatch%s' % year] = value 
#        for country, value in year_dict[year]['dfamm'].items():
#            if country == key['country']:
#                key['firstAuthorMismatch%s' % year] = value 
#        for country, value in year_dict[year]['dlamm'].items():
#            if country == key['country']:
#                key['lastAuthorMismatch%s' % year] = value 
#        for country, value in year_dict[year]['dmam'].items():
#            if country == key['country']:
#                key['middleAuthorMismatch%s' % year] = value 
#        for country, value in year_dict[year]['dsam'].items():
#            if country == key['country']:
#                key['singleAuthorMismatch%s' % year] = value 

for year in year_dict:
    for key in unsdAll['country']:
        key['%s' % year] = {}
        for country, value in year_dict[year]['dar'].items():
            if country == key['country']:
                key['%s' % year]['authorRepresentation'] = value 
        for country, value in year_dict[year]['dam'].items():
            if country == key['country']:
                key['%s' % year]['allMismatch'] = value 
        for country, value in year_dict[year]['dmm'].items():
            if country == key['country']:
                key['%s' % year]['mismatch'] = value 
        for country, value in year_dict[year]['dfamm'].items():
            if country == key['country']:
                key['%s' % year]['firstAuthorMismatch'] = value 
        for country, value in year_dict[year]['dlamm'].items():
            if country == key['country']:
                key['%s' % year]['lastAuthorMismatch'] = value 
        for country, value in year_dict[year]['dmam'].items():
            if country == key['country']:
                key['%s' % year]['middleAuthorMismatch'] = value 
        for country, value in year_dict[year]['dsam'].items():
            if country == key['country']:
                key['%s' % year]['singleAuthorMismatch'] = value 


tabdata = {}
tabdata['data'] = []

for year in year_dict:
    for key in unsdAll['country']:
        
        temp = {}
        temp['year'] = year
        temp['country'] = key['country']
        temp['development'] = key['development']
        temp['region'] = key['region']
        temp['subregion'] = key['subregion']
        
        for country, value in year_dict[year]['dar'].items():
            if country == temp['country']:
                temp['authorRepresentation'] = value
        for country, value in year_dict[year]['dam'].items():
            if country == temp['country']:
                temp['allMismatch'] = value 
        for country, value in year_dict[year]['dmm'].items():
            if country == temp['country']:
                temp['mismatch'] = value 
        for country, value in year_dict[year]['dfamm'].items():
            if country == temp['country']:
                temp['firstAuthorMismatch'] = value 
        for country, value in year_dict[year]['dlamm'].items():
            if country == temp['country']:
                temp['lastAuthorMismatch'] = value 
        for country, value in year_dict[year]['dmam'].items():
            if country == temp['country']:
                temp['middleAuthorMismatch'] = value 
        for country, value in year_dict[year]['dsam'].items():
            if country == temp['country']:
                temp['singleAuthorMismatch'] = value
        
        tabdata['data'].append(temp)

with open('tabdata.json','w') as wf:
    json.dump(tabdata,wf,indent=4)