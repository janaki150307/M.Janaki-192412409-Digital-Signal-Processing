
clc;
clear;
close all;

%% 1. SYNTHETIC SPEECH GENERATION

Fs = 16000;                  % Sampling rate (Hz)
duration = 0.5;              % Duration (seconds)

t = 0:1/Fs:duration-1/Fs;

f1 = 250;
f2 = 700;

x_speech = sin(2*pi*f1*t) + 0.5*sin(2*pi*f2*t);

%% 2. FRAME-BY-FRAME LPC VOCODER SYNTHESIS

p = 12;                      % Prediction order
N_frame = 320;
hop = 160;

num_frames = floor((length(t)-N_frame)/hop)+1;

x_synth = zeros(1,length(t));
win_gain = zeros(1,length(t));

rng(42);

for m = 1:num_frames

    idx = (m-1)*hop + (1:N_frame);

    frame = x_speech(idx).*hamming(N_frame)';

    % Compute LPC coefficients
    [a,g] = lpc(frame,p);

    % Excitation generation
    excitation = sqrt(max(g,0))*randn(1,N_frame);

    % LPC synthesis filtering
    synth_frame = filter(1,a,excitation);

    % Overlap-add with window
    win = hamming(N_frame)';

    x_synth(idx) = x_synth(idx) + synth_frame.*win;

    win_gain(idx) = win_gain(idx) + win;

end

% Normalize overlap-add output
valid_idx = win_gain > 1e-6;

x_synth(valid_idx) = x_synth(valid_idx)./win_gain(valid_idx);

%% 3. SINGLE FRAME SPECTRAL ANALYSIS

frame_sample = x_speech(161:160+N_frame).*hamming(N_frame)';

[a_sample,g_sample] = lpc(frame_sample,p);

% LPC frequency response
[H_lpc,w] = freqz(sqrt(max(g_sample,0)),a_sample,1024,Fs);

% Power spectral density using Welch method
[X_fft,f_fft] = pwelch(frame_sample,hamming(N_frame),[],N_frame,Fs);

%% 4. COMMAND WINDOW DISPLAY

fprintf('====================================================\n');
fprintf(' EXPERIMENT 20: LPC VOCODER SPEECH SYNTHESIS\n');
fprintf('====================================================\n');

fprintf('Sampling Frequency : %d Hz\n',Fs);
fprintf('Signal Duration : %.2f seconds\n',duration);
fprintf('LPC Prediction Order : %d\n',p);
fprintf('Frame Length : %d samples\n',N_frame);
fprintf('Hop Length : %d samples\n',hop);
fprintf('Number of Frames : %d\n',num_frames);

fprintf('\nSpectral Analysis:\n');
fprintf('LPC Coefficient Count : %d\n',length(a_sample));
fprintf('Excitation Gain : %.4f\n',g_sample);

fprintf('\nStatus: LPC Vocoder Synthesis Completed.\n');
fprintf('====================================================\n');

%% 5. SUBFIGURE PLOTTING AND EXPORT

figW = 8.5;
figH = 5.5;

% Subfigure 20A: Original Speech Signal

figA = figure('Units','centimeters', ...
    'Position',[2,2,figW,figH]);

plot(t(1:640),x_speech(1:640),'b','LineWidth',1.2);
grid on;
box on;

title('Original Speech Signal');
xlabel('Time (s)');
ylabel('Amplitude');

print(figA,'Exp20_SubfigA_OriginalSpeech.png','-dpng','-r300');

% Subfigure 20B: LPC Synthesized Speech Signal

figB = figure('Units','centimeters', ...
    'Position',[11,2,figW,figH]);

plot(t,x_synth,'r','LineWidth',1.2);
grid on;
box on;

title('LPC Vocoder Synthesized Speech Signal');
xlabel('Time (s)');
ylabel('Amplitude');

print(figB,'Exp20_SubfigB_SynthesizedSpeech.png','-dpng','-r300');

% Subfigure 20C: LPC Frequency Response

figC = figure('Units','centimeters', ...
    'Position',[20,2,figW,figH]);

plot(w/1e3,20*log10(abs(H_lpc)+eps),'m','LineWidth',1.2);
grid on;
box on;

title('LPC Spectral Envelope');
xlabel('Frequency (kHz)');
ylabel('Magnitude (dB)');

print(figC,'Exp20_SubfigC_LPCResponse.png','-dpng','-r300');

% Subfigure 20D: Welch Power Spectral Density

figD = figure('Units','centimeters', ...
    'Position',[2,9,figW,figH]);

plot(f_fft/1e3,10*log10(X_fft+eps),'g','LineWidth',1.2);
grid on;
box on;

title('Speech Power Spectral Density using Welch Method');
xlabel('Frequency (kHz)');
ylabel('Power/Frequency (dB/Hz)');

print(figD,'Exp20_SubfigD_WelchPSD.png','-dpng','-r300');

%% 6. COMPLETION MESSAGE

fprintf('\nAll four figures saved successfully.\n');
fprintf('Experiment 20 completed successfully.\n');
