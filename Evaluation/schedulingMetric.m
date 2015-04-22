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
nPath = 1; % number of survivor paths

rate = bits./(res.X*res.Y); % in bpp

vecC = [];
vecTxTime = [];
for i = 1:N
    snr = txPower*CalChannelGain(pos(i,1),pos(i,2),bsX,bsY)/n0;
    capacity = tau*W*log2(1+snr);
    reqSlots = ceil(bits(i)/capacity);
    vecC = [vecC capacity];
    vecTxTime = [vecTxTime reqSlots];
end

% Trellis algorithm using scheduling metric
Schedule = [1:10]';
for run = 1:N-1
    % Append the scheduling matrix for nPath times
    m_numSchedules = nPath*length(Schedule(:,1));
    tempSchedule = -1*ones(m_numSchedules,run);
    for i = 1:length(Schedule(:,1))
        for j = 1:nPath
            tempSchedule((i-1)*nPath+j,:) = Schedule(i,:);
        end
    end
    Schedule = tempSchedule;
    
    nextSchedule = -1*ones(1,m_numSchedules)';
    % Find nPath cameras with the better profit
    for i = 1:nPath:m_numSchedules
        schedCams = Schedule(i,:);
        unschedCams = [1:N];
        unschedCams(ismember(unschedCams,schedCams))=[];
        m_vecProfit = [];
        m_vecCandidates = [];
        for c = 1:length(unschedCams)
            cam = unschedCams(c);
            m_vecCandidates = [m_vecCandidates cam];
            m_vecMetric = [];
            for m = 1:length(unschedCams)
                cam2 = unschedCams(m);
                d1 = CalDistortion(inputPath,[cam schedCams],unschedCams,N,rate,res,reg);
                d2 = CalDistortion(inputPath,[cam2 schedCams],unschedCams,N,rate,res,reg);
                m1 = d1*sum(vecTxTime([cam schedCams]));
                m2 = d2*sum(vecTxTime([cam2 schedCams]));
                m_vecMetric = [m_vecMetric m1-m2];
            end
            m_vecProfit = [m_vecProfit max(m_vecMetric)];
        end
        [m_profit, m_idx] = sort(m_vecProfit,'ascend');
        if length(m_idx) < nPath
            nextSchedule(i:i+nPath-1) = m_vecCandidates(m_idx(1));
        else
            for j = 0:nPath-1
                nextCam = m_vecCandidates( m_idx(j+1) );
                nextSchedule(i+j) = nextCam;
            end
        end
    end
    Schedule = [Schedule nextSchedule]
end

% Calculate performance
vecPSNR = [];
vecSupNum = [];
for nSlots = 200:200:1500
    % Find best schedule
    bestSche = 0;
    bestPsnr = 0;
    bestSupCams = [];
    for i = 1:length(Schedule)
        supCams = [];
        totalReqSlots = 0;
        for c = 1:length(Schedule(i,:))
            cam = Schedule(i,c);
            snr = txPower*CalChannelGain(pos(cam,1),pos(cam,2),bsX,bsY)/n0;
            reqSlots = ceil(bits(cam)/(tau*W*log2(1+snr)));
            totalReqSlots = totalReqSlots + reqSlots;
            if totalReqSlots > nSlots
                break;
            end
            supCams = [supCams cam];
        end
        unSupCams = [1:N];
        unSupCams(ismember(unSupCams,supCams))=[];
        temp = CalPsnr(inputPath,supCams,unSupCams,N,rate,res,reg);
        if temp > bestPsnr
            bestPsnr = temp;
            bestSche = i;
            bestSupCams = supCams;
        end
    end
    vecSupNum = [vecSupNum length(bestSupCams)];
    vecPSNR = [vecPSNR bestPsnr];
end

vecPSNR
vecSupNum

% vecPSNR = [28.9598 29.4865 30.0372 30.4781 30.7630 31.1287 31.4953] %200:200:1500 nPath = 1
% vecSupNum = [1 3 4 5 6 7 8]