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
    eval(['initTxRegs.cam' num2str(i) '=ones(reg.Y,reg.X);']);
end

% Initialize cost matrix
matCost = zeros(N,N);
for i = 1:N
    for j = 1:N
        if i == j
            matCost(i,j) = inf;
        else
            eval(['tempBits = matsBits.cam' num2str(j) ';']);
            tempTxRegs = IfTxRequired(inputPath, j, i, ones(reg.Y,reg.X), reg);
            matCost(i,j) = sum(sum(tempBits.*tempTxRegs));
        end
    end
end

% Reduce cost matrix
%{
matCostOrigin = matCost;
reducedCost = 0;
for i = 1:N
    reducedCost = reducedCost + min(matCost(i,:));
    matCost(i,:) = matCost(i,:) - min(matCost(i,:))*ones(1,N);
end
for i = 1:N
    reducedCost = reducedCost + min(matCost(:,i));
    matCost(:,i) = matCost(:,i) - min(matCost(:,i))*ones(N,1);
end
%}

BBqueue = [];
for nextCam = 1:N
    if nextCam ~= firstCam
        route = [firstCam nextCam];
        newNode = struct('depth',2,'cost',matCost(firstCam,nextCam), ...
            'lb',CalBBLowerBound2(route,matCost),'route',route,'txRegions',initTxRegs,'costMatrix', matCost);
        BBqueue = [newNode BBqueue];
    end
end

%{
ub = 0;
for i = 2:N
    ub = ub + matCost(i-1,i);
end
%}

ub = inf;
while length(BBqueue) > 0
    % sort BBqueue to get lowest lb and depthest node
    BBqueue = sortStruct(BBqueue,'lb',-1); % -1 means sort descending
    BBqueue = sortStruct(BBqueue,'depth',1); % 1 means sort ascending
    
    % pop the last element
    BBnode = BBqueue(length(BBqueue))
    BBqueue(length(BBqueue)) = [];
    %BBnode
    if BBnode.depth == N
        if BBnode.cost < ub
            ub = BBnode.cost;
            bestSchedule = BBnode.route;
        end
    elseif BBnode.depth < N
        for nextCam = 1:N
            if ismember(nextCam, BBnode.route) == 0
                m_prevCam = BBnode.route(length(BBnode.route));
                m_route = [BBnode.route nextCam];
                % Check the required txRegions based on previous transmissions
                m_thisCamTxRegions = ones(reg.Y,reg.X);
                for ov = 1:length(m_route)-1
                    ovCam = m_route(ov);
                    eval(['tempRefCamTxRegs = BBnode.txRegions.cam' num2str(ovCam) ';']);                        
                    tempTxRegs = IfTxRequired(inputPath,nextCam,ovCam,tempRefCamTxRegs,reg);
                    m_thisCamTxRegions = min(m_thisCamTxRegions,tempTxRegs);
                end
                eval(['m_tempBits = matsBits.cam' num2str(nextCam) ';']);
                m_cost = BBnode.cost+sum(sum(m_tempBits.*m_thisCamTxRegions));;
                m_lb = CalBBLowerBound2(m_route,matCost)
                % keep branching if lb <= ub
                if m_cost <= ub && m_lb <= ub
                    % Create new BB node
                    newTxRegs = BBnode.txRegions;
                    eval(['newTxRegs.cam' num2str(nextCam) ' = m_thisCamTxRegions;']);
                    newNode = struct('depth',BBnode.depth+1,'cost',m_cost, ...
                        'lb',m_lb,'route',m_route,'txRegions',newTxRegs,'costMatrix', matCost);
                    BBqueue = [newNode BBqueue];
                end
            end
        end
    end
end

bestSchedule
finalTxBits = CalTxBits(inputPath, bestSchedule, matsBits, reg)

% bestScehdule = [3 4 5 6 7 8 9 10 2 1] txBits = 5324474
% bestScehdule = [10 9 8 7 6 5 4 3 2 1] txBits = 5286224
