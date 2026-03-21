import numpy as np
import matplotlib.pyplot as plt
import mne 
import mne_bids
import os

subject_001 = "motor_data/S001"
print(os.listdir(subject_001))

run_05 = "motor_data/S001/S001R05.edf"
raw = mne.io.read_raw_edf(run_05, preload=True)
raw.filter(l_freq=7, h_freq=30)
raw.notch_filter(freqs=60)

events, event_id = mne.events_from_annotations(raw)
event_dict = event_id
data = raw.get_data()
channels = raw.ch_names
sfreq = raw.info['sfreq']

print(data.shape) #64 channels, 20000 times
print(channels)
print(sfreq)

file_safe_channel_names = ['Fc5', 'Fc3', 'Fc1', 'Fcz', 'Fc2', 'Fc4', 'Fc6', 'C5', 'C3', 'C1', 'Cz', 'C2', 'C4', 'C6', 'Cp5', 'Cp3', 'Cp1', 'Cpz', 'Cp2', 'Cp4', 'Cp6', 'Fp1', 'Fpz', 'Fp2', 'Af7', 'Af3', 'Afz', 'Af4', 'Af8', 'F7', 'F5', 'F3', 'F1', 'Fz', 'F2', 'F4', 'F6', 'F8', 'Ft7', 'Ft8', 'T7', 'T8', 'T9', 'T10', 'Tp7', 'Tp8', 'P7', 'P5', 'P3', 'P1', 'Pz', 'P2', 'P4', 'P6', 'P8', 'Po7', 'Po3', 'Poz', 'Po4', 'Po8', 'O1', 'Oz', 'O2', 'Iz']
print(len(file_safe_channel_names)) #64

for i, ch in enumerate(channels):
    channel_signal = data[i,:]
    signal = channel_signal.flatten()
    np.savetxt(f"cont_{file_safe_channel_names[i]}_signal.txt", signal)


print(file_safe_channel_names)
print(file_safe_channel_names[0])

for i, ch in enumerate(file_safe_channel_names):
    print(f"python3 alt_main.py \"cont_{ch}_signal.txt\" {ch} 0.00625")
    
phases = []
for i, ch in enumerate(file_safe_channel_names):
    phase = np.loadtxt(f"phase_exth_{ch}.txt")
    phase = np.deg2rad(phase)
    phases.append(phase)

#Truncate to same length
min_len = min(len(phase) for phase in phases)
phases_array = np.array([phase[:min_len] for phase in phases], dtype=float)
#print(phases_array.shape) #(64 channels, 19855 time samples)
time_seconds = np.arange(len(phases_array[0]))/sfreq

#removing an artifact at the first second
samples_1s = int(sfreq)
phases_array = phases_array[:, samples_1s:]
time_seconds = time_seconds[samples_1s:]

#Calculating global order parameter r
N = phases_array.shape[0]
z = np.sum(np.exp(1j*phases_array), axis=0)/N
r = np.abs(z)

#Calculating average phase psi
psi = np.angle(z)
print("Average phase: ", psi)
#print(psi.shape)
#print(type(psi))
np.savetxt("average_phase.txt", psi)


#print(r.shape)
#print(type(r))
plt.plot(time_seconds, r)
plt.title("Coherence of the oscillator population\n64 channels")
plt.ylabel("Synchronization parameter r")
plt.xlabel("time (seconds)")
plt.ylim(0,1)
plt.savefig("Coherence_plot_64_channels.png", dpi=300)
plt.show()
plt.close()

plt.boxplot(r)
plt.ylabel("Synchronization parameter r")
plt.ylim(-0.1, 1.1)
plt.title(f"Distribution of synchrony values\n64 channels")
plt.savefig(f"box_plot_64_channels.png", dpi=300)
#plt.show()
plt.close()

q_1, q_2, q_3 = np.percentile(r, [25, 50, 75])
#Calcularing r stats
print("max r:", max(r)) 
print("min r:", min(r)) 
print("quartile 1: ", q_1)
print("median: ", q_2)
print("quartile 3", q_3)


r_avg = np.mean(r)
print("average r: ", r_avg)

