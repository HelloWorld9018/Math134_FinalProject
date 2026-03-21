Run motor_Data_noEpoch.py and alt_main.py together. These files contain my original code. 

Type this in the console to extract the phases and begin the code:
python3 alt_main.py "cont_Fc5_signal.txt" Fc5 0.00625
python3 alt_main.py "cont_Fc3_signal.txt" Fc3 0.00625
python3 alt_main.py "cont_Fc1_signal.txt" Fc1 0.00625
python3 alt_main.py "cont_Fcz_signal.txt" Fcz 0.00625
python3 alt_main.py "cont_Fc2_signal.txt" Fc2 0.00625
python3 alt_main.py "cont_Fc4_signal.txt" Fc4 0.00625
python3 alt_main.py "cont_Fc6_signal.txt" Fc6 0.00625
python3 alt_main.py "cont_C5_signal.txt" C5 0.00625
python3 alt_main.py "cont_C3_signal.txt" C3 0.00625
python3 alt_main.py "cont_C1_signal.txt" C1 0.00625
python3 alt_main.py "cont_Cz_signal.txt" Cz 0.00625
python3 alt_main.py "cont_C2_signal.txt" C2 0.00625
python3 alt_main.py "cont_C4_signal.txt" C4 0.00625
python3 alt_main.py "cont_C6_signal.txt" C6 0.00625
python3 alt_main.py "cont_Cp5_signal.txt" Cp5 0.00625
python3 alt_main.py "cont_Cp3_signal.txt" Cp3 0.00625
python3 alt_main.py "cont_Cp1_signal.txt" Cp1 0.00625
python3 alt_main.py "cont_Cpz_signal.txt" Cpz 0.00625
python3 alt_main.py "cont_Cp2_signal.txt" Cp2 0.00625
python3 alt_main.py "cont_Cp4_signal.txt" Cp4 0.00625
python3 alt_main.py "cont_Cp6_signal.txt" Cp6 0.00625
python3 alt_main.py "cont_Fp1_signal.txt" Fp1 0.00625
python3 alt_main.py "cont_Fpz_signal.txt" Fpz 0.00625
python3 alt_main.py "cont_Fp2_signal.txt" Fp2 0.00625
python3 alt_main.py "cont_Af7_signal.txt" Af7 0.00625
python3 alt_main.py "cont_Af3_signal.txt" Af3 0.00625
python3 alt_main.py "cont_Afz_signal.txt" Afz 0.00625
python3 alt_main.py "cont_Af4_signal.txt" Af4 0.00625
python3 alt_main.py "cont_Af8_signal.txt" Af8 0.00625
python3 alt_main.py "cont_F7_signal.txt" F7 0.00625
python3 alt_main.py "cont_F5_signal.txt" F5 0.00625
python3 alt_main.py "cont_F3_signal.txt" F3 0.00625
python3 alt_main.py "cont_F1_signal.txt" F1 0.00625
python3 alt_main.py "cont_Fz_signal.txt" Fz 0.00625
python3 alt_main.py "cont_F2_signal.txt" F2 0.00625
python3 alt_main.py "cont_F4_signal.txt" F4 0.00625
python3 alt_main.py "cont_F6_signal.txt" F6 0.00625
python3 alt_main.py "cont_F8_signal.txt" F8 0.00625
python3 alt_main.py "cont_Ft7_signal.txt" Ft7 0.00625
python3 alt_main.py "cont_Ft8_signal.txt" Ft8 0.00625
python3 alt_main.py "cont_T7_signal.txt" T7 0.00625
python3 alt_main.py "cont_T8_signal.txt" T8 0.00625
python3 alt_main.py "cont_T9_signal.txt" T9 0.00625
python3 alt_main.py "cont_T10_signal.txt" T10 0.00625
python3 alt_main.py "cont_Tp7_signal.txt" Tp7 0.00625
python3 alt_main.py "cont_Tp8_signal.txt" Tp8 0.00625
python3 alt_main.py "cont_P7_signal.txt" P7 0.00625
python3 alt_main.py "cont_P5_signal.txt" P5 0.00625
python3 alt_main.py "cont_P3_signal.txt" P3 0.00625
python3 alt_main.py "cont_P1_signal.txt" P1 0.00625
python3 alt_main.py "cont_Pz_signal.txt" Pz 0.00625
python3 alt_main.py "cont_P2_signal.txt" P2 0.00625
python3 alt_main.py "cont_P4_signal.txt" P4 0.00625
python3 alt_main.py "cont_P6_signal.txt" P6 0.00625
python3 alt_main.py "cont_P8_signal.txt" P8 0.00625
python3 alt_main.py "cont_Po7_signal.txt" Po7 0.00625
python3 alt_main.py "cont_Po3_signal.txt" Po3 0.00625
python3 alt_main.py "cont_Poz_signal.txt" Poz 0.00625
python3 alt_main.py "cont_Po4_signal.txt" Po4 0.00625
python3 alt_main.py "cont_Po8_signal.txt" Po8 0.00625
python3 alt_main.py "cont_O1_signal.txt" O1 0.00625
python3 alt_main.py "cont_Oz_signal.txt" Oz 0.00625
python3 alt_main.py "cont_O2_signal.txt" O2 0.00625
python3 alt_main.py "cont_Iz_signal.txt" Iz 0.00625

You can find the continuous EEG signals "cont_{channel name}_signal.txt" in this folder. Download these files first. 
They come from the larger dataset:https://physionet.org/content/eegmmidb/1.0.0/. 

The Hilbert transformation code is borrowed from Akari Matsuki.
MIT License
Copyright (c) 2023 Akari Matsuki
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

This folder will also contain important results and figures that were generated from the code.
