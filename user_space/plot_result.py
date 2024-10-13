import pandas
import matplotlib.pyplot as plt

file = 'result_perf_lite.csv'

df = pandas.read_csv(file)

df1 = df.iloc[::-1]
# plot prices
plt.semilogy(df1['Power Backoff'], df['MCS0'], '-', label = 'MCS0')
plt.semilogy(df1['Power Backoff'], df['MCS4'], '-', label = 'MCS4')
plt.semilogy(df1['Power Backoff'], df['MCS7'], '-', label = 'MCS7')
plt.legend()

plt.show()
