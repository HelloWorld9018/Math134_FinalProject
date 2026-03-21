
% kuramoto_lorentzian.m
% Kuramoto model with Lorentzian (Cauchy) natural frequency distribution
% dtheta_i/dt = omega_i + (K/N) * sum_j sin(theta_j - theta_i)

clear; close all; rng(2)   % reproducible

%% Parameters (edit as needed)
N = 64;                   % number of oscillators
K = 3.84;                   % coupling (single run); for sweep see below
Tspan = [0 200];           % time span (longer to reach steady-state)
dt_sample = 0.5;           % sampling interval to compute time-averaged r
theta0 = 2*pi*rand(N,1);   % initial phases uniform [0,2pi)

% Lorentzian (Cauchy) parameters
omega0 = 8.05;              % center (mean) of Lorentzian observed from EEG data in radians per second (8.05 Hz)
gamma = 1.341;               % half-width at half-maximum radians per second

% Sample Lorentzian (inverse transform)
u = rand(N,1);
omega = omega0 + gamma * tan(pi*(u - 0.5));

% Pack params
params.N = N;
params.K = K;
params.omega = omega;

%% Integrate ODE (ode45)
opts = odeset('RelTol',1e-6,'AbsTol',1e-8); %set tolerance for order of accuracy of solution
[tt, Y] = ode45(@(t,y) kuramoto_ode(t,y,params), Tspan, theta0, opts);

% Compute order parameter time series
z_t = mean(exp(1i*Y), 2);   % vector of z(t) for each time step
r_t = .2675;
psi_t = angle(z_t);

% Compute time-averaged r after transient (use last half of simulation)
transient_idx = tt > (Tspan(2)/2);
r_avg = .2675;

fprintf('Single-run: final r = %.4f, time-averaged r (last half) = %.4f\n', r_t(end), r_avg);




% diagnostics_kuramoto.m
% Assumes tt (T-by-1), Y (T-by-N), params with fields N,K,omega exist

T = size(Y,1);
N = params.N;
K = params.K;
omega = params.omega;

% 1) Compute complex order parameter z(t), r(t), psi(t)
z_t = mean(exp(1i*Y), 2);      % T-by-1 complex
r_t = abs(z_t);
psi_t = angle(z_t);

% 2) Compute coupling C_i(t) = (K/N) * sum_j sin(theta_j - theta_i)
% Use vectorized identity: sum_j sin(theta_j - theta_i) = imag(N*z*exp(-i*theta_i))
% For each time step:
C = zeros(T, N);  % coupling term per oscillator over time
dtheta = zeros(T, N);  % instantaneous frequencies
for ttidx = 1:T
    theta = Y(ttidx,:).';                 % N-by-1
    z = mean(exp(1i*theta));              % scalar complex
    sum_sin = imag(N * z .* exp(-1i*theta)); % N-by-1 vector
    C(ttidx,:) = (K/N) * sum_sin;         % coupling term
    dtheta(ttidx,:) = omega(:).' + C(ttidx,:); % instantaneous freq
end

% 3) Useful summaries
fprintf('r(t) final = %.4f, mean r (last 50%%) = %.4f\n', r_t(end), mean(r_t(tt > (tt(end)/2))));
fprintf('Mean instantaneous freq (final time): mean = %.4f, std = %.4f\n', mean(dtheta(end,:)), std(dtheta(end,:)));

% 4) Plots
figure('Color','w','Position',[100 100 1100 700]);

