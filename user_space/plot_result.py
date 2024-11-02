import pandas
import matplotlib.pyplot as plt

file = 'result_perf_rvr.csv'

df = pandas.read_csv(file,index_col='RSSI')

df = df.T
for i, col in enumerate(df.columns):
    df[col].plot(legend=True,logy=True,grid=True)

plt.show()


