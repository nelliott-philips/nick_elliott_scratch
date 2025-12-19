import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import chirp, welch

fs = 200_000
t = np.arange(0, 0.01, 1/fs)
x = chirp(t, f0=5_000, f1=50_000, t1=t[-1], method="linear")
x += 0.05*np.random.randn(len(t))

f, Pxx = welch(x, fs=fs, nperseg=2048)

plt.figure()
plt.plot(t*1e3, x)
plt.title("Chirp + noise (time domain)")
plt.xlabel("Time (ms)")
plt.ylabel("Amplitude")
plt.grid(True)

plt.figure()
plt.semilogy(f/1e3, Pxx)
plt.title("Welch PSD")
plt.xlabel("Frequency (kHz)")
plt.ylabel("Power")
plt.grid(True)

plt.show()
