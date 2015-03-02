clc;
clear;

pos = load('../SourceData/test_correlation/day/pos.out');
dayEntropy = load('../SourceData/test_correlation/day/indepByte.out');
dayCorrMatrix = load('../SourceData/test_correlation/day/corrMatrix');
nightEntropy = load('../SourceData/test_correlation/night/indepByte.out');
nightCorrMatrix = load('../SourceData/test_correlation/night/corrMatrix');

H = struct('indep',{},'corr',{});
H(1).indep = dayEntropy;
H(1).corr = dayCorrMatrix;
H(2).indep = nightEntropy;
H(2).corr = nightCorrMatrix;

N = 18; % number of total cameras
T = 10; % number of total available time slots
t = 0.5; % time slot duration (ms)
W = 180; % bandwidth (kHz)
Ns = 2; % remaining branches while pruning

% Initial set all possible branches from k=0 to k=1
branchesSet = {};
for i=1:N
    m = i*ones(1,1);
    branchesSet{i} = m;
end

for k=2:T
    % Day
    for p=1:length(branchesSet)
        candidates = FindUnscheduled(N,branchesSet{p});
        FindMaxEntropyIncrease(Ns,candidates,H(1).corr,branchesSet{p})
    end
end
