clc;
clear;

pos = load('../SourceData/test_correlation/day/pos.out');
dayEntropy = load('../SourceData/test_correlation/day/indepByte.out');
dayCorrMatrix = load('../SourceData/test_correlation/day/corrMatrix');
nightEntropy = load('../SourceData/test_correlation/night/indepByte.out');
nightCorrMatrix = load('../SourceData/test_correlation/night/corrMatrix');

H = struct('indep',{},'corr',{});
H(1).indep = 8*dayEntropy;
H(1).corr = 8*dayCorrMatrix;
H(2).indep = 8*nightEntropy;
H(2).corr = 8*nightCorrMatrix;

BsX = 0;
BsY = 0;
txPower = 0.1; % transmission power (watt) (power density)
n0 = 1e-16; % cannot change this value (hard code in CalChannelGain)
N = 18; % number of total cameras
run = 3; % number of frames need to be transmitted
T = 600; % number of total available time slots
t = 0.5; % time slot duration (ms)
W = 10000/N; % bandwidth (kHz)
Ns = 2; % remaining branches while pruning

%-----------------------------------------%
%   Correlation-aware packet scheduling   %
%-----------------------------------------%
% Initial set all possible branches from k=0 to k=1
branchesSet = {};
for i=1:N
    m = i*ones(1,1);
    branchesSet{i} = m;
end

for k=2:run
    % Day
    newBranchesSet = {};
    c=1;
    for p=1:length(branchesSet)
        candidates = FindUnscheduled(N,branchesSet{p});
        bestCandidate = FindMaxEntropyIncrease(Ns,candidates,H(1).corr,branchesSet{p});
        for i=1:length(bestCandidate)
            newBranchesSet{c} = [branchesSet{p} bestCandidate(i)];
            c = c+1;
        end
    end
    branchesSet = newBranchesSet;
end

bestSchedule = [];
maxRecvEmtropy = 0;
supportCamSet = [];
for i=1:length(branchesSet)
    targetSchedule = branchesSet{i};
    scheduleValue = struct('cam',{},'transBytes',{},'slotsNeeded',{},'frameMode',{},'cumSlots',{});
    for j=1:length(targetSchedule)
        targetCam = targetSchedule(j);
        if j==1
            scheduleValue{j}.cam = targetCam;
            scheduleValue{j}.transBytes = H(1).indep(targetCam); % H(1) is for day time
            snr = txPower*CalChannelGain(pos(targetCam,1),pos(targetCam,2),BsX,BsY)/n0;
            thisRunSlotsNeeded = ceil(H(1).indep(targetCam)/(t*W*log2(1+snr)));
            scheduleValue{j}.slotsNeeded = thisRunSlotsNeeded;
            scheduleValue{j}.frameMode = 1; % 1 is for I-frame
            scheduleValue{j}.cumSlots = thisRunSlotsNeeded;
        else
            % Check the possiblity for overhearing
            flag = CheckOverhear(targetCam, scheduleValue, pos, n0, txPower, H, t, W);
            snr = txPower*CalChannelGain(pos(targetCam,1),pos(targetCam,2),BsX,BsY)/n0;
            scheduleValue{j}.cam = targetCam;
            if flag == 1
                scheduleValue{j}.transBytes = H(1).corr(targetCam,scheduleValue{j-1}.cam);
                thisRunSlotsNeeded = ceil(H(1).corr(targetCam,scheduleValue{j-1}.cam)/(t*W*log2(1+snr)));
                scheduleValue{j}.slotsNeeded = thisRunSlotsNeeded;
                scheduleValue{j}.frameMode = 0; % 0 is for p-frame
                scheduleValue{j}.cumSlots = scheduleValue{j-1}.cumSlots + thisRunSlotsNeeded;
            else
                scheduleValue{j}.transBytes = H(1).indep(targetCam);
                thisRunSlotsNeeded = ceil(H(1).indep(targetCam)/(t*W*log2(1+snr)));
                scheduleValue{j}.slotsNeeded = thisRunSlotsNeeded;
                scheduleValue{j}.frameMode = 1; % 0 is for p-frame
                scheduleValue{j}.cumSlots = scheduleValue{j-1}.cumSlots + thisRunSlotsNeeded;
            end
            if scheduleValue{j}.cumSlots > T % exceed maximum available time slots
                break;
            end
            availableCam = [];
            for aa=1:length(scheduleValue)
                availableCam = [availableCam scheduleValue{aa}.cam];
            end
        end
    end
    
    if GetSumEntropy(availableCam,H) > maxRecvEmtropy
        maxRecvEmtropy = GetSumEntropy(availableCam,H);
        bestSchedule = scheduleValue;
        supportCamSet = availableCam;
    end
