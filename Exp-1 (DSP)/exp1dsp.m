clear;
clc;
close all;

% ================================
% Design Parameters (from Lab Manual)
% ================================
Fs = 1000;   % Sampling frequency (Hz)
Ap = 1;      % Passband ripple (dB)
As = 40;     % Stopband attenuation (dB)

% ================================
% 1. Low-Pass Filter Design
% ================================
fp_lp = 100;    % Passband edge (Hz)
fs_lp = 150;    % Stopband edge (Hz)

wp_lp = fp_lp / (Fs/2);   % Normalized passband
ws_lp = fs_lp / (Fs/2);   % Normalized stopband

[N_lp, Wn_lp] = buttord(wp_lp, ws_lp, Ap, As);
[b_lp, a_lp] = butter(N_lp, Wn_lp, 'low');

% ================================
% 2. High-Pass Filter Design
% ================================
fp_hp = 250;    % Passband edge (Hz)
fs_hp = 200;    % Stopband edge (Hz)

wp_hp = fp_hp / (Fs/2);
ws_hp = fs_hp / (Fs/2);

[N_hp, Wn_hp] = buttord(wp_hp, ws_hp, Ap, As);
[b_hp, a_hp] = butter(N_hp, Wn_hp, 'high');

% ================================
% Display Results
% ================================
fprintf('=== EXPERIMENT 1: BUTTERWORTH IIR FILTERS ===\n\n');

fprintf('--- LOW-PASS FILTER ---\n');
fprintf('Filter Order (N_lp): %d\n', N_lp);
fprintf('Cutoff Frequency: %.2f Hz\n', Wn_lp * (Fs/2));
disp('Numerator Coefficients (b_lp):');
disp(b_lp);
disp('Denominator Coefficients (a_lp):');
disp(a_lp);

fprintf('--- HIGH-PASS FILTER ---\n');
fprintf('Filter Order (N_hp): %d\n', N_hp);
fprintf('Cutoff Frequency: %.2f Hz\n', Wn_hp * (Fs/2));
disp('Numerator Coefficients (b_hp):');
disp(b_hp);
disp('Denominator Coefficients (a_hp):');
disp(a_hp);

% ================================
% Frequency Response
% ================================
[H_lp, f] = freqz(b_lp, a_lp, 1024, Fs);
[H_hp, ~] = freqz(b_hp, a_hp, 1024, Fs);

% ================================
% Plotting
% ================================
figure('Name','Butterworth IIR LPF and HPF');

% LPF Magnitude
subplot(2,2,1);
plot(f, 20*log10(abs(H_lp)), 'b', 'LineWidth', 1.5);
grid on;
title(['LPF Magnitude Response (Order N = ', num2str(N_lp), ')']);
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
ylim([-80 5]);

% LPF Phase
subplot(2,2,2);
plot(f, unwrap(angle(H_lp))*180/pi, 'r', 'LineWidth', 1.5);
grid on;
title('LPF Phase Response');
xlabel('Frequency (Hz)');
ylabel('Phase (degrees)');

% HPF Magnitude
subplot(2,2,3);
plot(f, 20*log10(abs(H_hp)), 'b', 'LineWidth', 1.5);
grid on;
title(['HPF Magnitude Response (Order N = ', num2str(N_hp), ')']);
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
ylim([-80 5]);

% HPF Phase
subplot(2,2,4);
plot(f, unwrap(angle(H_hp))*180/pi, 'r', 'LineWidth', 1.5);
grid on;
title('HPF Phase Response');
xlabel('Frequency (Hz)');
ylabel('Phase (degrees)');
