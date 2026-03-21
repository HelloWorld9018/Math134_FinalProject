import numpy as np
import Extended_Hilbert_transform as ext_ht
import sys

file_name = sys.argv[1]
channel_name = sys.argv[2]
tau = float(sys.argv[3])


x = np.loadtxt(file_name)
x = x.reshape(1, len(x))

phase_exth, phase_h = ext_ht.phase_reconst(x, tau)

np.savetxt(f"phase_exth_{channel_name}.txt", phase_exth)
np.savetxt(f"phase_h_{channel_name}.txt", phase_h)

#alt_main.py "cont_{}_signal" 0.00625