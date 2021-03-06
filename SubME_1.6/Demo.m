clear all
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Demo for Subpixel Motion Estimation
% version 1.6
%
% Stanley Chan
% 
% Copyright 2010
% University of California, San Diego
%
% Last modified: 
% 29 Apr, 2010
% 29 Jun, 2010
%  7 Jul, 2010
%  3 Jan, 2013 clean up demo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Parameters
opts.BlockSize   = 4;
opts.SearchLimit = 10; % default = 10
opts.RegionNum = 36;
opts.WhichRegion0 = [4 4];
opts.WhichRegion1 = [4 2];

% Read image
img0 = im2double(imread('imgs/camera_8.png'));
img1 = im2double(imread('imgs/camera_9.png'));
xSize = length(img0(:,1,1))/sqrt(opts.RegionNum);
ySize = length(img0(1,:,1))/sqrt(opts.RegionNum);
img0 = img0((opts.WhichRegion0(1)-1)*xSize+1:opts.WhichRegion0(1)*xSize, ...
    (opts.WhichRegion0(2)-1)*ySize+1:opts.WhichRegion0(2)*ySize,:);
img1 = img1((opts.WhichRegion1(1)-1)*xSize+1:opts.WhichRegion1(1)*xSize, ...
    (opts.WhichRegion1(2)-1)*ySize+1:opts.WhichRegion1(2)*ySize,:);

%img0 = im2double(imread('imgs/foreman001.png'));
%img1 = im2double(imread('imgs/foreman002.png'));

% Motion estimation
tic
[MVx, MVy] = Bidirectional_ME(img0, img1, opts);
toc

% Motion Compensation
tic
imgMC = reconstruct(img0, MVx, MVy, 0.5);
toc

% Evaluation
[M N C] = size(imgMC);
Res  = imgMC-img1(1:M, 1:N, 1:C);
MSE  = norm(Res(:), 'fro')^2/numel(imgMC);
PSNR = 10*log10(max(imgMC(:))^2/MSE);

% Show results
figure(1);
quiver(MVx(end:-1:1,:), MVy(end:-1:1,:));
title('Motion Vector Field');

figure(2);
subplot(221);
imshow(img0); title('img_0');

subplot(222);
imshow(img1); title('img_1');

subplot(223);
imshow(imgMC); title('img_M');

subplot(224); 
T = sprintf('img_M - img_1, PSNR %3g dB', PSNR);
imshow(rgb2gray(imgMC)-rgb2gray(img1(1:M, 1:N, :)), []); title(T);
