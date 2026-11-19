
clear;
clc;
close all;

%% 1. PARAMETER DEFINITIONS

fc_carrier = 28e9;       % Carrier Frequency (28 GHz)
Fs_in = 1000e6;           % Input Sampling Frequency (1000 MHz)
M = 4;                   % Decimation Factor
L = 2;                   % Interpolation Factor

Fs_dec = Fs_in / M;      % Decimated Sampling Frequency (250 MHz)
Fs_out = Fs_dec * L;     % Output Sampling Frequency (500 MHz)

N_samples = 4000;
t_in = (0:N_samples-1) / Fs_in;

% Generate 5G-like Multitone Baseband Signal
f1 = 15e6;
f2 = 35e6;

x_in = sin(2*pi*f1*t_in) + 0.5*cos(2*pi*f2*t_in);

%% 2. DECIMATION STAGE

N_fir = 60;

% Anti-Aliasing Filter
fc_dec = 0.4;   % Normalized cutoff frequency

b_dec = fir1(N_fir, fc_dec, 'low');

% Filtering and Downsampling
x_filtered_dec = filter(b_dec, 1, x_in);

x_dec = x_filtered_dec(1:M:end);

%% 3. INTERPOLATION STAGE

% Upsampling by factor L
x_up = zeros(1, length(x_dec)*L);

x_up(1:L:end) = x_dec;

% Anti-Imaging Filter
fc_interp = 0.8;

b_interp = fir1(N_fir, fc_interp, 'low');

% Filtering and Scaling
x_out = L * filter(b_interp, 1, x_up);

%% 4. PERFORMANCE METRICS

[H, f] = freqz(b_dec, 1, 2048, Fs_in);

H_mag_db = 20*log10(abs(H) + eps);

pb_idx = f <= (Fs_dec/2 * 0.8);
sb_idx = f >= (Fs_dec/2);

passband_ripple = max(H_mag_db(pb_idx)) - min(H_mag_db(pb_idx));

stopband_atten = -max(H_mag_db(sb_idx));

%% 5. COMMAND WINDOW DISPLAY

fprintf('========================================================\n');
fprintf(' EXPERIMENT 14: 5G mmWave MULTIRATE PROCESSING RESULTS\n');
fprintf('========================================================\n');

fprintf('Carrier Frequency: %.2f GHz\n', fc_carrier/1e9);
fprintf('Input Sampling Rate: %.2f MHz\n', Fs_in/1e6);
fprintf('Decimation Factor (M): %d\n', M);
fprintf('Downsampled Sampling Rate: %.2f MHz\n\n', Fs_dec/1e6);

fprintf('Signal Parameters:\n');
fprintf(' - Original Sequence Length: %d samples\n', length(x_in));
fprintf(' - Downsampled Sequence Length: %d samples\n', length(x_dec));
fprintf(' - Interpolated Sequence Length: %d samples\n', length(x_out));
fprintf(' - Passband Ripple: %.2f dB\n', passband_ripple);
fprintf(' - Stopband Attenuation: %.2f dB\n\n', stopband_atten);

fprintf('Status: 5G mmWave Downconversion & Multirate Filtering Complete.\n');
fprintf('========================================================\n');

%% 6. SPECTRUM CALCULATION USING FFT

Nfft = 4096;

% Original Signal Spectrum
X_in = fft(x_in, Nfft);

f_in = (0:Nfft/2) * (Fs_in/Nfft);

X_in_mag = abs(X_in(1:Nfft/2+1));
X_in_db = 20*log10(X_in_mag/max(X_in_mag) + eps);

% Decimated Signal Spectrum
X_dec = fft(x_dec, Nfft);

f_dec = (0:Nfft/2) * (Fs_dec/Nfft);

X_dec_mag = abs(X_dec(1:Nfft/2+1));
X_dec_db = 20*log10(X_dec_mag/max(X_dec_mag) + eps);

% Interpolated Signal Spectrum
X_out = fft(x_out, Nfft);

f_out = (0:Nfft/2) * (Fs_out/Nfft);

X_out_mag = abs(X_out(1:Nfft/2+1));
X_out_db = 20*log10(X_out_mag/max(X_out_mag) + eps);

%% 7. VISUALIZATION

figure('Name', 'Experiment 14: Multirate mmWave Processing', ...
       'NumberTitle', 'off');

% Plot 1: Original Signal
subplot(3,1,1);

plot(f_in/1e6, X_in_db, 'b', 'LineWidth', 1.2);
grid on;

title('1. Original Baseband Signal Spectrum (Fs = 1000 MHz)');
xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');

xlim([0 Fs_in/2/1e6]);
ylim([-80 5]);

% Plot 2: Decimated Signal
subplot(3,1,2);

plot(f_dec/1e6, X_dec_db, 'r', 'LineWidth', 1.2);
grid on;

title('2. Decimated Signal Spectrum (M = 4, Fs = 250 MHz)');
xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');

xlim([0 Fs_dec/2/1e6]);
ylim([-80 5]);

% Plot 3: Interpolated Signal
subplot(3,1,3);

plot(f_out/1e6, X_out_db, 'm', 'LineWidth', 1.2);
grid on;

title('3. Interpolated Output Signal Spectrum (L = 2, Fs = 500 MHz)');
xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');

xlim([0 Fs_out/2/1e6]);
ylim([-80 5]);

%% 8. SAVE FIGURE

print(gcf, 'Exp14_Multirate_Processing.png', '-dpng', '-r300');

fprintf('\nExperiment 14 completed successfully.\n');
fprintf('Spectrum graph saved successfully.\n');
