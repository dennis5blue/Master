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
firstCam = 8;

rate = bits./(res.X*res.Y); % in bpp

vecC = [];
for i = 1:N
    snr = txPower*CalChannelGain(pos(i,1),pos(i,2),bsX,bsY)/n0;
    capacity = tau*W*log2(1+snr);
    reqSlots = ceil(bits(i)/capacity);
    vecC = [vecC capacity];
end

%Scheduling metric
Schedule = [firstCam];
for run = 1:N-1
    schedCams = Schedule;
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
    nextCam = m_vecCandidates( m_idx(1) );
    Schedule = [Schedule nextCam];
end