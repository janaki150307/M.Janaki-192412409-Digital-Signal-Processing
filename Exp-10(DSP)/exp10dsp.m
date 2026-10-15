clc;
clear;
close all;

% INPUT PARAMETERS
b = [0.0048 0.0193 0.0289 0.0193 0.0048];
a = [1 -2.3695 2.3140 -1.0547 0.1874];

Bc = 8;
Bp = 16;
N = 200;

x = [1 zeros(1,N-1)];

% COEFFICIENT QUANTIZATION
S = 2^(Bc-1)-1;

bq = round(b*S)/S;
aq = round(a*S)/S;

% IDEAL AND QUANTIZED OUTPUTS
y_ideal = filter(b,a,x);
y_coeff = filter(bq,aq,x);

e_coeff = y_ideal-y_coeff;

MaxCoeffError = max(abs(e_coeff));
SQNR_coeff = 10*log10(sum(y_ideal.^2)/ ...
    max(sum(e_coeff.^2),eps));

% PRODUCT QUANTIZATION
Sp = 2^(Bp-1)-1;

y_prod = zeros(1,N);
v = zeros(1,4);

for n = 1:N
    p = bq*x(n);
    fb = -aq(2:5).*v;
    p = round([p fb]*Sp)/Sp;
    y_prod(n) = sum(p);
    v = [y_prod(n) v(1:3)];
end

e_prod = y_coeff-y_prod;

MaxProdError = max(abs(e_prod));
SQNR_prod = 10*log10(sum(y_coeff.^2)/ ...
    max(sum(e_prod.^2),eps));

% ZERO INPUT LIMIT CYCLE TEST
state = [0.01 0.01 0.01 0.01];
y_zero = zeros(1,N);

for n = 1:N
    acc = -aq(2:5)*state.';
    y_zero(n) = round(acc*Sp)/Sp;
    state = [y_zero(n) state(1:3)];
end

LimitAmplitude = max(abs(y_zero));
LimitSamples = find(abs(y_zero)>1e-12);

% OVERFLOW AND SATURATION TEST
xo = 1.2*ones(1,N);

y_over = filter(bq,aq,xo);
y_sat = min(max(y_over,-1),1);

OverflowCount = sum(abs(y_over)>1);
MaxOverflow = max(abs(y_over));

% DISPLAY RESULTS
fprintf('\nQUANTIZATION RESULTS\n');
fprintf('Coefficient error = %.6e\n',MaxCoeffError);
fprintf('Coefficient SQNR = %.2f dB\n',SQNR_coeff);
fprintf('Product error = %.6e\n',MaxProdError);
fprintf('Product SQNR = %.2f dB\n',SQNR_prod);
fprintf('Zero input amplitude = %.6e\n',LimitAmplitude);
fprintf('Limit cycle samples = %d\n',length(LimitSamples));
fprintf('Overflow samples = %d\n',OverflowCount);
fprintf('Maximum overflow = %.6e\n',MaxOverflow);

% DISPLAY COEFFICIENTS
disp('Original numerator coefficients:');
disp(b);

disp('Quantized numerator coefficients:');
disp(bq);

disp('Original denominator coefficients:');
disp(a);

disp('Quantized denominator coefficients:');
disp(aq);

% PLOT 1: IDEAL AND QUANTIZED RESPONSE
figure;
stem(0:N-1,y_ideal,'filled');
hold on;
stem(0:N-1,y_coeff);
grid on;
xlabel('Samples');
ylabel('Amplitude');
title('Ideal vs Quantized Response');
legend('Ideal','Quantized');

% PLOT 2: COEFFICIENT QUANTIZATION ERROR
figure;
plot(0:N-1,e_coeff);
grid on;
xlabel('Samples');
ylabel('Error');
title('Coefficient Quantization Noise');

% PLOT 3: PRODUCT QUANTIZATION ERROR
figure;
stem(0:N-1,e_prod,'filled');
grid on;
xlabel('Samples');
ylabel('Error');
title('Product Quantization Noise');

% PLOT 4: ZERO INPUT TEST
figure;
plot(0:N-1,y_zero);
grid on;
xlabel('Samples');
ylabel('Amplitude');
title('Zero Input Limit Cycle Test');

% PLOT 5: OVERFLOW TEST
figure;
plot(0:N-1,y_over);
hold on;
plot(0:N-1,y_sat,'--');
grid on;
xlabel('Samples');
ylabel('Amplitude');
title('Overflow and Saturation Test');
legend('Without Saturation','With Saturation');

% PLOT 6: IDEAL POLE ZERO PLOT
figure;
zplane(b,a);
grid on;
title('Ideal Filter Pole Zero Plot');

% PLOT 7: QUANTIZED POLE ZERO PLOT
figure;
zplane(bq,aq);
grid on;
title('Quantized Filter Pole Zero Plot');