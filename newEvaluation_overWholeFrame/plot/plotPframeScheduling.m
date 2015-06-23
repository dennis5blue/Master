clc;
clear;
addpath('../Utility');
load('../PframeScheduling.mat');
inputPath = ['../' inputPath];

% Start plotting figures
figure(1);
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
plot(log2(plotSg),plotImproveRefP,'*-','LineWidth',2,'DisplayName', ...
    'Reference from I-frames or P-frames','Color','r','MarkerSize',10); hold on;
plot(log2(plotSg),plotImproveRefI,'*-','LineWidth',2,'DisplayName', ...
    'Reference only from I-frames','Color','b','MarkerSize',10);
set (gca, 'XTick',[5:1:9]);
xt = get(gca, 'XTick');
set (gca, 'XTickLabel', 2.^xt);
leg = legend('show','location','SouthEast');
set(leg,'FontSize',12);
axis([-inf inf -inf inf]);
ylabel('Improve ratio (%)','FontSize',11);
xlabel('Search range','FontSize',11);
grid on;