clc;
clear;
addpath('./Utility');
inputPath = '../SourceData/test9/';

% load the output of I-frame selection problem
N = cell2mat(struct2cell(load('IframeStructure.mat', 'N')));
pos = cell2mat(struct2cell(load('IframeStructure.mat', 'pos')));
dir = cell2mat(struct2cell(load('IframeStructure.mat', 'dir')));
vecBits = cell2mat(struct2cell(load('IframeStructure.mat', 'vecBits')));
matCost = cell2mat(struct2cell(load('IframeStructure.mat', 'matCost')));
temp = cell2mat(struct2cell(load('IframeStructure.mat', 'bestSelection')));
iFrames = find(temp==1);
vecBits = vecBits(1:N);

% Parameters settings (must be the same with BBscheduling.m)
bsX = 0; bsY = 0; % position of base station
tau = 1; % ms
txPower = 0.1; % transmission power (watt)
n0 = 1e-16; % cannot change this value (hard code in CalChannelGain)
W = 180; % kHz
rho = 1;

algVersion = 0; % larger metric scheudle first

for i = 1:N
    for j = 1:N
        for k = 1:N
            if j ~= k
                if matCost(i,j) == matCost(i,k)
                    matCost(i,k) = matCost(i,k)+1;
                end
            end
        end
    end
end

vecC = [];
for i = 1:N
    snr = txPower*CalChannelGain(pos(i,1),pos(i,2),bsX,bsY)/n0;
    capacity = tau*W*log2(1+snr);
    vecC = [vecC capacity];
end

% Find the reference camera
whichIFrame = zeros(1,N);
for i = 1:N
    if ~ismember(i,iFrames)
        tempCost = matCost(i,iFrames);
        for j = 1:length(iFrames)
            if IfCanOverhear(pos(i,1),pos(i,2),pos(iFrames(j),1),pos(iFrames(j),2),bsX,bsY,rho) == 0
                tempCost(j) = inf;
            end
        end
        [val idx] = sort(tempCost,'ascend');
        whichIFrame(i) = iFrames(idx(1));
    else
        whichIFrame(i) = i;
    end
end

% Initialize vecGOP (group of pictures to be scheduled)
vecGOP = [];
for i = 1:length(iFrames)
    iCam = iFrames(i);
    corrPFrames = [];
    for j = 1:N
        if j ~= iCam
            if whichIFrame(j) == iCam
                corrPFrames = [corrPFrames j];
            end
        end
    end
    GOP = struct('iFrame',iCam,'pFrames',corrPFrames,'schedule',[],'refStructure',iCam.*ones(1,length(corrPFrames)));
    vecGOP = [vecGOP GOP];
end

% Start schdeulding (group by group)
for gg = 1:length(vecGOP)
    iCam = vecGOP(gg).iFrame;
    pCamSet = vecGOP(gg).pFrames;
    while length(pCamSet) ~= 0
        vecRefCam = vecGOP(gg).refStructure; % note that initial all pFrames reference from iCam
        if length(pCamSet) == 1
            vecGOP(gg).schedule = [vecGOP(gg).schedule pCamSet(1)];
            prevCams = [iCam vecGOP(gg).schedule];
            prevCanHearCams = FindCanHearCamsSet( pCamSet(1), iCam, vecRefCam, vecGOP(gg), prevCams, pos, bsX, bsY, rho );
            temp = min(matCost(pCamSet(1),prevCanHearCams));
            newRef = find( matCost(pCamSet(1),:) == temp );
            vecRefCam(find(vecGOP(gg).pFrames==pCamSet(1))) = newRef;
            vecGOP(gg).refStructure = vecRefCam;
            pCamSet = [];
            
        % Calculate the scheduling metric if there has more than one unscheduled cameras    
        elseif length(pCamSet) > 1
            
            % Different version of scheduling metric
            if algVersion == 0 % 0 is for brute force
                [m_bestSche m_bestRefStruc] = BruteForcePFrameScheduling( vecGOP(gg), matCost, pos, bsX, bsY, rho );
                vecGOP(gg).schedule = m_bestSche;
                vecGOP(gg).refStructure = m_bestRefStruc;
                break;
            elseif algVersion == 1 % consdier schedule now and later
                vecMetric = CalPFrameSchedulingMetric1( pCamSet, vecRefCam, vecGOP(gg), matCost );
            elseif algVersion == 2 % consider the benefit to others
                vecMetric = CalPFrameSchedulingMetric2( pCamSet, vecRefCam, vecGOP(gg), matCost );
            elseif algVersion == 3 % consdier the distance
                vecMetric = CalPFrameSchedulingMetric3( pCamSet, pos, bsX, bsY );
            end

            % Select the camera with largest metric to schedule next
            nextCam = pCamSet( find(vecMetric==max(vecMetric)) );
            if length(nextCam) > 1
                nextCam = nextCam(1);
            end
            vecGOP(gg).schedule = [vecGOP(gg).schedule nextCam];
            pCamSet(find(pCamSet==nextCam)) = [];
            
            % Update refCams
            for jj = 1:length(pCamSet)
                pCam = pCamSet(jj);
                prevCams = [iCam vecGOP(gg).schedule];
                
                % Find the set of cameras that pCam can overhear
                prevCanHearCams = FindCanHearCamsSet( pCam, iCam, vecRefCam, vecGOP(gg), prevCams, pos, bsX, bsY, rho );
                
                % Find the new ref camera for pCam
                temp = min(matCost(pCam,prevCanHearCams));
                newRef = find( matCost(pCam,:) == temp );
                vecRefCam(find(vecGOP(gg).pFrames==pCam)) = newRef;
            end
            vecGOP(gg).refStructure = vecRefCam;
        end
    end
end
saveFileName = ['mat/PframeScheduling_cam' num2str(N) '_alg' num2str(algVersion) '.mat'];
save(saveFileName);