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
run = 18; % number of frames need to be transmitted
T = 4000; % number of total available time slots
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
    
    if GetJointEntropy(availableCam,H) > maxRecvEmtropy
        maxRecvEmtropy = GetJointEntropy(availableCam,H);
        bestSchedule = scheduleValue;
        supportCamSet = availableCam;
    end
end
maxRecvEmtropy
bestSchedule
supportCamSet

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
greedyRecvEntropy = GetJointEntropy(greedyAvailableCam,H);
greedySchedule = greedyScheduleValue;
greedySupportCamSet = greedyAvailableCam;


%----------------------------------------------------------%
% Greedy scheduling with cluster (maximum reduction first) %
%----------------------------------------------------------%
tempCamSetClus1 = [1:N:2]
tempCamSetClus2 = [2:N:2]
%---------------%
% Start ploting %
%---------------%
plotTrellis = [];
plotGreedy = [];
for i=1:(length(bestSchedule)-1)
    plotTrellis = [plotTrellis bestSchedule{i}.slotsNeeded];
end
for i=1:(length(greedySchedule)-1)
    plotGreedy = [plotGreedy greedySchedule{i}.slotsNeeded];
end

% make them have equal size
if length(plotGreedy) > length(plotTrellis)
    plotTrellis((length(plotTrellis)+1):length(plotGreedy)) = 0;
else
    plotGreedy((length(plotGreedy)+1):length(plotTrellis)) = 0;
end
% Create a stacked bar chart using the bar function
figure(1);
%bar(1:length(plotGreedy), [plotTrellis' plotGreedy'], 0.5, 'stack');
bar(1:length(plotGreedy), [plotTrellis' plotGreedy'], 0.5);

% Adjust the axis limits
axis([0 length(plotTrellis)+1 0 500]);
set(gca, 'XTick', 1:length(plotTrellis));

% Add title and axis labels
title('Required time slots');
xlabel('frame');
ylabel('number of time slots');

% Add a legend
legend('ref', 'greedy');
