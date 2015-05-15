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

% Initial txRegions
for i = 1:N
    eval(['txRegs.cam' num2str(i) '=ones(reg.Y,reg.X);']);
end

globalProb = (1/(N-1))./ones(N,N);
for i = 1:N
    globalProb(i,i) = 0;
end

counter = 0;
while (sum(sum(globalProb<0.1))+sum(sum(globalProb>0.9)) ~= N*N)
    scheSamples = zeros(nSamples,N);
    vecTxBits = [];
    for s = 1:nSamples
        probTransition = globalProb;
        scheSamples(s,1) = firstCam;
        for k = 2:N-1
            prevCam = scheSamples(s,k-1);
            probTransition(:,prevCam) = zeros(N,1);
            for r = 1:N
                probTransition(r,:) = probTransition(r,:)./sum(probTransition(r,:));
            end
            prob = probTransition(prevCam,:);
            nextCam = genSample(prob);
            scheSamples(s,k) = nextCam;
        end
        scheSamples(s,N) = genSample(probTransition(nextCam,:));
        vecTxBits = [vecTxBits CalTxBits(inputPath, scheSamples(s,:), matsBits, reg)];
    end
    %vecTxBits
    [val idx] = sort(vecTxBits,'ascend');
    
    % calculate transition matrix based on best nRemainSample samples
    newProb = (1/nRemainSample).*ones(N,N);
    timeTransition = zeros(N,N);
    for i = 1:nRemainSample
        ss = idx(i);
        samp = scheSamples(ss,:);
        for j = 2:length(samp)
            pp = samp(j-1);
            nn = samp(j);
            timeTransition(pp,nn) = timeTransition(pp,nn)+1;
        end
    end
    newProb = newProb.*timeTransition;
    
    % normalize
    for i = 1:N
        if sum(newProb(i,:)) > 0
            newProb(i,:) = newProb(i,:)./sum(newProb(i,:));
        end
    end
    counter = counter+1
    globalProb = alpha.*globalProb + (1-alpha).*newProb;
end

%globalProb
finalSchedule = [firstCam];
for i = 2:N
    prev = finalSchedule(i-1);
    finalSchedule = [finalSchedule find(globalProb(prev,:)>0.9)];
end

finalSchedule
finalTxBits = CalTxBits(inputPath, finalSchedule, matsBits, reg)

% greedySize = [10 9 8 6 1 7 2 3 4 5] 5620948 bits
% schedule = [1 2 7 6 4 5 3 8 9 10] 5388929 bits
% schedule = [10 4 5 1 3 2 8 9 6 7] 5248250 bits