end
%maxRecvEmtropy
%bestSchedule
%supportCamSet

%---------------------------------------------%
% Greedy scheduling (maximum reduction first) %
%---------------------------------------------%
tempCamSet = [1:N];
firstCam = 1;
temp = H(1).indep(firstCam);
for i=2:N
    if H(1).indep(i) < temp
        temp = H(1).indep(i);
        firstCam = i;
    end
end
firstCam = 13;
tempCamSet(find(tempCamSet == firstCam)) = [];
greedyScheduleValue = struct('cam',{},'transBytes',{},'slotsNeeded',{},'frameMode',{},'cumSlots',{});
greedyScheduleValue{1}.cam = firstCam;
greedyScheduleValue{1}.transBytes = H(1).indep(firstCam);
snr = txPower*CalChannelGain(pos(firstCam,1),pos(firstCam,2),BsX,BsY)/n0;
thisRunSlotsNeeded = ceil(H(1).indep(firstCam)/(t*W*log2(1+snr)));            
greedyScheduleValue{1}.slotsNeeded = thisRunSlotsNeeded;
greedyScheduleValue{1}.frameMode = 1; % 1 means I-frame
greedyScheduleValue{1}.cumSlots = thisRunSlotsNeeded;

% Start schedule based on the reduction of required transmission time slots
for i=2:N
    reduc = 0;
    nextCam = tempCamSet(1);
    for j=1:length(tempCamSet)
        targetCam = tempCamSet(j);
        flag = CheckOverhear(targetCam, greedyScheduleValue, pos, n0, txPower, H, t, W);
        if flag == 1
            snr = txPower*CalChannelGain(pos(targetCam,1),pos(targetCam,2),BsX,BsY)/n0;
            tempSlotNeeded = ceil(H(1).corr(targetCam,greedyScheduleValue{i-1}.cam)/(t*W*log2(1+snr)));
            tempReduc = ceil(H(1).indep(targetCam)/(t*W*log2(1+snr))) - tempSlotNeeded;
            if tempReduc > reduc
                reduc = tempReduc;
                nextCam = targetCam;
            end
        end
    end
    tempCamSet(find(tempCamSet==nextCam)) = [];
    greedyScheduleValue{i}.cam = nextCam;
    if reduc > 0
        greedyScheduleValue{i}.transBytes = H(1).corr(nextCam,greedyScheduleValue{i-1}.cam);
        snr = txPower*CalChannelGain(pos(nextCam,1),pos(nextCam,2),BsX,BsY)/n0;
        thisRunSlotsNeeded = ceil(H(1).corr(nextCam,greedyScheduleValue{i-1}.cam)/(t*W*log2(1+snr)));            
        greedyScheduleValue{i}.slotsNeeded = thisRunSlotsNeeded;
        greedyScheduleValue{i}.frameMode = 0; % 0 means p-frame
        greedyScheduleValue{i}.cumSlots = greedyScheduleValue{i-1}.cumSlots + thisRunSlotsNeeded;
    else
        greedyScheduleValue{i}.transBytes = H(1).indep(nextCam);
        snr = txPower*CalChannelGain(pos(nextCam,1),pos(nextCam,2),BsX,BsY)/n0;
        thisRunSlotsNeeded = ceil(H(1).indep(nextCam)/(t*W*log2(1+snr)));            
        greedyScheduleValue{i}.slotsNeeded = thisRunSlotsNeeded;
        greedyScheduleValue{i}.frameMode = 1; % 1 means I-frame
        greedyScheduleValue{i}.cumSlots = greedyScheduleValue{i-1}.cumSlots + thisRunSlotsNeeded;
    end
    if greedyScheduleValue{i}.cumSlots > T % exceed maximum available time slots
        break;
    end
    greedyAvailableCam = [];
    for aa=1:length(greedyScheduleValue)
        greedyAvailableCam = [greedyAvailableCam greedyScheduleValue{aa}.cam];
    end
end
greedyRecvEntropy = GetSumEntropy(greedyAvailableCam,H);
greedySchedule = greedyScheduleValue;
greedySupportCamSet = greedyAvailableCam;


