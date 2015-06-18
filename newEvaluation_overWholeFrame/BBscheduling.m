clc;
clear;
addpath('./Utility');
inputPath = '../SourceData/test9/';
searchRange = 512;

% Read files
bits = 8.*dlmread([inputPath 'outFiles/indepByte.txt']); % bits
pos = dlmread([inputPath 'pos.txt']);
dir = dlmread([inputPath 'dir.txt']);
matCost = 8.*dlmread([inputPath 'outFiles/rng' num2str(searchRange) '/corrMatrix.txt']);

% Parameters settings
bsX = 0; bsY = 0; % position of base station
tau = 1; % ms
txPower = 0.1; % transmission power (watt)
n0 = 1e-16; % cannot change this value (hard code in CalChannelGain)
N = 15; % number of total cameras
W = 180; % kHz
rho = 1;
firstCam = 1;
for i = 1:N
    matCost(i,i) = bits(i);
end
matCost = matCost(1:N,1:N)

vecC = [];
for i = 1:N
    snr = txPower*CalChannelGain(pos(i,1),pos(i,2),bsX,bsY)/n0;
    capacity = tau*W*log2(1+snr);
    vecC = [vecC capacity];
end

% First branch
vecX = -1*ones(1,N); % indicate if a camera is encoded as an I-frame
BBqueue = [];
vecX(firstCam) = 1;
newNode = struct('depth',1,'lb',CalBBLowerBound(vecX,matCost),'selection',vecX);
BBqueue = [newNode BBqueue];
vecX(firstCam) = 0;
newNode = struct('depth',1,'lb',CalBBLowerBound(vecX,matCost),'selection',vecX);
BBqueue = [newNode BBqueue];

% Strat BB algorithm
recordUb = [];
recordLb = [];
ub = inf;
while length(BBqueue) > 0
    % sort BBqueue to get lowest lb and depthest node
    BBqueue = sortStruct(BBqueue,'lb',-1); % -1 means sort descending
    BBqueue = sortStruct(BBqueue,'depth',1); % 1 means sort ascending
    
    % pop the last element
    BBnode = BBqueue(length(BBqueue));
    BBqueue(length(BBqueue)) = [];
    
    if BBnode.depth == N
        m_cost = CalExactCost(BBnode.selection,matCost);
        if m_cost < ub
            ub = m_cost
            bestSelection = BBnode.selection
        end
    elseif BBnode.depth < N
        nextCam = RandomSelectNextBranch( BBnode.selection );
        
        % branch 1
        m_selec = BBnode.selection;
        m_selec(nextCam) = 1;
        m_lb = CalBBLowerBound(m_selec,matCost);
        if m_lb < ub
            newNode = struct('depth',BBnode.depth+1,'lb',m_lb,'selection',m_selec);
            BBqueue = [newNode BBqueue];
        end
        
        % branch 0
        m_selec(nextCam) = 0;
        m_lb = CalBBLowerBound(m_selec,matCost);
        if m_lb <= ub
            newNode = struct('depth',BBnode.depth+1,'lb',m_lb,'selection',m_selec);
            BBqueue = [newNode BBqueue];
        end
    end
    %[BBnode.lb ub]
    recordUb = [recordUb ub];
    recordLb = [recordLb BBnode.lb];
end

bestSelection
finalTxBits = CalExactCost(bestSelection,matCost)

% Start plotting figures
figure(1);
plotLb = recordLb./(1024*8);
plotUb = recordUb./(1024*8);
iter = [1:length(plotUb)];
plot(iter,plotLb,'-','LineWidth',1,'DisplayName', ...
    'lower bound','Color','b','MarkerSize',10); hold on;
plot(iter,plotUb,'-','LineWidth',3,'DisplayName', ...
    'upper bound','Color','r','MarkerSize',10);
leg = legend('show','location','NorthEast');
set(leg,'FontSize',12);
axis([-inf inf -inf inf]);
ylabel('Transmission bytes (kB)','FontSize',11);
xlabel('Iteration','FontSize',11);
grid on;

figure(2);
sg = [0 32 64 128 256 512];
indep = [CalExactCost(ones(1,N),matCost)/(8*1024) 0 0 0 0 0];
for i = 2:length(sg)
    m_matCost = 8.*dlmread([inputPath 'outFiles/rng' num2str(sg(i)) '/corrMatrix.txt']);
    m_matCost = m_matCost(1:N,1:N);
    m_cost = CalExactCost(bestSelection,m_matCost)/(8*1024);
    eval(['sg' num2str(sg(i)) ' = [0 0 0 0 0 0];']);
    eval(['sg' num2str(sg(i)) '(' num2str(i) ') = m_cost;']);
end
bar([1:length(sg)], indep, 'FaceColor', [1 0 0], 'DisplayName','Independent transmission'); hold on;
bar([1:length(sg)], sg32, 'FaceColor', [0 0.5 0.2], 'DisplayName','Search range = 32'); hold on;
bar([1:length(sg)], sg64, 'FaceColor', [0 0.5 0.4], 'DisplayName','Search range = 64'); hold on;
bar([1:length(sg)], sg128, 'FaceColor', [0 0.5 0.6], 'DisplayName','Search range = 128'); hold on;
bar([1:length(sg)], sg256, 'FaceColor', [0 0.5 0.8], 'DisplayName','Search range = 256'); hold on;
bar([1:length(sg)], sg512, 'FaceColor', [0 0.5 1], 'DisplayName','Search range = 512');

leg = legend('show','location','NorthEast');
set(leg,'FontSize',11);
axis([-inf inf -inf inf]);
set(gca,'XTick',[]);
%set(gca,'YTick',[]);
%set(gca,'YColor','w');
set(gca,'XColor','w');
set(gca,'XTickLabel',['']);
%set(gca,'YTickLabel',['']);
ylabel('Transmission bytes (kB)');
xlabel('');
grid on;