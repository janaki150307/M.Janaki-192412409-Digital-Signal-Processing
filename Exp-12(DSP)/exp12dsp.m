
clc;
clear;
close all;

%% 1. SIGNAL GENERATION
Fs = 8000;
f1 = 500;
f2 = 1500;

M = 2;
L = 2;

N = 1000;

fc_dec = 1800;
fc_interp = 3600;

n = 0:N-1;
t = n/Fs;

x = sin(2*pi*f1*t) + 0.8*sin(2*pi*f2*t);

%% 2. DECIMATION

% Direct downsampling
x_down_direct = x(1:M:end);
Fs_dec = Fs/M;

% Anti-aliasing filter
b_dec = fir1(60,fc_dec/(Fs/2));

x_dec_filtered = filter(b_dec,1,x);
x_dec = x_dec_filtered(1:M:end);

%% 3. INTERPOLATION

% Upsampling
x_up = zeros(1,length(x)*L);
x_up(1:L:end) = x;

Fs_interp = Fs*L;

% Anti-imaging filter
b_interp = L*fir1(60,fc_interp/(Fs_interp/2));

x_interp_filtered = filter(b_interp,1,x_up);

%% 4. COMMAND WINDOW DISPLAY

fprintf('\n============================================\n');
fprintf(' EXPERIMENT 12: MULTIRATE SIGNAL PROCESSING\n');
fprintf('============================================\n');

fprintf('Original Sampling Frequency : %d Hz\n',Fs);
fprintf('Decimation Factor : %d\n',M);
fprintf('Sampling Frequency after Decimation : %d Hz\n\n',Fs_dec);

fprintf('Interpolation Factor : %d\n',L);
fprintf('Sampling Frequency after Interpolation : %d Hz\n\n',Fs_interp);

fprintf('Signal Lengths:\n');
fprintf('Original Signal : %d samples\n',length(x));
fprintf('Decimated Signal : %d samples\n',length(x_dec));
fprintf('Interpolated Signal : %d samples\n',length(x_interp_filtered));

fprintf('\nStatus: Decimation and Interpolation completed successfully.\n');
fprintf('============================================\n');

%% 5. SPECTRUM COMPUTATION

Nfft = 2048;

% Original signal
X = fftshift(fft(x,Nfft));
X_mag = abs(X)/length(x);
f_x = (-Nfft/2:Nfft/2-1)*(Fs/Nfft);

% Direct decimated signal
X1 = fftshift(fft(x_down_direct,Nfft));
X_down_mag = abs(X1)/length(x_down_direct);
f_down = (-Nfft/2:Nfft/2-1)*(Fs_dec/Nfft);

% Filtered decimated signal
X2 = fftshift(fft(x_dec,Nfft));
X_dec_mag = abs(X2)/length(x_dec);
f_dec = (-Nfft/2:Nfft/2-1)*(Fs_dec/Nfft);

% Upsampled signal
X3 = fftshift(fft(x_up,Nfft));
X_up_mag = abs(X3)/length(x_up);
f_up = (-Nfft/2:Nfft/2-1)*(Fs_interp/Nfft);

% Filtered interpolated signal
X4 = fftshift(fft(x_interp_filtered,Nfft));
X_interp_mag = abs(X4)/length(x_interp_filtered);
f_interp = (-Nfft/2:Nfft/2-1)*(Fs_interp/Nfft);

%% 6. SUBFIGURE 12A: ORIGINAL SIGNAL

figure;

subplot(2,1,1);
plot(t(1:100)*1000,x(1:100),'b','LineWidth',1.2);
grid on;
title('Original Input Waveform');
xlabel('Time (ms)');
ylabel('Amplitude');

subplot(2,1,2);
plot(f_x,X_mag,'b','LineWidth',1.2);
grid on;
title('Original Spectrum (Fs = 8000 Hz)');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

print(gcf,'-dpng','-r300','Exp12_SubfigA_Original.png');

%% 7. SUBFIGURE 12B: DECIMATED SIGNAL

figure;

t_dec = (0:length(x_dec)-1)/Fs_dec;

subplot(2,1,1);
plot(t_dec(1:50)*1000,x_dec(1:50),'r','LineWidth',1.2);
grid on;
title('Decimated Waveform (M = 2)');
xlabel('Time (ms)');
ylabel('Amplitude');

subplot(2,1,2);
plot(f_down,X_down_mag,'k--','LineWidth',1);
hold on;
plot(f_dec,X_dec_mag,'r','LineWidth',1.2);
grid on;
title('Decimated Spectra');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
legend('Direct','Filtered');

print(gcf,'-dpng','-r300','Exp12_SubfigB_Decimated.png');

%% 8. SUBFIGURE 12C: INTERPOLATED SIGNAL

figure;

t_interp = (0:length(x_interp_filtered)-1)/Fs_interp;

subplot(2,1,1);
plot(t_interp(1:200)*1000,x_interp_filtered(1:200),'m','LineWidth',1.2);
grid on;
title('Interpolated Waveform (L = 2)');
xlabel('Time (ms)');
ylabel('Amplitude');

subplot(2,1,2);
plot(f_up,X_up_mag,'k--','LineWidth',1);
hold on;
plot(f_interp,X_interp_mag,'m','LineWidth',1.2);
grid on;
title('Interpolated Spectra');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
legend('Direct','Filtered');

print(gcf,'-dpng','-r300','Exp12_SubfigC_Interpolated.png');

%% 9. COMPLETED

disp('All graphs generated successfully.');
disp('All three figures saved as PNG files.');
