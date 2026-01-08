import numpy as np
import matplotlib.pyplot as plt
from scipy import signal
from scipy.optimize import brentq

# -----------------------------
# User specs (analog elliptic LPF)
# -----------------------------
N_target = 3
rp_db = 0.5          # passband ripple (dB)
fp_hz = 43e6         # passband edge frequency (Hz)  (your "Fc")
fs_hz = 64.5e6       # stopband edge frequency (Hz)

wp = 2 * np.pi * fp_hz
ws = 2 * np.pi * fs_hz

# -------------------------------------------------------------------
# Elliptic filters require BOTH rp and rs. Since rs wasn't specified,
# we solve for the rs value that makes ellipord() return N_target=3.
# -------------------------------------------------------------------
def order_minus_target(rs_db: float) -> float:
    N, _ = signal.ellipord(wp, ws, rp_db, rs_db, analog=True)
    return N - N_target

lo, hi = 5.0, 200.0
f_lo = order_minus_target(lo)
f_hi = order_minus_target(hi)

# Expand bracket if needed
while f_lo * f_hi > 0 and hi < 400:
    hi *= 1.5
    f_hi = order_minus_target(hi)

if f_lo * f_hi > 0:
    # Fallback if bracketing fails (should be rare for these specs)
    rs_db = 40.0
else:
    rs_db = brentq(order_minus_target, lo, hi)

# -----------------------------
# Design: 3rd-order analog elliptic low-pass
# Wn is the passband edge for analog designs when rp is given.
# -----------------------------
z, p, k = signal.ellip(N_target, rp_db, rs_db, wp, analog=True, output="zpk")

# -----------------------------
# Frequency response (Bode)
# -----------------------------
f = np.logspace(np.log10(fp_hz / 20), np.log10(fs_hz * 20), 4000)
w = 2 * np.pi * f

_, H = signal.freqs_zpk(z, p, k, worN=w)
mag_db = 20 * np.log10(np.abs(H))
phase_deg = np.unwrap(np.angle(H)) * 180 / np.pi

# Attenuation at fs
H_fs = signal.freqs_zpk(z, p, k, worN=[ws])[1][0]
att_fs_db = -20 * np.log10(np.abs(H_fs))

print(f"Implied stopband attenuation for N=3: Rs ~= {rs_db:.2f} dB")
print(f"Attenuation at fs = {fs_hz/1e6:.1f} MHz: {att_fs_db:.2f} dB")
print("\nPoles (rad/s):")
for pi in p:
    print(f"  {pi}")
print("\nZeros (rad/s):")
for zi in z:
    print(f"  {zi}")

# -----------------------------
# Plot: magnitude
# -----------------------------
plt.figure(figsize=(10, 6))
plt.semilogx(f, mag_db)
plt.axvline(fp_hz, linestyle="--")
plt.axvline(fs_hz, linestyle="--")
plt.axhline(-rp_db, linestyle=":")
plt.xlabel("Frequency (Hz)")
plt.ylabel("Magnitude (dB)")
plt.title("3rd-Order Analog Elliptic Low-Pass (Bode Magnitude)")
plt.grid(True, which="both", linestyle=":")
plt.show()

# -----------------------------
# Plot: phase
# -----------------------------
plt.figure(figsize=(10, 6))
plt.semilogx(f, phase_deg)
plt.axvline(fp_hz, linestyle="--")
plt.axvline(fs_hz, linestyle="--")
plt.xlabel("Frequency (Hz)")
plt.ylabel("Phase (degrees)")
plt.title("3rd-Order Analog Elliptic Low-Pass (Bode Phase)")
plt.grid(True, which="both", linestyle=":")
plt.show()
