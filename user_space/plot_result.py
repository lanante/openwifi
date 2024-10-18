import pandas
import matplotlib.pyplot as plt

file = 'result_perf_lite.csv'

df = pandas.read_csv(file,index_col='Power Backoff')

df = df.T
for i, col in enumerate(df.columns):
    df[col].plot(legend=True)

plt.show()


