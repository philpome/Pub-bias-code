#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Aug  2 09:50:34 2017

@author: robert
"""

import wbdata
import csv
import json



codeMatcher = []
with open('UNSD_all_codes.csv', 'r') as rf:
    reader = csv.reader(rf)
    for row in reader:
        temp = {}
        temp['%s' % row[0]] = row[4]
        codeMatcher.append(temp)

cc_dict = json.load(open('speciesPerCountry.json','r'))

tabdata = json.load(open('tabdata.json','r'))


for item in tabdata['data']:
    for code in codeMatcher:
        for key in code:
            if key == item['country']:
                item['cc'] = code[key]


for item in tabdata['data']:
    for c in cc_dict:
        if item['cc'] == c:            
            item['gbifDiversity'] = cc_dict[c]

centroids = {}
coords = open('country_centroids_all.csv','rt')
coords = csv.reader(coords)
for row in coords:
    centroids[row[12]] = {}
    centroids[row[12]]['lat'] = float(row[0])
    centroids[row[12]]['long']= float(row[1])
   

for item in tabdata['data']:
    for centroid in centroids:
        if item['cc'] == centroid:
            item['lat'] = centroids[centroid]['lat']
            item['long'] = centroids[centroid]['long']


def worldBankAppender(indicator):
    for occ in wbdata.get_data(indicator):
        for item in tabdata['data']:
            if occ['country']['id'] == item['cc']:
                if int(occ['date']) == item['year']:
                    if occ['value'] != None:
                        item['%s' % occ['indicator']['value']] = float(occ['value'])


indicatorList = ['NY.GDP.PCAP.PP.KD',
                 'SE.TER.CUAT.BA.ZS',
                 'ER.PTD.TOTL.ZS',
                 'EN.MAM.THRD.NO',
                 'EN.HPT.THRD.NO',
                 'EN.FSH.THRD.NO',
                 'EN.BIR.THRD.NO',
                 'IP.JRN.ARTC.SC',
                 'SP.POP.TOTL',
                 'SI.POV.GINI',
                 'SI.POV.NAHC',
                 'PV.EST',
                 'GV.POLI.ST.ES',
                 'EN.ANM.THRD.NO',
                 'AG.LND.AGRI.ZS',
                 'UNDP.HDI.XD',
                 'UIS.OE.56.40510',
                 'SE.TER.GRAD',
                 'UIS.XGOVEXP.IMF.56',
                 'SL.TLF.0714.ZS',
                 'SP.POP.SCIE.RD.P6',
                 'GB.XPD.RSDV.GD.ZS',
                 'AG.LND.TOTL.K2']

for code in indicatorList:
    worldBankAppender(code)
    print(code)
    
with open('workingDataset.json','w') as wf:
    json.dump(tabdata, wf)