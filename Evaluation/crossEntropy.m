% Use cross entropy for node selection
clc;
clear;
tic;
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
nTrails = 150;
alpha = 0.7; % weight for better solution
nSuper = 15;

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

% Start cross entropy algorithm
vecPSNR = [];
vecSupNum = [];
for nSlots = 200:200:1500
    % Initial probability
    vecProb = 0.5*ones(1,N);
    while length(find(vecProb>0.9))+length(find(vecProb<0.1)) < N
        m_vecDistortion = [];
        m_matBernoulli = [];
        for i = 1:nTrails
            trail = binornd(1,vecProb);
            m_txTime = sum(vecTxTime(find(trail==1)));
            % Make sure that the total transmission time of selection is feasible
            % Random drop selection if txTime exceed
            while m_txTime > nSlots
                temp = find(trail==1);
                drop = temp(randi(numel(temp)));
                trail(drop) = 0;
                m_txTime = sum(vecTxTime(find(trail==1)));
            end
            selected = find(trail==1);
            unselected = [1:N];
            unselected(ismember(unselected,selected))=[];
            distortion = CalDistortion( inputPath, selected, unselected, N, rate, res, reg );
            m_matBernoulli = [m_matBernoulli; trail];
            m_vecDistortion = [m_vecDistortion distortion];
        end
        [val idx] = sort(m_vecDistortion,'ascend');
        betterSol = m_matBernoulli(idx(1:nSuper),:);
        updateProb = [];
        for i = 1:N
            updateProb = [updateProb sum(betterSol(:,i))];
        end
        updateProb = updateProb./nSuper;
        vecProb = alpha.*updateProb + (1-alpha).*vecProb;
    end
    supCams = find(vecProb>0.9);
    unSupCams = [1:N];
    unSupCams(ismember(unSupCams,supCams))=[];
    psnr = CalPsnr(inputPath,supCams,unSupCams,N,rate,res,reg);
    vecSupNum = [vecSupNum length(supCams)];
    vecPSNR = [vecPSNR psnr];
end

vecPSNR
vecSupNum
toc;
% vecPSNR = [28.9432 29.4865 29.9860 30.3596 30.8984 31.1595 31.7066] %200:200:1500