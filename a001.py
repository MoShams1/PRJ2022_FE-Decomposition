import pandas as pd
from matplotlib import pyplot as plt

# df = pd.read_json('Data/Exp01_20220713_TEST_S01.json')
# df = pd.read_json('Data/Exp02_20220713_test_S01.json')
df = pd.read_json('Data/Exp03_20220713_MS_S03.json')

err1 = df['click1_xloc'] - df['probe_xloc']
# msk1 = df['cnd'] == 'double'
# msk2 = df['cnd'] == 'single1'

# plt.hist(err1)
# plt.show()

# print(df.loc[1])
print(df)
