import csv 
import pandas as pd 
import numpy as np
import datetime
import os 

dm = pd.read_csv('Raw_data_DrugB_3_dm.csv')
dose_info = pd.read_csv('Raw_data_DrugB_3_dosing_info.csv')
drug_conc = pd.read_csv('Raw_data_DrugB_3_drug_conc.csv')


def clean_id(df):
    df['USUBJID'] = df['USUBJID'].str[1:].astype(int) - 1000
    return df

# Visualizations to produce 

# 1. Plot of drug concentration vs time for each subject

## data requirements 
# Data is from drug_conc
# need to clean time to just hours by person 

# Cleaning IDs
drug_conc = clean_id(drug_conc)
dose_info = clean_id(dose_info)
dm = clean_id(dm)


drug_conc['Time'] = pd.to_datetime(drug_conc['Time']



print(drug_conc)

os.remove('nonmem.csv')
with open('nonmem.csv', 'w') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(['ID', 'Time', 'AMT', 'DV', 'MDV', 'EVID', 'DOSE', 'DRUG/ARM', 'AGE', 'SEX', 'ALBUMIN', 'WEIGHT'])
    




## graph requirements: 
# Color by covariates 
# Need 1 average line and lines for each person 

# 2. Line plot of renal clearance by age 
# Need average and std dev 

# 3. Boxplot of female and male by weight 





