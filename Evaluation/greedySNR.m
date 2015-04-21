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

rate = bits./(res.X*res.Y); % in bpp

for i = 1:N
    I = imread(['../SourceData/test2_png/camera_' num2str(i) '.png']);
    mean     = sum(I(:))/length(I(:));
    variance = sum((I(:) - mean).^2)/(length(I(:)) - 1);
    distortion = variance*(2^(-2*rate(i)));
    PSNR = 10*log10(double(( ( 255 )^2 )/distortion));
end

SNR = [];
for i = 1:N
    SNR = [SNR txPower*CalChannelGain(pos(i,1),pos(i,2),bsX,bsY)/n0];
end
[val idx] = sort(SNR,'descend');

vecPSNR = [];
vecSupNum = [];
Schedule = idx;
for nSlots = 200:200:1500
    % Find best schedule
    supCams = [];
    totalReqSlots = 0;
    for c = 1:length(Schedule)
        cam = Schedule(c);
        snr = txPower*CalChannelGain(pos(cam,1),pos(cam,2),bsX,bsY)/n0;
        reqSlots = ceil(bits(cam)/(tau*W*log2(1+snr)));
        totalReqSlots = totalReqSlots + reqSlots;
        if totalReqSlots > nSlots
            break;
        end
        supCams = [supCams cam];
    end
    vecSupNum = [vecSupNum length(supCams)];
    unSupCams = [1:N];
    unSupCams(ismember(unSupCams,supCams))=[];
    %disp(['supCams: ' mat2str(supCams)]);
    %disp(['unSupCams: ' mat2str(unSupCams)]);
    PSNR = CalPsnr(supCams,unSupCams,N,rate,res,reg);
    vecPSNR = [vecPSNR PSNR];
end

vecPSNR
vecSupNum
% vecPSNR = [28.9432 29.4944 29.9860 30.4781 30.8502 31.1287 31.4953] % for greedy SNR 200:200:1500