%----------------------------------------------------------%
% Greedy scheduling with cluster (maximum reduction first) %
%----------------------------------------------------------%
% divided into two clusters
tempCamSetClus1 = [1:2:N];
tempCamSetClus2 = [2:2:N];

greedyClusScheduleValue1 = struct('cam',{},'transBytes',{},'slotsNeeded',{},'frameMode',{},'cumSlots',{});
firstCam = tempCamSetClus1(1);
greedyClusScheduleValue1{1}.cam = firstCam;
greedyClusScheduleValue1{1}.transBytes = H(1).indep(firstCam);
snr = txPower*CalChannelGain(pos(firstCam,1),pos(firstCam,2),BsX,BsY)/n0;
thisRunSlotsNeeded = ceil(H(1).indep(firstCam)/(t*W*log2(1+snr))); % assume ideal power control for two clusters
greedyClusScheduleValue1{1}.slotsNeeded = thisRunSlotsNeeded;
greedyClusScheduleValue1{1}.frameMode = 1; % 1 means I-frame
greedyClusScheduleValue1{1}.cumSlots = thisRunSlotsNeeded;

greedyClusScheduleValue2 = struct('cam',{},'transBytes',{},'slotsNeeded',{},'frameMode',{},'cumSlots',{});
firstCam = tempCamSetClus2(1);
greedyClusScheduleValue2{1}.cam = firstCam;
greedyClusScheduleValue2{1}.transBytes = H(1).indep(firstCam);
snr = txPower*CalChannelGain(pos(firstCam,1),pos(firstCam,2),BsX,BsY)/n0;
thisRunSlotsNeeded = ceil(H(1).indep(firstCam)/(t*W*log2(1+snr)));
greedyClusScheduleValue2{1}.slotsNeeded = thisRunSlotsNeeded;
greedyClusScheduleValue2{1}.frameMode = 1; % 1 means I-frame
greedyClusScheduleValue2{1}.cumSlots = thisRunSlotsNeeded;

for i=2:length(tempCamSetClus1) % note that the size of two clusters need to be the same (or we will have error here)
    nextCam1 = tempCamSetClus1(i);
    nextCam2 = tempCamSetClus2(i);
    
    if  CheckOverhear( nextCam1, greedyClusScheduleValue1, pos, n0, txPower, H, t, W/2 ) == 1
        greedyClusScheduleValue1{i}.cam = nextCam1;
        greedyClusScheduleValue1{i}.transBytes = H(1).corr(nextCam1,greedyClusScheduleValue1{i-1}.cam);
        snr = txPower*CalChannelGain(pos(nextCam1,1),pos(nextCam1,2),BsX,BsY)/n0;
        thisRunSlotsNeeded = ceil(H(1).corr(nextCam1,greedyClusScheduleValue1{i-1}.cam)/(t*W*log2(1+snr)));            
        greedyClusScheduleValue1{i}.slotsNeeded = thisRunSlotsNeeded;
        greedyClusScheduleValue1{i}.frameMode = 0; % 0 means p-frame
        greedyClusScheduleValue1{i}.cumSlots = greedyClusScheduleValue1{i-1}.cumSlots + thisRunSlotsNeeded;
    else
        greedyClusScheduleValue1{i}.cam = nextCam1;
        greedyClusScheduleValue1{i}.transBytes = H(1).indep(nextCam1);
        snr = txPower*CalChannelGain(pos(nextCam1,1),pos(nextCam1,2),BsX,BsY)/n0;
        thisRunSlotsNeeded = ceil(H(1).indep(nextCam1)/(t*W*log2(1+snr)));            
        greedyClusScheduleValue1{i}.slotsNeeded = thisRunSlotsNeeded;
        greedyClusScheduleValue1{i}.frameMode = 1; % 1 means I-frame
        greedyClusScheduleValue1{i}.cumSlots = greedyClusScheduleValue1{i-1}.cumSlots + thisRunSlotsNeeded;
    end
    
    if  CheckOverhear( nextCam2, greedyClusScheduleValue2, pos, n0, txPower, H, t, W/2 ) == 1
        greedyClusScheduleValue2{i}.cam = nextCam2;
        greedyClusScheduleValue2{i}.transBytes = H(1).corr(nextCam2,greedyClusScheduleValue2{i-1}.cam);
        snr = txPower*CalChannelGain(pos(nextCam2,1),pos(nextCam2,2),BsX,BsY)/n0;
        thisRunSlotsNeeded = ceil(H(1).corr(nextCam2,greedyClusScheduleValue2{i-1}.cam)/(t*W*log2(1+snr)));            
        greedyClusScheduleValue2{i}.slotsNeeded = thisRunSlotsNeeded;
        greedyClusScheduleValue2{i}.frameMode = 0; % 0 means p-frame
        greedyClusScheduleValue2{i}.cumSlots = greedyClusScheduleValue2{i-1}.cumSlots + thisRunSlotsNeeded;
    else
        greedyClusScheduleValue2{i}.cam = nextCam2;
        greedyClusScheduleValue2{i}.transBytes = H(1).indep(nextCam2);
        snr = txPower*CalChannelGain(pos(nextCam2,1),pos(nextCam2,2),BsX,BsY)/n0;
        thisRunSlotsNeeded = ceil(H(1).indep(nextCam2)/(t*W*log2(1+snr)));            
        greedyClusScheduleValue2{i}.slotsNeeded = thisRunSlotsNeeded;
        greedyClusScheduleValue2{i}.frameMode = 1; % 1 means I-frame
        greedyClusScheduleValue2{i}.cumSlots = greedyClusScheduleValue2{i-1}.cumSlots + thisRunSlotsNeeded;
    end
    
    if greedyClusScheduleValue1{i}.cumSlots > T && greedyClusScheduleValue2{i}.cumSlots > T % exceed maximum available time slots
        break;
    end
    greedyClusAvailableCam = [];
    for aa=1:length(greedyClusScheduleValue1)
        greedyClusAvailableCam = [greedyClusAvailableCam greedyClusScheduleValue1{aa}.cam];
    end
    for bb=1:length(greedyClusScheduleValue2)
        greedyClusAvailableCam = [greedyClusAvailableCam greedyClusScheduleValue2{bb}.cam];
    end