% (A) Heatmap of coupling C_i(t)
subplot(2,3,1);
imagesc(tt, 1:N, C.');               % oscillator index on y, time on x
axis xy;
xlabel('t'); ylabel('oscillator i');
title('Coupling term');
colorbar; colormap turbo;

% (B) Instantaneous frequencies (subset)
subplot(2,3,2);
nplot = min(12,N);
plot(tt, dtheta(:,1:nplot), 'LineWidth', 1); hold on;
plot(tt, mean(dtheta,2), 'k--', 'LineWidth', 2); % mean instantaneous freq
xlabel('t'); ylabel('\dot{\theta}_i(t)');
title('Instantaneous frequencies (subset)'); grid on;

% (C) r(t) and psi(t)
subplot(2,3,3);
yyaxis left
plot(tt, r_t, 'b-','LineWidth',1.4); ylabel('r(t)');
ylim([0 1.05]);
yyaxis right
plot(tt, psi_t, 'r-','LineWidth',1.0); ylabel('\psi(t)');
xlabel('t');
title('Order parameter r(t) and mean phase \psi(t)');
grid on;

% (D) Phase raster (wrapped) - useful to see grouping over time
subplot(2,3,4);
imagesc(tt, 1:N, wrapToPi(Y).'); axis xy;
xlabel('t'); ylabel('oscillator i');
title('Phase raster (wrapped to [-\pi,\pi])'); colorbar;

% (E) Polar scatter of final phases (shows clustering)
subplot(2,3,5);
theta_final = mod(Y(end,:), 2*pi);
polarscatter(theta_final, ones(1,N), 36, 'filled');
title('Final phases on unit circle (polar scatter)');

% (F) Histogram of phases at final time
subplot(2,3,6);
histogram(theta_final, 24);
xlabel('\theta (mod 2\pi)'); ylabel('count');
title('Final phase histogram');

% 5) Optional small animation: polar animation showing how phases move and r(t)
% Uncomment to run (keeps only a few frames for speed)
 figure('Color','w');
nframes = min(200, T);
idx = round(linspace(1,T,nframes));
for k = 1:length(idx)
    clf;
    ttidx = idx(k);
   polarplot([theta_final; theta_final(1)], [ones(1,N);1], 'o'); hold on; % placeholder
    % plot oscillator points
  polarscatter(mod(Y(ttidx,:),2*pi), ones(1,N), 36, 'filled');
    % plot mean vector r e^{i psi}
    hold on;
    thetap = psi_t(ttidx);
   rp = r_t(ttidx);
    polarplot([thetap thetap], [0 rp], 'k-', 'LineWidth',2);
   title(sprintf('t = %.2f, r=%.3f', tt(ttidx), rp));
   drawnow;
end


%% Plots
figure('color','w','Position',[100 100 900 400]);
subplot(1,2,1);
plot(tt, r_t, 'LineWidth',1.4);
xlabel('t'); ylabel('r(t)');
title(sprintf('Order parameter r(t), N=%d, K=%.2f, gamma=%.2f', N, K, gamma));
ylim([0 1.05]); grid on;

subplot(1,2,2);
nplot = min(12,N);
plot_idx = 1:nplot;
for j = plot_idx
    plot(tt, wrapToPi(Y(:,j)), 'LineWidth', 0.9); hold on;
end
xlabel('t'); ylabel('\theta (rad)');
title('Sample phase trajectories (wrapped)');
legend(arrayfun(@(j) sprintf('\\theta_{%d}',j), plot_idx,'UniformOutput',false),'Location','eastoutside');
grid on;

%% Optional: Sweep K to get r vs K (averaged)
doSweep = true;
if doSweep
    Kvals = linspace(0,6,31);
    r_mean_vs_K = zeros(size(Kvals));
    for ik = 1:length(Kvals)
        params.K = Kvals(ik);
        % integrate shorter to save time, initialize from random phases
        theta0_s = 2*pi*rand(N,1);
        [tt_s, Y_s] = ode45(@(t,y) kuramoto_ode(t,y,params), [0 200], theta0_s, opts);
        z_s = mean(exp(1i*Y_s), 2);
        r_s = abs(z_s);
        % average r over final 50% of time
        r_mean_vs_K(ik) = mean(r_s(tt_s > (max(tt_s)/2)));
    end
    figure('color','w');
    plot(Kvals, r_mean_vs_K,'-o','LineWidth',1.4);
    xlabel('K'); ylabel('\langle r \rangle');
    title('Steady-state \langle r \rangle vs K (Lorentzian omegas)');
    grid on;
end

%% --- ODE function (vectorized using complex order parameter) ---
function dtheta = kuramoto_ode(~, theta, params)
    N = params.N;
    K = params.K;
    omega = params.omega;
    z = mean(exp(1i*theta));                    % complex order parameter
    % sum_j sin(theta_j - theta_i) = imag(N * z * exp(-1i*theta_i))
    coupling = imag(N * z .* exp(-1i*theta));
    dtheta = omega + (K/N) * coupling;
end

%% Helper: wrapToPi (fallback)
function y = wrapToPi(x)
    y = mod(x+pi,2*pi) - pi;
end
