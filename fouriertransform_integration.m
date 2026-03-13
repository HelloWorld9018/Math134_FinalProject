
% image_fourier_approx_script.m
% Read an image from a specified path, compute a low-mode Fourier approximation,
% and display original, spectra, truncated spectra, and reconstruction.
%
% Edit the path and the Nx, Ny parameters below as desired.

% --- User settings ---
filename = 'C:\Users\jakeb\OneDrive\Pictures\Screenshots\Screenshot 2026-03-10 132034.png';
Nx = 100;   % number of low-frequency modes to keep in x-direction (half-width)
Ny = 100;   % number of low-frequency modes to keep in y-direction (half-width)

% --- Read and convert to grayscale double in [0,1]
Irgb = imread(filename);
if size(Irgb,3) == 3
    I = rgb2gray(Irgb);
else
    I = Irgb;
end
I = im2double(I);

% --- Original size
[M, N] = size(I);

% --- 2D Fourier transform
F = fft2(I);

% --- Shift zero-frequency to center for visualization and masking
Fsh = fftshift(F);

% --- Export ALL Fourier coefficients (full F) to CSV (centered frequency indices)
% Warning: this CSV will have M*N rows; can be very large for big images.
outAllCSV = 'all_coeffs.csv';

% Build centered frequency index grids (same convention used later)
kx = (-floor(N/2)):(ceil(N/2)-1);   % length N
ky = (-floor(M/2)):(ceil(M/2)-1);   % length M
[KX_all, KY_all] = meshgrid(kx, ky);

% Use the shifted full spectrum (center at 0,0)
Fsh_full = Fsh;         % already computed above

% Flatten into columns
vals_full = Fsh_full(:);
kx_full = KX_all(:);
ky_full = KY_all(:);

% Prepare table of all coefficients
Re_full = real(vals_full);
Im_full = imag(vals_full);
Mag_full = abs(vals_full);
Phase_full = angle(vals_full);

Tfull = table(kx_full, ky_full, Re_full, Im_full, Mag_full, Phase_full, ...
    'VariableNames', {'kx','ky','Re','Im','Mag','Phase'});

% Write to CSV (may take time & disk space)
writetable(Tfull, outAllCSV);
fprintf('Wrote full %d-by-%d coefficient list (%d rows) to %s\n', M, N, height(Tfull), outAllCSV);

% --- Build a rectangular low-pass mask in the shifted frequency domain.
% Keep central (low) frequencies: indices within Nx and Ny of the center.
cx = floor(N/2) + 1;  % center column index
cy = floor(M/2) + 1;  % center row index

mask = zeros(M, N);
kx_min = max(1, cx - Nx);
kx_max = min(N, cx + Nx);
ky_min = max(1, cy - Ny);
ky_max = min(M, cy + Ny);
mask(ky_min:ky_max, kx_min:kx_max) = 1;

% --- Apply mask and unshift back
Fsh_trunc = Fsh .* mask;
F_trunc = ifftshift(Fsh_trunc);

% Dimensions and normalization
[M, N] = size(I);
MN = M * N;

% Ensure shifted truncated spectrum
Fsh_trunc = fftshift(F_trunc);

% horizontal angular frequency vector (rad/sample)
fx = (-floor(N/2):(ceil(N/2)-1))' * (1 / N);   % cycles/sample
omega_x = 2*pi * fx;                          % angular frequency vector length N

% complex a_hat along horizontal freq: mean over rows, normalize by MN
ahat_x = mean(Fsh_trunc, 1).' / MN;           % column vector (N x 1)

% Interpolate your Lorentzian g (defined on w) to omega_x
% (Assumes you defined w and g earlier; w in same units as omega_x)
g_on_omega_x = interp1(w, g, omega_x, 'linear', 0);

% Compute integral
z_x = trapz(omega_x, ahat_x .* g_on_omega_x);

fprintf('z (horizontal) = %.12g + %.12g i\n', real(z_x), imag(z_x));

% --- Save Fourier coefficient matrices to .mat file
outMatFile = 'fourier_coeffs.mat';
save(outMatFile, 'F', 'F_trunc', 'mask', '-v7.3');
fprintf('Saved full and truncated FFT matrices to %s\n', outMatFile);

% --- Export nonzero truncated coefficients to CSV (indices + real + imag)
% Decide whether you want center-based frequency indices (k,l) in range
% -floor(N/2):floor(N/2) etc., or simple matrix indices (1..N,1..M).
% Here we output centered frequency indices (kx, ky) using MATLAB fftshift convention.

% Shift the truncated spectrum so center is at (0,0) indices
Fsh_trunc = fftshift(F_trunc);  % if already shifted earlier, ensure correct orientation

% Build centered frequency index grids
% Note: M = number of rows (y direction), N = number of cols (x direction)
kx = (-floor(N/2)):(ceil(N/2)-1);  % length N
ky = (-floor(M/2)):(ceil(M/2)-1);  % length M
[KX, KY] = meshgrid(kx, ky);       % KY: rows, KX: cols

% Extract nonzero (kept) coefficients from shifted truncated spectrum
vals = Fsh_trunc(:);
maskvec = mask(:);                 % mask was built in shifted domain earlier
kept_idx = find(maskvec);          % linear indices of kept coefficients

% Prepare table: centered kx, ky, real, imag, magnitude, phase
kx_kept = KX(kept_idx).';
ky_kept = KY(kept_idx).';
real_kept = real(vals(kept_idx)).';
imag_kept = imag(vals(kept_idx)).';
mag_kept  = abs(vals(kept_idx)).';
phase_kept = angle(vals(kept_idx)).';

T = table(kx_kept.', ky_kept.', real_kept.', imag_kept.', mag_kept.', phase_kept.', ...
    'VariableNames', {'kx','ky','Re','Im','Mag','Phase'});

outCSV = 'truncated_coeffs.csv';
writetable(T, outCSV);
fprintf('Wrote %d truncated coefficients to %s\n', height(T), outCSV);

% --- (Optional) If you want the full coefficient list (including zeros), you can export similarly,
% but CSV will be large for big images. Use .mat for full matrices (already saved).



% --- Inverse FFT to get approximation
I_approx = real(ifft2(F_trunc));

% --- Clip to [0,1] for display
I_approx = min(max(I_approx, 0), 1);

% --- Display results
figure('Name','Fourier Approximation','NumberTitle','off','Color','w','Position',[100 100 1000 600]);

subplot(2,2,1);
imshow(I,[]);
title('Original image');

subplot(2,2,2);
imshow(log(1+abs(Fsh)),[]);
title('Log magnitude spectrum (shifted)');

subplot(2,2,3);
imshow(log(1+abs(Fsh_trunc)),[]);
title(sprintf('Truncated spectrum (Nx=%d, Ny=%d)', Nx, Ny));

subplot(2,2,4);
imshow(I_approx,[]);
title('Reconstructed (low-mode)');

% --- Show difference and print RMS error
err = I - I_approx;
rms_err = sqrt(mean(err(:).^2));
fprintf('Reconstruction RMS error = %g\n', rms_err);


% Optional: save the reconstructed image
% imwrite(I_approx, 'fourier_approx_output.png');
dir('all_coeffs.csv');
  
% Define parameters
w0 = 4; % Peak
gamma = .67; % HWHM

% Generate range
w = -10:.0001:40;
% Calculate Lorentzian
g = (1/pi) * (gamma ./ ((w - w0).^2 + gamma^2));


disp(z_x);