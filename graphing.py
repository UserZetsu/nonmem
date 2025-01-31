# ## graph requirements: 
# # Color by covariates 
# # Need 1 average line and lines for each person 

# # 2. Line plot of renal clearance by age 
# # Need average and std dev 

# # 3. Boxplot of female and male by weight 

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Load the data
data = pd.read_csv('data/nonmem.csv')

# Bin the ages into categories
age_bins = [0, 18, 30, 45, 60, 100]
age_labels = ['0-18', '19-30', '31-45', '46-60', '61+']
data['AGE_BIN'] = pd.cut(data['AGE'], bins=age_bins, labels=age_labels)

# Bin the weights into categories
weight_bins = [0, 50, 70, 90, 110, 150]
weight_labels = ['0-50', '51-70', '71-90', '91-110', '111+']
data['WEIGHT_BIN'] = pd.cut(data['WEIGHT'], bins=weight_bins, labels=weight_labels)

# Set the style for the plots
sns.set(style="whitegrid")

# Create a figure with subplots
fig, axes = plt.subplots(3, 1, figsize=(10, 20))

# Create PK profiles colored by binned age
sns.lineplot(ax=axes[0], x='TIME', y='DV', hue='AGE_BIN', data=data, palette='viridis', legend='full', estimator=None)
axes[0].set_title('PK Profiles by Age Group (Dose-Normalized)')
axes[0].set_xlabel('Time (hours)')
axes[0].set_ylabel('Dose-Normalized DV')
axes[0].legend(title='Age Group', bbox_to_anchor=(1.05, 1), loc='upper left')

# Create PK profiles colored by another covariate (e.g., SEX)
sns.lineplot(ax=axes[1], x='TIME', y='DV', hue='SEX', data=data, palette='coolwarm', legend='full', estimator=None)
axes[1].set_title('PK Profiles by Sex (Dose-Normalized)')
axes[1].set_xlabel('Time (hours)')
axes[1].set_ylabel('Dose-Normalized DV')
axes[1].legend(title='Sex', bbox_to_anchor=(1.05, 1), loc='upper left')

# Create PK profiles colored by binned weight
sns.lineplot(ax=axes[2], x='TIME', y='DV', hue='WEIGHT_BIN', data=data, palette='plasma', legend='full', estimator=None)
axes[2].set_title('PK Profiles by Weight Group (Dose-Normalized)')
axes[2].set_xlabel('Time (hours)')
axes[2].set_ylabel('Dose-Normalized DV')
axes[2].legend(title='Weight Group', bbox_to_anchor=(1.05, 1), loc='upper left')

plt.tight_layout()
plt.show()