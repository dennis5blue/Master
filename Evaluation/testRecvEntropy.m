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
run = 5; % number of frames need to be transmitted
T = 2000; % number of total available time slots
t = 0.5; % time slot duration (ms)
W = 10000/N; % bandwidth (kHz)
Ns = 2; % remaining branches while pruning

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
            availableCam
        end
    end
end
