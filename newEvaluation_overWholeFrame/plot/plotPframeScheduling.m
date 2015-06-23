clc;
clear;
addpath('../Utility');

% load data for proposed p-frame scheduling metric
load('../mat/PframeScheduling_cam20_alg3.mat');
inputPath = ['../' inputPath];
indepBits = 0;
for i = 1:N
    indepBits = indepBits + matCost(i,i);
end
plotImproveRefI = [];
plotImproveRefP= [];
plotSg = [32 64 128 256 512];
for i = 1:length(plotSg)
    sg = plotSg(i);
    m_newMatCost = 8.*dlmread([inputPath 'outFiles/rng' num2str(sg) '/corrMatrix.txt']);
    m_newMatCost = m_newMatCost(1:N,1:N);
    [costRefI, costRefP] = CalCostByRefStructure( m_newMatCost, vecBits, vecGOP );
    plotImproveRefI = [plotImproveRefI 100*(indepBits-costRefI)/indepBits];
    plotImproveRefP = [plotImproveRefP 100*(indepBits-costRefP)/indepBits];
end

% load data for brute force p-frame scheduling
load('../mat/PframeScheduling_cam20_alg0.mat');
inputPath = ['../' inputPath];
indepBits = 0;
for i = 1:N
    indepBits = indepBits + matCost(i,i);
end
plotImproveRefPBruteForce = [];
for i = 1:length(plotSg)
    sg = plotSg(i);
    m_newMatCost = 8.*dlmread([inputPath 'outFiles/rng' num2str(sg) '/corrMatrix.txt']);
    m_newMatCost = m_newMatCost(1:N,1:N);
    [costRefI, costRefP] = CalCostByRefStructure( m_newMatCost, vecBits, vecGOP );
    plotImproveRefPBruteForce = [plotImproveRefPBruteForce 100*(indepBits-costRefP)/indepBits];
end

% Start plotting figures
figure(1);
ploty = [];
for i = 3:length(plotSg)
    sg = plotSg(i);
    ploty=[ploty;plotImproveRefI(i) plotImproveRefP(i) plotImproveRefPBruteForce(i)];
end
bar(ploty,'group');
legend('Reference only from I-frame', ...
    'Reference from I-frame or P-frame (scheduling metric)', ...
    'Reference from I-frame or P-frame (brute force)');
%set (gca, 'XTick',[5:1:9]);
%xt = get(gca, 'XTick');
set (gca, 'XTickLabel', [128 256 512]);
leg = legend('show','location','SouthWest');
set(leg,'FontSize',11);
axis([-inf inf 29 31]);
ylabel('Improve ratio (%)','FontSize',11);
xlabel('Search range','FontSize',11);
grid on;