end
greedyClusRecvEntropy = GetSumEntropy(greedyClusAvailableCam,H);
greedyClusSchedule1 = greedyClusScheduleValue1;
greedyClusSchedule2 = greedyClusScheduleValue2;
greedyClusSupportCamSet = greedyClusAvailableCam;

%---------------%
% Start ploting %
%---------------%

maxRecvEmtropy
greedyRecvEntropy 
greedyClusRecvEntropy

% below is for ploting required time slots
%{
plotTrellis = [];
plotGreedy = [];
plotClusGreedy = [];
for i=1:(length(bestSchedule)-1)
    plotTrellis = [plotTrellis bestSchedule{i}.slotsNeeded];
end
for i=1:(length(greedySchedule)-1)
    plotGreedy = [plotGreedy greedySchedule{i}.slotsNeeded];
end
for i=1:(length(greedyClusSchedule1)-1)
    plotClusGreedy = [plotClusGreedy greedyClusSchedule1{i}.slotsNeeded];
end
for i=1:(length(greedyClusSchedule2)-1)
    plotClusGreedy = [plotClusGreedy greedyClusSchedule2{i}.slotsNeeded];
end

% make them have equal size
if length(plotGreedy) > length(plotTrellis) && length(plotGreedy) > length(plotClusGreedy)
    plotTrellis((length(plotTrellis)+1):length(plotGreedy)) = 0;
    plotClusGreedy((length(plotClusGreedy)+1):length(plotGreedy)) = 0;
elseif length(plotTrellis) > length(plotGreedy) && length(plotTrellis) > length(plotClusGreedy)
    plotGreedy((length(plotGreedy)+1):length(plotTrellis)) = 0;
    plotClusGreedy((length(plotClusGreedy)+1):length(plotTrellis)) = 0;
else
    plotTrellis((length(plotTrellis)+1):length(plotClusGreedy)) = 0;
    plotGreedy((length(plotGreedy)+1):length(plotClusGreedy)) = 0;    
end
% Create a stacked bar chart using the bar function
figure(1);
%bar(1:length(plotGreedy), [plotTrellis' plotGreedy'], 0.5, 'stack');
bar(1:length(plotGreedy), [plotTrellis' plotGreedy' plotClusGreedy'], 0.5);

% Adjust the axis limits
axis([0 length(plotTrellis)+1 0 500]);
set(gca, 'XTick', 1:length(plotTrellis));

% Add title and axis labels
title('Required time slots');
xlabel('frame');
ylabel('number of time slots');

% Add a legend
legend('ref', 'greedy without cluster','greedy with cluster');
%}
