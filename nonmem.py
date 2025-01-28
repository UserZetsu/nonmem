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
df = drug_conc.join(dose_info[['USUBJID', 'Study day', 'Drug', 'Start Time', 'DATE', 'Dose']].set_index('USUBJID'), on = 'USUBJID')


# Cleaning IDs 
df['USUBJID'] = df['USUBJID'].str[1:].astype(int) - 1000

# Cleaning dates 
df['Time'] = pd.to_datetime(df['Time'])
## Setting Start Time
df['Start Time'] = pd.to_datetime(df['DATE'] + ' ' + df['Start Time'])


# Creating MDV, 0 if there is no value, 1 if there is a value 
df['mdv'] = df['Drug concentration'].apply(lambda x: 0 if x > 0 else 1)

# Creating amt, 
df = df.groupby('USUBJID').apply(lambda x: x.replace(x.iloc[0]['Time'], x.iloc[0]['Start Time']))
print(df)


# # Convert to datetype
# drug_conc['Time'] = pd.to_datetime(drug_conc['Time'])
# drug_conc['Elapsed time'] = drug_conc.groupby('USUBJID')['Time'].transform(lambda x: )

# # Splitting Date from Time and converting to format
# drug_conc['Date'] = drug_conc['Time'].dt.date
# drug_conc['Date'] = drug_conc['Date'].apply(lambda x: x.strftime('%m/%d/%Y'))

# # Splitting Time from Time
# drug_conc['Time'] = drug_conc['Time'].dt.time

# # Grabbing dose
# drug_conc['amt'] = drug_conc.apply(lambda x: dose_info.loc[1]['Dose'][:-2].strip() if x['Drug concentration'] == 0 else 0,axis=1)

# # Join datasets
# drug_conc = drug_conc.join(dm.set_index('USUBJID'), on = 'USUBJID')
# drug_conc = drug_conc.join(dose_info[['USUBJID','Study day', 'Drug', 'Start Time']].set_index('USUBJID'), on = 'USUBJID')


# # Making start time as my first time value
# drug_conc['Time'] = drug_conc.apply(lambda x: pd.to_datetime(x['Start Time']).time() if x['mdv'] == 1 else x['Time'], axis=1)


# # Converting gender to binary 
# drug_conc['Sex'] = drug_conc['Sex'].apply(lambda x: 1 if x == "Male" else 0)

# # Column reordering 
# drug_conc = drug_conc.loc[:, ['USUBJID', 'Date', 'Time', 'amt', 'Drug concentration', 'mdv', 'Study day', 'Drug', 'Age', 'Sex', 'Albumin', 'body weight']]
# drug_conc.columns = ['ID', 'DATE', 'TIME', 'AMT', 'DV', 'MDV', 'STUDY DAY', 'DRUG/ARM', 'AGE', 'SEX', 'ALBUMIN', 'WEIGHT']

# print(drug_conc[:40])

# # TODO: 
# # 1) Change date to start time



os.remove('data/nonmem.csv')
df.to_csv('data/nonmem.csv', index = False)



# ## graph requirements: 
# # Color by covariates 
# # Need 1 average line and lines for each person 

# # 2. Line plot of renal clearance by age 
# # Need average and std dev 

# # 3. Boxplot of female and male by weight 





