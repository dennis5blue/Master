clc;
clear;
addpath('./Utility');

vecImprovBB_realBits = [];
vecImprovBB_geoTech = [];
vecImprovSA_realBits = [];
vecImprovSA_geoTech = [];
vecImprovMDS_realBits = [];
vecImprovMDS_geoTech = [];

numCamAtInter = [2 3 4 5 6];
numOfInter = 4; % since we have four intersections for test version 12
searchRng = 512;
testVersion = 12;
rho = 1;
SAiterLimit = 1000;
ifSaveFile = 0;
for i = 1:length(numCamAtInter)
    N = numCamAtInter(i)*numOfInter
    
    ratio = 100*BBselection_betterPrune_Inter(num2str(ifSaveFile),num2str(N),num2str(testVersion),num2str(searchRng),num2str(rho));
    vecImprovBB_realBits = [vecImprovBB_realBits ratio];
    ratio = 100*BBselection_betterPrune_geoTech_Inter(num2str(ifSaveFile),num2str(N),num2str(testVersion),num2str(searchRng),num2str(rho));
    vecImprovBB_geoTech = [vecImprovBB_geoTech ratio];
    
    [ratio_real ratio_geoTech] = SAselection (num2str(ifSaveFile),num2str(N),num2str(testVersion),num2str(searchRng),num2str(rho),num2str(SAiterLimit));
    vecImprovSA_realBits = [vecImprovSA_realBits 100*ratio_real];
    vecImprovSA_geoTech = [vecImprovSA_geoTech 100*ratio_geoTech];
    
    ratio = 100*MDS_proposed_Inter(num2str(ifSaveFile),num2str(N),num2str(testVersion),num2str(searchRng),num2str(rho));
    vecImprovMDS_realBits = [vecImprovMDS_realBits ratio];
    ratio = 100*MDS_proposed_geoTech_Inter(num2str(ifSaveFile),num2str(N),num2str(testVersion),num2str(searchRng),num2str(rho));
    vecImprovMDS_geoTech = [vecImprovMDS_geoTech ratio];
    
end

% Start plotting figures
figure(1);
plot(numCamAtInter,vecImprovBB_realBits,'^-','LineWidth',2,'DisplayName', ...
    'BB algorithm','Color','r','MarkerSize',10); hold on;
%plot(numCamAtInter,vecImprovBB_geoTech,'^--','LineWidth',2,'DisplayName', ...
%    'BB algorithm (geo)','Color','r','MarkerSize',10); hold on;

plot(numCamAtInter,vecImprovSA_realBits,'x-','LineWidth',2,'DisplayName', ...
    'SA algorithm','Color','c','MarkerSize',10); hold on;
%plot(numCamAtInter,vecImprovSA_geoTech,'x--','LineWidth',2,'DisplayName', ...
%    'SA algorithm (geo)','Color','c','MarkerSize',10); hold on;

plot(numCamAtInter,vecImprovMDS_realBits,'s-','LineWidth',2,'DisplayName', ...
    'Graph approximation','Color','b','MarkerSize',10); hold on;
%plot(numCamAtInter,vecImprovMDS_geoTech,'s--','LineWidth',2,'DisplayName', ...
%    'Graph approximation (geo)','Color','b','MarkerSize',10);

%set (gca, 'XTick',[5:1:9]);
%xt = get(gca, 'XTick');
%set (gca, 'XTickLabel', 2.^xt);
leg = legend('show','location','NorthWest');
set(leg,'FontSize',12);
axis([-inf inf -inf inf]);
ylabel('Improvement ratio (%)','FontSize',11);
xlabel('Number of cameras at one intersections','FontSize',11);
grid on;