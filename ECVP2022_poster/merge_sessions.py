import pandas as pd

# df1 = pd.read_json('Data/RawData/Exp01_20220711_MS_S01.json')
# df2 = pd.read_json('Data/RawData/Exp01_20220711_MS_S02.json')
# df = pd.concat([df1, df2], ignore_index=True)
# df.to_json('Data/Exp01_20220711_MS.json')

df1 = pd.read_json('Data/RawData/Exp03_20220715_AR_S01.json')
df2 = pd.read_json('Data/RawData/Exp03_20220715_AR_S02.json')
df = pd.concat([df1, df2], ignore_index=True)
df.to_json('Data/Exp03AR.json')
