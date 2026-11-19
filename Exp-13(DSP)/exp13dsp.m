
clc;
clear;
close all;

%% 1. INPUT PARAMETERS
N = 24;              % FIR Filter Order
M = 2;               % Decimation Factor
Fs = 8000;            % Sampling Frequency in Hz
N_samples = 128;      % Number of samples

% FIR Prototype Filter
b = fir1(N, 0.4);

% Polyphase Decomposition for M = 2
E0 = b(1:M:end);      % Branch 0 (Even indices)
E1 = b(2:M:end);      % Branch 1 (Odd indices)

% Input Signal: 500 Hz Sinusoid
t = (0:N_samples-1) / Fs;
x = sin(2*pi*500*t);

%% 2. CONVENTIONAL VS POLYPHASE DECIMATION

% Direct Path: Filtering followed by Downsampling
y_direct_full = filter(b, 1, x);
y_direct = y_direct_full(1:M:end);

% Polyphase Path
x0 = x(1:M:end);
x_delayed = [0, x(1:end-1)];
x1 = x_delayed(1:M:end);

y_poly = filter(E0, 1, x0) + filter(E1, 1, x1);

% Verification
rec_error = max(abs(y_direct - y_poly));

% Computational Complexity
N_taps = length(b);
N_in = length(x);
N_out = length(y_direct);

MAC_direct = N_in * N_taps;
MAC_poly = N_out * N_taps;

comp_saving = (1 - (MAC_poly / MAC_direct)) * 100;

%% 3. COMMAND WINDOW DISPLAY

fprintf('============================================================\n');
fprintf(' EXPERIMENT 13: POLYPHASE DECOMPOSITION OF DECIMATION FILTER\n');
fprintf('============================================================\n');

fprintf('Decimation Factor (M) : %d\n', M);
fprintf('Filter Order (N) : %d (%d Taps)\n', N, N_taps);
fprintf('Input Signal : 500 Hz Sinusoid (%d samples)\n', N_samples);
fprintf('Sampling Frequency (Fs) : %d Hz\n\n', Fs);

fprintf('Polyphase Sub-Filter Coefficients:\n');

fprintf('E0(z) = [');
fprintf('%.4f ', E0);
fprintf(']\n');

fprintf('E1(z) = [');
fprintf('%.4f ', E1);
fprintf(']\n\n');

fprintf('COMPUTATIONAL COMPLEXITY ANALYSIS:\n');
fprintf('Direct MAC Operations : %d MACs\n', MAC_direct);
fprintf('Polyphase MAC Operations : %d MACs\n', MAC_poly);
fprintf('Computational Savings : %.2f%%\n\n', comp_saving);

fprintf('VERIFICATION:\n');
fprintf('Max Absolute Difference : %.4e\n', rec_error);

if rec_error < 1e-12
    fprintf('Status : Perfect Reconstruction Verified!\n');
else
    fprintf('Status : Verification Failed\n');
end

fprintf('============================================================\n');

%% 4. SUBFIGURE GENERATION

figW = 8.5;
figH = 5.5;

% Subfigure 13A: Prototype Impulse Response
figA = figure('Units', 'centimeters', ...
    'Position', [2, 2, figW, figH]);

stem(0:N, b, 'filled', 'LineWidth', 1.2);
grid on;
box on;

title('Prototype FIR Filter Impulse Response');
xlabel('Sample Index (n)');
ylabel('Coefficient Value');

print(figA, 'Exp13_SubfigA_Prototype.png', '-dpng', '-r300');

% Subfigure 13B: Sub-filter Coefficients
figB = figure('Units', 'centimeters', ...
    'Position', [11, 2, figW, figH]);

stem(0:length(E0)-1, E0, 'b', 'filled', 'LineWidth', 1.2);
hold on;

stem(0:length(E1)-1, E1, 'r--', 'LineWidth', 1.2);

grid on;
box on;

title('Polyphase Sub-Filter Coefficients (M=2)');
xlabel('Sub-Filter Sample Index');
ylabel('Coefficient Value');

legend('Branch E0[n]', 'Branch E1[n]', 'FontSize', 7);

print(figB, 'Exp13_SubfigB_Polyphase.png', '-dpng', '-r300');

% Subfigure 13C: Time-Domain Output Comparison
figC = figure('Units', 'centimeters', ...
    'Position', [20, 2, figW, figH]);

plot(y_direct(1:50), 'b', 'LineWidth', 1.5);
hold on;

plot(y_poly(1:50), 'r--', 'LineWidth', 1.5);

grid on;
box on;

title('Time-Domain Output Comparison');
xlabel('Sample Index');
ylabel('Amplitude');

legend('Direct Decimation', 'Polyphase Decimation', 'FontSize', 7);

print(figC, 'Exp13_SubfigC_OutputComparison.png', '-dpng', '-r300');

%% 5. COMPLETION MESSAGE

fprintf('\nAll three figures saved successfully as PNG files.\n');
fprintf('Experiment 13 completed successfully.\n');
