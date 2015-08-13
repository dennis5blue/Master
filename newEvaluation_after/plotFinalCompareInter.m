clc;
clear;

testVersion = 13;
addpath('./Utility');
inputPath = ['../SourceData/test' num2str(testVersion) '/'];
vecDegree = [40 30 20 10];
numAlgs = 4;
bsX = 0; bsY = 0; % position of base station
N = 8; % number of total cameras
rho = 1;

matPlot = zeros(length(vecDegree),numAlgs);
for i = 1:length(vecDegree)
    deg = vecDegree(i);
    vecBits = 8.*dlmread([inputPath 'outFiles/' num2str(deg) '/indepByte.txt']);
    
    [imRatio] = DMCP_InterNew ('0',num2str(N),num2str(testVersion),num2str(rho),num2str(deg));
    %matPlot(i,2) = (sum(vecBits)*(1-imRatio))/(8*1024);
    matPlot(i,1) = 100*imRatio;
    
    [imRatio noUse] = SAselection_Inter ('0',num2str(N),num2str(testVersion),num2str(rho),num2str(deg),'300');
    %matPlot(i,3) = (sum(vecBits)*(1-imRatio))/(8*1024);
    matPlot(i,2) = 100*imRatio;
    
    imRatio = MDS_proposed_Inter ('0',num2str(N),num2str(testVersion),num2str(rho),num2str(deg));
    %matPlot(i,4) = (sum(vecBits)*(1-imRatio))/(8*1024);
    matPlot(i,3) = 100*imRatio;
    
    imRatio = BBselection_betterPrune_Inter ('0',num2str(N),num2str(testVersion),num2str(rho),num2str(deg));
    %matPlot(i,5) = (sum(vecBits)*(1-imRatio))/(8*1024);    
    matPlot(i,4) = 100*imRatio;
end

figure(1);
l{1}='DMCP'; l{2}='Proposed SA'; l{3}='Graph approximation'; l{4}='Proposed BB';
x1 = sprintf('40%c', char(176));
x2 = sprintf('30%c', char(176));
x3 = sprintf('20%c', char(176));
x4 = sprintf('10%c', char(176));
str = {'40';'30';'20';'10'};

f = bar(matPlot,1.5);
set(gca, 'XTickLabel',str, 'XTick',1:numel(str))
legend(f,l);

leg = legend('show','location','NorthEast');
set(leg,'FontSize',11);
axis([-inf inf -inf inf]);
%set(gca,'XTick',[]);
%set(gca,'YTick',[]);
%set(gca,'YColor','w');
%set(gca,'XColor','w');
%set(gca,'YTickLabel',['']);
ylabel('Improvement ratio (%)', 'FontSize', 11);
xlabel('Camera rotation (degree)', 'FontSize', 11);
grid on;