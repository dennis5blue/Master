clc;
clear;
addpath('./Utility');
inputPath = '../SourceData/test9/';
searchRange = 512;

% Read files
bits = 8.*dlmread([inputPath 'outFiles/indepByte.txt']); % bits
pos = dlmread([inputPath 'pos.txt']);
dir = dlmread([inputPath 'dir.txt']);
matCost = 8.*dlmread([inputPath 'outFiles/rng' num2str(searchRange) '/corrMatrix.txt']);

% Parameters settings
bsX = 0; bsY = 0; % position of base station
tau = 1; % ms
txPower = 0.1; % transmission power (watt)
n0 = 1e-16; % cannot change this value (hard code in CalChannelGain)
N = 30; % number of total cameras
W = 180; % kHz

vecC = [];
for i = 1:N
    snr = txPower*CalChannelGain(pos(i,1),pos(i,2),bsX,bsY)/n0;
    capacity = tau*W*log2(1+snr);
    vecC = [vecC capacity];
end