np.savetxt("order_params.txt", r)

#FFT to find natural frequency
natural_frequencies = [] #order corresponds with channel names
not_plotted = True

for i, ch in enumerate(file_safe_channel_names):
    signal = np.loadtxt(f"cont_{ch}_signal.txt")
    F = sfreq
    L = len(signal)
    fft_vals = np.fft.fft(signal)
    amplitudes = np.abs(fft_vals)
    halved_a = amplitudes[:L//2]
    halved_a[0] = 0 #Ignore DC
    index_of_max_amplitude = np.argmax(halved_a)
    natural_freq = F * index_of_max_amplitude / L
    natural_frequencies.append(natural_freq)
    #print(natural_freq)

    frequencies = []
    for b in range(L):
        f_b = F * (b) / L
        frequencies.append(f_b)
    if(not_plotted):
        plt.plot(frequencies[:L//2], halved_a)
        plt.xlabel("Frequency (Hz)")
        plt.ylabel("Amplitude")
        plt.title(f"FFT for channel {ch}")
        plt.savefig(f"FFT_for_channel_{ch}.png", dpi=300)
        plt.show()
        plt.close()

    not_plotted = False

omega = 2*np.pi*np.array(natural_frequencies) #nautraul angular frequency
np.savetxt("angular_natural_frequenceis.txt", omega)

plt.boxplot(natural_frequencies)
plt.title("Distribution of natural frequencies in 64-channel EEG data") 
plt.savefig("Dist_natural_frequencies.png", dpi=300)
#plt.show()
plt.close()

#print(type(natural_frequencies))

#Take derivative of phase
not_plotted = True
d_theta_array = []
for i, ch in enumerate(file_safe_channel_names):
    #theta = np.loadtxt(f"phase_exth_{ch}.txt")
    #theta = np.deg2rad(theta)
    #theta = theta[samples_1s:]
    theta = phases_array[i]
    if(not_plotted):
        plt.plot(theta[:2000])
        plt.title("Raw phase")
        #plt.show()
        plt.close()

    theta = np.unwrap(theta)
    if(not_plotted):
        plt.plot(theta[:2000])
        plt.title("Unwrapped phase")
        #plt.show()
        plt.close()

    dt = 1/sfreq

    dtheta_dt = np.gradient(theta, dt)
    np.savetxt(f"dtheta_{ch}.txt", dtheta_dt)
    d_theta_array.append(dtheta_dt)
    #Debugging tests
    #print(np.max(np.abs(np.diff(theta))))
    #print(theta.min(), theta.max())
    #print("\n")

    if(not_plotted):
        plt.plot(dtheta_dt[:1000])
        #plt.show()
        plt.close()
        not_plotted = False

#Calculating coupling parameter K, plotting as a function of t
k_t_values = []
theta = phases_array
d_theta = np.array(d_theta_array)

for t in range(len(r)):  
    numerator = d_theta[:, t] - omega
    denominator = r[t] * np.sin(psi[t]-theta[:,t])

    mask = np.abs(denominator) > 0.05
    if np.sum(mask)>5:
        k_t = numerator[mask]/denominator[mask]
        k_t_values.append(np.median(k_t))
    else:
        k_t_values.append(np.nan)

plt.plot(time_seconds, k_t_values)
plt.title("Strength of coupling parameter K between all 64 channels as t varies")
plt.ylabel("K")
plt.xlabel("time (seconds)")
plt.savefig("coupling_param_func_of_t.png", dpi=300)
plt.show()
plt.close()

#Find globlal K,
#This is a useless method, completely inaccurate. Need to do KS fitting instead
k_values=[]
valid_r = (r>0.2) #Too small r leads to unreliable prediction of K
for t in range(len(r)):
    if(valid_r[t]):
        numerator = d_theta[:, t] - omega
        denominator = r[t] * np.sin(psi[t]-theta[:,t])
        mask = np.abs(denominator) > 0.05
    if np.sum(mask)>5:
        k_i = numerator[mask]/denominator[mask] 
        k_values.extend(k_i)

k_global = np.median(k_values)
#print(k_global)

plt.boxplot(k_values)
plt.title("Distribution of k, restricted to r>0.2")
#plt.show()
plt.close()

#Find global K, attempt
func = r*np.sin(psi-theta)
l_side = d_theta - omega[:, np.newaxis]
func_flat = func.flatten()
l_side_flat = l_side.flatten()
mask = np.abs(func_flat)>0.05
func = func_flat[mask][:, np.newaxis]
l_side = l_side_flat[mask][:, np.newaxis]
k = np.linalg.lstsq(func, l_side, rcond=None)[0]
k_glob = k[0,0]
print("global k: ", k_glob)


#Finding critical K
#Visualize distribution of natural frequencies
q25, q50, q75 = np.percentile(omega, [25, 50, 75])
w_center = q50
gamma = 0.5 * (q75 - q25)

w_vals = np.linspace(min(omega), max(omega), 500)
lorenzian_curve = (gamma/np.pi)/((w_vals-w_center)**2 + gamma**2)
plt.figure(figsize=(7,7))
plt.plot(w_vals, lorenzian_curve, color = '#fa980f')
plt.hist(omega, bins=30, density=True, histtype='step', color = 'b', linestyle='dashed')
plt.title("Density distribution of natural frequencies $\omega_i$")
plt.xlabel("Natural angular frequency (Rad/s)")
plt.ylabel("Density")
plt.savefig("lorenzian_frequency_distribution.png", dpi = 300)
plt.show()
plt.close()
#Data is only approximately lorenzian, so critical_k estimation has low accuracy

critical_k = 2*gamma
print("gamma:", gamma)
print("critical k: ", critical_k)
print("\n")


#now try with the 5 channels
#then try epoch after

version1 = ["C3..", "Cz..", "C4..",  "Cp3.", "Cp4."]
version1_names = ["C3", "Cz", "C4", "Cp3", "Cp4"]

version2 = ["C3..", "C4.."]
version2_names = ["C3", "C4"]

version3 = ["Af8.", "Oz.."]
version3_names = ["Af8", "Oz"]

#version4 = []

versions = [version1, version2, version3]
versions_names = [version1_names, version2_names, version3_names]

for b, ver in enumerate(versions):
    motor_channels = ver
    file_safe_motor_channels = versions_names[b]
    motor_phases = []
    for i, ch in enumerate(file_safe_motor_channels):
        m_phase = np.loadtxt(f"phase_exth_{ch}.txt")
        m_phase = np.deg2rad(m_phase)
        motor_phases.append(m_phase)

    motor_phases_array = np.array([m_phase[:min_len] for m_phase in motor_phases], dtype=float)

    N = len(motor_phases)
    r_motors = np.abs(np.sum(np.exp(1j*motor_phases_array), axis=0)/N)
    r_motors = r_motors[samples_1s:]

    motor_q1, motor_q2, motor_q3 = np.percentile(r_motors, [25, 50, 75])
    print("Version ", b+1, " stats: ")
    print("Max r: ", max(r_motors)) 
    print("Min r: ", min(r_motors)) 
    print("Median r: ", motor_q2)
    print("Mean r: ", np.mean(r_motors))
    print("Quartile 1: ", motor_q1)
    print("Quartile 3: ", motor_q3)
    print("\n")

    #print(r_motors.shape)
    #print(type(r_motors))

    plt.plot(time_seconds, r_motors)
    plt.title(f"Coherence of the oscillator population\nChannels: {', '.join(versions_names[b])}")
    plt.ylabel("Synchronization parameter r")
    plt.xlabel("time (seconds)")
    plt.ylim(0,1)
    plt.savefig(f"Coherence_plot_ver{b+1}_channels.png", dpi=300)
    #plt.show()
    plt.close()

    plt.boxplot(r_motors)
    plt.ylabel("Synchronization parameter r")
    plt.ylim(-0.1, 1.1)
    plt.title(f"Distribution of synchrony values\nChannels: {', '.join(versions_names[b])}")
    plt.savefig(f"box_plot_ver{b+1}.png", dpi=300)
    #plt.show()
    plt.close()



#python3 main.py "x_QuasiPeriodic.txt" 0.01
#My ver: file name, channel name, sampling frequency
