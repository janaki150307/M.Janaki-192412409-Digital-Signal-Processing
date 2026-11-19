
clc;
clear;
close all;

%% DSP-Based Image Enhancement, Compression and Edge Detection
% Test Image: cameraman.tif
% Spatial Filter: 3x3 Median Filter
% Enhancement: Contrast Stretching
% Compression: JPEG Quality = 50
% Edge Detector: Canny
% Requires Image Processing Toolbox

%% 1. INPUT PARAMETERS

imgName = 'cameraman.tif';

medSize = [3 3];
jpegQuality = 50;
cannyTh = [0.1 0.2];
MAXI = 255;

%% 2. LOAD IMAGE

I = imread(imgName);

if size(I,3) == 3
    I = rgb2gray(I);
end

[rows,cols] = size(I);

fprintf('Image: %s | Size: %d x %d | Class: %s\n', ...
    imgName,rows,cols,class(I));

fprintf('Min = %d, Max = %d, Mean = %.2f, Std = %.2f\n', ...
    min(I(:)),max(I(:)),mean(double(I(:))),std(double(I(:))));

%% 3. SPATIAL FILTERING AND ENHANCEMENT

I_med = medfilt2(I,medSize);

I_enh = imadjust(I_med,stretchlim(I_med),[]);

%% 4. JPEG COMPRESSION AND RECONSTRUCTION

jpgFile = fullfile(tempdir,'cameraman_q50.jpg');

imwrite(I,jpgFile,'jpg','Quality',jpegQuality);

I_rec = imread(jpgFile);

origBytes = rows*cols;

info = dir(jpgFile);
compBytes = info.bytes;

CR = origBytes/compBytes;
bpp = 8*compBytes/(rows*cols);

%% 5. EDGE DETECTION

E_orig = edge(I,'canny',cannyTh);
E_enh = edge(I_enh,'canny',cannyTh);
E_rec = edge(I_rec,'canny',cannyTh);

%% 6. QUALITY METRICS

% Mean Squared Error
MSE = @(A,B) mean((double(A(:))-double(B(:))).^2);

% Peak Signal-to-Noise Ratio
PSNR = @(A,B) 10*log10(MAXI^2/(MSE(A,B)+eps));

MSE_med = MSE(I,I_med);
PSNR_med = PSNR(I,I_med);

MSE_enh = MSE(I,I_enh);
PSNR_enh = PSNR(I,I_enh);

MSE_rec = MSE(I,I_rec);
PSNR_rec = PSNR(I,I_rec);

% Normalized Image Error
NIE_med = MSE_med/MAXI^2;
NIE_enh = MSE_enh/MAXI^2;
NIE_rec = MSE_rec/MAXI^2;

% Structural Similarity Index
SSIM_rec = ssim(I_rec,I);

% Edge Pixel Count
edgePix = [nnz(E_orig),nnz(E_enh),nnz(E_rec)];

%% 7. IMAGE DISPLAY

figure('Name','Enhancement, Compression, Edge Detection', ...
    'Color','w','Position',[40 40 1200 750]);

subplot(2,3,1);
imshow(I);
title('Original Image');

subplot(2,3,2);
imshow(I_med);
title('After 3x3 Median Filter');

subplot(2,3,3);
imshow(I_enh);
title('Enhanced Image');

subplot(2,3,4);
imshow(I_rec);
title(sprintf('JPEG Q=%d (CR = %.2f)',jpegQuality,CR));

subplot(2,3,5);
imshow(E_orig);
title('Canny Edge Map - Original');

subplot(2,3,6);
imshow(E_rec);
title('Canny Edge Map - JPEG');

%% 8. HISTOGRAM COMPARISON

figure('Name','Histograms','Color','w', ...
    'Position',[80 80 900 350]);

subplot(1,2,1);
imhist(I);
title('Histogram - Original');

subplot(1,2,2);
imhist(I_enh);
title('Histogram - Enhanced');

%% 9. COMPRESSION ERROR IMAGE

figure('Name','Compression Error','Color','w', ...
    'Position',[120 120 900 380]);

subplot(1,2,1);
imshow(abs(double(I)-double(I_rec)),[]);
colorbar;
title('|Original - JPEG Reconstructed|');

subplot(1,2,2);
imshow(E_enh);
title('Canny Edge Map - Enhanced Image');

%% 10. RATE-DISTORTION ANALYSIS

qList = 10:10:90;

psnrQ = zeros(size(qList));
crQ = zeros(size(qList));

for n = 1:numel(qList)

    f = fullfile(tempdir,'tmp_q.jpg');

    imwrite(I,f,'jpg','Quality',qList(n));

    R = imread(f);

    d = dir(f);

    psnrQ(n) = PSNR(I,R);

    crQ(n) = origBytes/d.bytes;

end

figure('Name','Rate-Distortion','Color','w', ...
    'Position',[160 160 900 380]);

subplot(1,2,1);
plot(qList,psnrQ,'-o','LineWidth',1.4);
grid on;
xlabel('JPEG Quality');
ylabel('PSNR (dB)');
title('PSNR vs JPEG Quality');

subplot(1,2,2);
plot(qList,crQ,'-s','LineWidth',1.4);
grid on;
xlabel('JPEG Quality');
ylabel('Compression Ratio');
title('Compression Ratio vs JPEG Quality');

%% 11. OUTPUT PARAMETER TABLE

fprintf('\n=============== OUTPUT PARAMETER TABLE ===============\n');

fprintf('%-28s %10s %10s %12s\n', ...
    'Image','MSE','PSNR (dB)','MSE/MAXI^2');

fprintf('%-28s %10.2f %10.2f %12.6f\n', ...
    'Median filtered',MSE_med,PSNR_med,NIE_med);

fprintf('%-28s %10.2f %10.2f %12.6f\n', ...
    'Enhanced (imadjust)',MSE_enh,PSNR_enh,NIE_enh);

fprintf('%-28s %10.2f %10.2f %12.6f\n', ...
    'JPEG Q=50 reconstructed',MSE_rec,PSNR_rec,NIE_rec);

%% 12. COMPRESSION RESULTS

fprintf('\n--- Compression Results (JPEG Q = %d) ---\n',jpegQuality);

fprintf('Original Size : %d bytes\n',origBytes);
fprintf('Compressed Size : %d bytes\n',compBytes);
fprintf('Compression Ratio : %.2f : 1\n',CR);
fprintf('Bits per Pixel : %.3f bpp\n',bpp);
fprintf('SSIM (JPEG vs Original) : %.4f\n',SSIM_rec);

%% 13. EDGE DETECTION RESULTS

fprintf('\n--- Edge Detection (Canny [%.1f %.1f]) ---\n', ...
    cannyTh(1),cannyTh(2));

fprintf('Edge Pixels - Original Image : %d\n',edgePix(1));
fprintf('Edge Pixels - Enhanced Image : %d\n',edgePix(2));
fprintf('Edge Pixels - JPEG Reconstructed : %d\n',edgePix(3));

fprintf('\n====================================================\n');
fprintf('Experiment Completed Successfully.\n');
fprintf('====================================================\n');

%% 14. SAVE FIGURES

figHandles = findall(0,'Type','figure');

for k = 1:length(figHandles)

    figure(figHandles(k));

    filename = sprintf('Exp21_Figure_%d.png',k);

    print(figHandles(k),filename,'-dpng','-r300');

end

fprintf('\nAll figures saved successfully in Current Folder.\n');
