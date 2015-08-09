clc;
clear;
addpath('./Utility');

vecImprovBB_realBits = [];
vecImprovBB_geoTech = [];
vecImprovSA_realBits = [];
vecImprovSA_geoTech = [];
vecImprovMDS_realBits = [];
vecImprovMDS_geoTech = [];
vecIterMDS_realBits = [];
vecIterMDS_geoTech = [];

vecBitsBB = [];
vecBitsMDS = [];

vecDegree = [10:5:40];
numOfInter = 1; % since we have four intersections for test version 13
searchRng = 512;
testVersion = 13;
rho = 1;
SAiterLimit = 300;
ifSaveFile = 0;
N = 8;
inputPath = ['../SourceData/test' num2str(testVersion) '/'];
vecEpsilon = [];
for deg = vecDegree
    vecBits = 8.*dlmread([inputPath 'outFiles/' num2str(deg) '/indepByte.txt']); % bits
    matCost = 8.*dlmread([inputPath 'outFiles/' num2str(deg) '/corrMatrix.txt']);
    vecTemp = [];
    for i = 1:N
        matCost(i,i) = vecBits(i);
        vecTemp = [vecTemp vecBits(i)/min(matCost(i,:))];
    end
    vecEpsilon = [vecEpsilon max(vecTemp)];
    
    ratio = BBselection_betterPrune_Inter(num2str(ifSaveFile),num2str(N),num2str(testVersion),num2str(rho),num2str(deg));
    vecImprovBB_realBits = [vecImprovBB_realBits 100*ratio];
    vecBitsBB = [vecBitsBB sum(vecBits(1:N))*(1-ratio)];
    %ratio = 100*BBselection_betterPrune_geoTech_Inter(num2str(ifSaveFile),num2str(N),num2str(testVersion),num2str(rho),num2str(deg));
    %vecImprovBB_geoTech = [vecImprovBB_geoTech ratio];
    
    [ratio countIter] = MDS_proposed_Inter(num2str(ifSaveFile),num2str(N),num2str(testVersion),num2str(rho),num2str(deg));
    vecImprovMDS_realBits = [vecImprovMDS_realBits 100*ratio];
    vecIterMDS_realBits = [vecIterMDS_realBits countIter];
    vecBitsMDS = [vecBitsMDS sum(vecBits(1:N))*(1-ratio)];
    %[ratio countIter] = MDS_proposed_geoTech_Inter(num2str(ifSaveFile),num2str(N),num2str(testVersion),num2str(rho),num2str(deg));
    %vecImprovMDS_geoTech = [vecImprovMDS_geoTech 100*ratio];
    %vecIterMDS_geoTech = [vecIterMDS_geoTech countIter];
    
    [ratio_real ratio_geoTech] = SAselection_Inter (num2str(ifSaveFile),num2str(N),num2str(testVersion),num2str(rho),num2str(deg),num2str(SAiterLimit));
    vecImprovSA_realBits = [vecImprovSA_realBits 100*ratio_real];
    %vecImprovSA_geoTech = [vecImprovSA_geoTech 100*ratio_geoTech];
end

AoV = 50;
plotCorr = [];
for deg = vecDegree
    plotCorr = [plotCorr 100*(AoV-deg)/AoV];
end
% Start plotting figures
figure(1);
plot(fliplr(plotCorr),fliplr(vecImprovBB_realBits),'^-','LineWidth',2,'DisplayName', ...
    'BB algorithm','Color','r','MarkerSize',10); hold on;
plot(fliplr(plotCorr),fliplr(vecImprovSA_realBits),'s-','LineWidth',2,'DisplayName', ...
    'SA algorithm','Color','g','MarkerSize',10); hold on;
plot(fliplr(plotCorr),fliplr(vecImprovMDS_realBits),'x-','LineWidth',2,'DisplayName', ...
    'Graph approximation','Color','b','MarkerSize',10); hold on;
leg = legend('show','location','NorthWest');
set(leg,'FontSize',12);
axis([-inf inf 3 38.5]);
ylabel('Improvement ratio (%)','FontSize',11);
xlabel('FoV overlapped proportion (%)','FontSize',11);
grid on;

figure(2);
plotApproxRatio_real = vecBitsMDS./vecBitsBB;
plotApproxRatio_estimate = [];
for i = 1:length(vecDegree)
    ep = vecEpsilon(i);
    itNum = vecIterMDS_realBits(i);
    appRatio = ep - (ep*(N-itNum)-N-itNum)/N;
    plotApproxRatio_estimate = [plotApproxRatio_estimate appRatio];
end
plot(fliplr(plotCorr),fliplr(plotApproxRatio_estimate),'o-','LineWidth',2,'DisplayName', ...
    'Estimated approximation ratio','Color','b','MarkerSize',10); hold on;
plot(fliplr(plotCorr),fliplr(plotApproxRatio_real),'^-','LineWidth',2,'DisplayName', ...
    'Evaluated approximation ratio','Color','r','MarkerSize',10); hold on;
leg = legend('show','location','NorthWest');
set(leg,'FontSize',12);
axis([-inf inf 1 2.5]);
ylabel('Approximation ratio','FontSize',11);
xlabel('FoV overlapped proportion (%)','FontSize',11);
grid on;