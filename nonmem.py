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


drug_conc['Time'] = pd.to_datetime(drug_conc['Time'])
drug_conc['Date'] = drug_conc['Time'].dt.date
# Should I replace drug concentration time with dosing information start time when drug concentration = 0?
drug_conc['Time'] = drug_conc['Time'].dt.time
drug_conc['mdv'] = drug_conc['Drug concentration'].apply(lambda x: 1 if x > 0 else 0)
drug_conc['amt'] = drug_conc.apply(lambda row: dose_info.loc[1]['Dose'][:-2].strip() if row['Drug concentration'] == 0 else 0,axis=1)
drug_conc = drug_conc.join(dm.set_index('USUBJID'), on = 'USUBJID')
drug_conc = drug_conc.join(dose_info[['USUBJID','Study day', 'Drug']].set_index('USUBJID'), on = 'USUBJID')
drug_conc = drug_conc.loc[:, ['USUBJID', 'Date', 'Time', 'amt', 'Drug concentration', 'mdv', 'Study day', 'Drug', 'Age', 'Sex', 'Albumin', 'body weight']]
drug_conc.columns = ['ID', 'DATE', 'TIME', 'AMT', 'DV', 'MDV', 'STUDY DAY', 'DRUG/ARM', 'AGE', 'SEX', 'ALBUMIN', 'WEIGHT']
print(drug_conc)

os.remove('nonmem.csv')
drug_conc.to_csv('nonmem.csv', index = False)



## graph requirements: 
# Color by covariates 
# Need 1 average line and lines for each person 

# 2. Line plot of renal clearance by age 
# Need average and std dev 

# 3. Boxplot of female and male by weight 





