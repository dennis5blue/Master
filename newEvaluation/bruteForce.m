clc;
clear;
addpath('./Utility');
inputPath = '../SourceData/test4_png/';

% Read files
bits = 8.*dlmread([inputPath 'test_phase_0.txt']);
pos = dlmread([inputPath 'test_pos.txt']);
pos = 100.*pos(:,1:3);
dir = dlmread([inputPath 'test_pos.txt']);
dir = dir(:,6);

% Parameters settings
bsX = 0; bsY = 0; % position of base station
tau = 1; % ms
txPower = 0.1; % transmission power (watt)
n0 = 1e-16; % cannot change this value (hard code in CalChannelGain)
N = 10; % number of total cameras
res.X = 1280; res.Y = 720;
reg.X = 16; reg.Y = 9;
W = 180; % kHz
nSamples = 50; % number of cross entropy samples
nRemainSample = 10;
alpha = 0.7;
firstCam = 10;

vecC = [];
for i = 1:N
    snr = txPower*CalChannelGain(pos(i,1),pos(i,2),bsX,bsY)/n0;
    capacity = tau*W*log2(1+snr);
    vecC = [vecC capacity];
end

rate = bits./(res.X*res.Y); % in bpp
tmp = ceil(bits./(reg.X*reg.Y));
% rate and size for each regions (an approximated approach)
for i = 1:N
    eval(['matsRate.cam' num2str(i) '=rate(' num2str(i) ')*ones(reg.Y,reg.X);']);
    eval(['matsBits.cam' num2str(i) '=tmp(' num2str(i) ')*ones(reg.Y,reg.X);']);
end

candidate = perms([1 2 3 5 6 7 8 9]);
ub = inf;
bestSchedule = [];
recordUb = [];
for i = 1:length(candidate(:,1))
    [i ub]
    schedule = candidate(i,:);
    txBits = CalTxBits(inputPath, [10 4 schedule], matsBits, reg);
    if txBits < ub
        ub = txBits;
        bestSchedule = schedule;
    end
    recordUb = [recordUb ub];
end