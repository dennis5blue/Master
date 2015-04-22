clc;
clear;
addpath('./Utility');
inputPath = '../SourceData/test2_png/';

% Read files
bits = 8.*dlmread([inputPath 'test_phase_0.txt']);
pos = dlmread([inputPath 'test_pos.txt']);
pos = 100.*pos(:,1:3);
dir = dlmread([inputPath 'test_pos.txt']);
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

V = [];
D = [];
P = [];
for i = 1:N
    I = imread([inputPath 'camera_' num2str(i) '.png']);
    mean     = sum(I(:))/length(I(:));
    variance = sum((I(:) - mean).^2)/(length(I(:)) - 1);
    distortion = variance*(2^(-2*rate(i)));
    PSNR = 10*log10(double(( ( 255 )^2 )/distortion));
    V = [V variance];
    D = [D distortion];
    P = [P PSNR];
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
    
    PSNR = 0;
    for i = 1:N
        if ismember(i,vecSupNum)
            PSNR = PSNR + P(i);
        else
            PSNR = PSNR + 10*log10(double(( ( 255 )^2 )/V(i)));
        end
    end
    vecPSNR = [vecPSNR PSNR/N];
end
vecPSNR