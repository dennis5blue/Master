clc;
clear;
addpath('./Utility');

% Read files
bits = 8.*dlmread('../SourceData/test_phase_0.txt');
pos = dlmread('../SourceData/test_pos.txt');
pos = 100.*pos(:,1:3);
dir = dlmread('../SourceData/test_pos.txt');
dir = dir(:,6);

% Parameters settings
nSlots = 1000; % number of time slots
tau = 1; % time slot duration (ms)
bsX = 0; bsY = 0; % position of base station
txPower = 0.1; % transmission power (watt)
n0 = 1e-16; % cannot change this value (hard code in CalChannelGain)
N = 10; % number of total cameras
res.X = 1280; res.Y = 720;
reg.X = 16; reg.Y = 9;
W = 180; % kHz
nPath = 2; % number of survivor paths

rate = bits./(res.X*res.Y); % in bpp

% Formula for calculating PSNR
%{
for i = 1:N
    I = imread(['../SourceData/test2_png/camera_' num2str(i) '.png']);
    mean     = sum(I(:))/length(I(:));
    variance = sum((I(:) - mean).^2)/(length(I(:)) - 1);
    distortion = variance*(2^(-2*rate(i)));
    PSNR = 10*log10(double(( ( 255 )^2 )/distortion));
end
%}

vecC = [];
vecTxTime = [];
for i = 1:N
    snr = txPower*CalChannelGain(pos(i,1),pos(i,2),bsX,bsY)/n0;
    capacity = tau*W*log2(1+snr);
    reqSlots = ceil(bits(i)/capacity);
    vecC = [vecC capacity];
    vecTxTime = [vecTxTime reqSlots];
end

vecPSNR
vecSupNum
