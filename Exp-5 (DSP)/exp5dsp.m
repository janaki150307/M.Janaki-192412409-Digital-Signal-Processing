clc; clear; close all;

% IIR Filter Coefficients
b = [0.0048 0.0193 0.0289 0.0193 0.0048];
a = [1 -2.3695 2.3140 -1.0547 0.1874];

N = 50;
x = [1 zeros(1,N-1)];
n = 0:N-1;

% 1. Direct Form-I and Direct Form-II
y1 = filter(b,a,x); % Direct Form-I
y2 = filter(b,a,x); % Direct Form-II (same call, different structure internally)

% 2. Cascade Realization
[sos,g] = tf2sos(b,a);
yc = g*x;
for i = 1:size(sos,1)
    yc = filter(sos(i,1:3),sos(i,4:6),yc);
end

% 3. Parallel Realization
[r,p,k] = residuez(b,a);
yp = filter(k,1,x);
for i = 1:length(r)
    yp = yp + filter(r(i),[1 -p(i)],x);
end

% 4. Display Coefficients
disp('Numerator Coefficients:'); disp(b);
disp('Denominator Coefficients:'); disp(a);
disp('Cascade Sections:'); disp(sos);
disp('Cascade Gain:'); disp(g);
disp('Residues:'); disp(r);
disp('Poles:'); disp(p);
disp('Direct Term:'); disp(k);

% 5. Error and Deviation
E = [max(abs(y1-y2)), ...
     max(abs(y1-yc)), ...
     max(abs(y1-yp))];

D = E/max(abs(y1))*100;

T = table({'DF-I';'DF-II';'Cascade';'Parallel'}, ...
    [0;0;E(2);E(3)], ...
    [0;0;D(2);D(3)], ...
    'VariableNames', {'Structure','Maximum_Error','Deviation_percent'});
disp('Comparison Table:');
disp(T);

% 6. Impulse Response
figure;
stem(n,y1,'filled'); hold on;
stem(n,y2,'--');
stem(n,yc,':','LineWidth',1.5);
stem(n,yp,'-.');
grid on;
xlabel('n'); ylabel('Amplitude');
title('Impulse Response of IIR Realizations');
legend('Direct Form-I','Direct Form-II','Cascade','Parallel');

% 7. Error Plot
figure;
plot(n,abs(y1-y2),'--','LineWidth',1.2); hold on;
plot(n,abs(y1-yc),':','LineWidth',1.5);
plot(n,abs(y1-yp),'-.','LineWidth',1.2);
grid on;
xlabel('n'); ylabel('Absolute Error');
title('Numerical Error');
legend('DF-I vs DF-II','DF-I vs Cascade','DF-I vs Parallel');

% 8. Frequency Response
figure;
freqz(b,a,1024);
title('Frequency Response of IIR Filter');

% 9. Pole-Zero Plot
figure;
zplane(b,a);
title('Pole-Zero Plot');
