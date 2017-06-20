#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jun  2 13:04:03 2017

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
    region[key] = row[1:]

reader_subregion = csv.reader(open('UNSD_subregion.csv'))
subregion = {}
for row in reader_subregion:
    key = row[0]
    if key in subregion:
        pass
    subregion[key] = row[1:]


country_list = []
for entry in extracted_data:
    for i in range(len(entry['focalspeciesCOO'])):
        for country in entry['focalspeciesCOO'][i]:
            if country not in country_list:
                country_list.append(country)

#    for country in entry['authorsCOO']:
#        if country not in country_list:
#                country_list.append(country)

#mismatch = []
#firstAuthorMismatch2 = []
#lastAuthorMismatch = []
#for entry in extracted_data:
#    for i in range(len(entry['focalspeciesCOO'])):
#        for auth_country in entry['authorsCOO']:
#            if auth_country not in entry['focalspeciesCOO'][i]:
#                mismatch.append(auth_country)
#        if len(entry['authorsCOO']) != 0:
#            if entry['authorsCOO'][0] not in entry['focalspeciesCOO'][i]:
#                firstAuthorMismatch2.append(entry['authorsCOO'][0])
#        if len(entry['authorsCOO']) != 0:
#            if entry['authorsCOO'][len(entry['authorsCOO'])-1] not in entry['focalspeciesCOO'][i]:
#                lastAuthorMismatch.append(entry['authorsCOO'][len(entry['authorsCOO'])-1])


#Mismatch that removes redundant author countries (for each author country not represented in at least one species country list, the country is counted once)
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


#firstAuthorMismatch = []
#lastAuthorMismatch = []
#for entry in extracted_data:
#    if len(entry['focalspecies']) > 0:
#        if len(entry['authorsCOO']) > 1:
#            fAC = []
#            lAC = []
#            fA = entry['authorsCOO'][0]
#            lA = entry['authorsCOO'][len(entry['authorsCOO'])-1]
#            for i in range(len(entry['focalspecies'])):
#                if fA not in entry['focalspeciesCOO'][i]:
#                    if fA not in fAC:
#                        fAC.append(fA)
#                if lA not in entry['focalspeciesCOO'][i]:
#                    if lA not in lAC:
#                        lAC.append(lA)
#            for country in fAC: firstAuthorMismatch.append(country)
#            for country in lAC: lastAuthorMismatch.append(country)

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

#list of all species in dataset for each paper ***Use dict_count function to remove repeat species and get a count of each species in list
spp_in_dataset = []
for entry in extracted_data:
    for i in range(len(entry['focalspecies'])):
        spp_in_dataset.append(entry['focalspecies'][i])


yearMismatch = []
for entry in extracted_data:
    year = []
    if len(entry['focalspecies']) > 0:
        
        for i in range(len(entry['focalspeciesCOO'])):
            for auth_country in entry['authorsCOO']:
                if auth_country not in entry['focalspeciesCOO'][i]:
                    if entry['year'] not in year: 
                        year.append(entry['year'])
        
        for y in year:
            yearMismatch.append(y)


yearTotals = []
for entry in extracted_data:
    if len(entry['focalspecies']) > 0:
        yearTotals.append(entry['year'])


genetictools = []
for entry in extracted_data:
    if len(entry['focalspecies']) > 0:
        for tool in entry['genetictool']:
            genetictools.append(tool)

tool_by_year = defaultdict(list)
for entry in extracted_data:
    if len(entry['focalspecies']) > 0:
        for tool in entry['genetictool']:
            tool_by_year[tool].append(entry['year'])


def regionize(list_to_be_regionized):
    region_list = []
    for k in region:
        for j in list_to_be_regionized:
            if k == j:
                for item in region[k]:
                    region_list.append(item)
    return(region_list)

def developize(list_to_be_developized):
    develop_list = []
    for k in development:
        for j in list_to_be_developized:
            if k == j:
                for item in development[k]:
                    develop_list.append(item)
    return(develop_list)

def subregionize(list_to_be_subregionized):
    subregion_list = []
    for k in subregion:
        for j in list_to_be_subregionized:
            if k == j:
                for item in subregion[k]:
                    subregion_list.append(item)
    return(subregion_list)

def dict_count(mm):    
    mismatch_dict = defaultdict(int)
    
    for k in mm:
        mismatch_dict[k] += 1
    return mismatch_dict


def d_countrymatcher(dictionary1,dictionary2):
    print('country,percentMismatch,v1,v2,total')
    
    countrylist = []
    
    for kt,vt in dict_count(authorRepresentation).items():
        for k1,v1 in dict_count(dictionary1).items():
            for k2,v2 in dict_count(dictionary2).items():
                if kt == k1 == k2:
                    print(kt , ',' , v1/v2*100 , ',' , v1 , ',' , v2 , ',' , vt)
                    countrylist.append(kt)
    
    for kt,vt in dict_count(authorRepresentation).items():
        for k1,v1 in dict_count(dictionary1).items():
            for k2,v2 in dict_count(dictionary2).items():
                if kt not in countrylist:
                    if kt == k2: 
                        print(kt , ',' , ',' , ',' , v2 , ',' , vt)
                        countrylist.append(kt)
    
    for kt,vt in dict_count(authorRepresentation).items():
        if kt not in countrylist:
            print(kt , ',' , ',' , ',' , ',' , vt)
                

def d_matcher(dictionary1,dictionary2,header):
    print('%s,percentMismatch,v1,v2' % header)
    
    klist = []
    
    for k1,v1 in dict_count(dictionary1).items():
        for k2,v2 in dict_count(dictionary2).items():
            if k1 == k2:
                print(k1, ',' , v1/v2*100 , ',' , v1 , ',' , v2)
                klist.append(k1)
    
    for k1,v1 in dict_count(dictionary1).items():
        if k1 not in klist:
                print(k1, ',' , ',' , v1 , ',')
                klist.append(k1)
    
    for k2,v2 in dict_count(dictionary2).items():
        if k2 not in klist:
            print(k2, ',' , ',' , ',' , v2)
                
                
                
                
                
                
                
                
