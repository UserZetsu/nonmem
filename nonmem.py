import csv 
import pandas as pd 
import numpy as np
import datetime
import os 

# Load data 
dm = pd.read_csv('data/Raw_data_DrugB_3_dm.csv')
dose_info = pd.read_csv('data/Raw_data_DrugB_3_dosing_info.csv')
drug_conc = pd.read_csv('data/Raw_data_DrugB_3_drug_conc.csv')

# Joining three dataframes together 
df = drug_conc.join(dm.set_index('USUBJID'), on = 'USUBJID')
df = df.join(dose_info[['USUBJID', 'Study day', 'Drug', 'Start Time', 'DATE', 'Dose']].set_index('USUBJID'), on = 'USUBJID')


# Cleaning IDs 
df['USUBJID'] = df['USUBJID'].str[1:].astype(int) - 1000

# Cleaning dates 
df['Time'] = pd.to_datetime(df['Time'])
df['Date'] = df['Time'].dt.date

#df['Date'] = df['Date'].apply(lambda x: x.dt.strftime('%m/%d/%Y'))
## Setting Start Time
df['Start Time'] = pd.to_datetime(df['DATE'] + ' ' + df['Start Time'])


# Creating MDV, 0 if there is no value, 1 if there is a value 
df['mdv'] = df['Drug concentration'].apply(lambda x: 0 if x > 0 else 1)

# Replacing first value of Time with the start time, then convert to hours 
df = df.groupby('USUBJID', group_keys=False).apply(lambda x: x.replace(x.iloc[0]['Time'], x.iloc[0]['Start Time']))
df['Time'] = df.apply(lambda x: x['Time'] - x['Start Time'], axis = 1)
df['Time'] = df['Time'].dt.total_seconds()/3600

# Creating date column 



# Creating drug amt column
df['amt'] = df.apply(lambda x: x['Dose'][:-2].strip() if x['Drug concentration'] == 0 else 0, axis = 1)

# Converting gender to binary 
df['Sex'] = df['Sex'].apply(lambda x: 1 if x == "Male" else 0)

# Creating EVID 
df['evid'] = df['amt'].apply(lambda x: 1 if x > 0 else 0)

# Column reordering 
df = df.loc[:, ['USUBJID', 'Date', 'Time', 'amt', 'Drug concentration', 'mdv', 'evid','Study day', 'Drug', 'Age', 'Sex', 'Albumin', 'body weight']]
df.columns = ['ID', 'DATE', 'TIME', 'AMT', 'DV', 'MDV', 'EVID' 'STUDY DAY', 'DRUG/ARM', 'AGE', 'SEX', 'ALBUMIN', 'WEIGHT']

# Write to CSV
os.remove('data/nonmem.csv')
df.to_csv('data/nonmem.csv', index = False)

#print(df[:14])


