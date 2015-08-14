clc;
clear;

testVersion = 13;
addpath('./Utility');
inputPath = ['../SourceData/test' num2str(testVersion) '/'];
vecDegree = [40 30 20 10];
numAlgs = 4;
SAIter = 300;
bsX = 0; bsY = 0; % position of base station
N = 8; % number of total cameras
rho = 1;

matPlot = zeros(length(vecDegree),numAlgs);
for i = 1:length(vecDegree)
    deg = vecDegree(i);
    vecBits = 8.*dlmread([inputPath 'outFiles/' num2str(deg) '/indepByte.txt']);
    
    imRatio = DMCP_InterNew ('0',num2str(N),num2str(testVersion),num2str(rho),num2str(deg));
    %matPlot(i,2) = (sum(vecBits)*(1-imRatio))/(8*1024);
    matPlot(i,1) = 100*imRatio;
    
    [imRatio noUse] = SAselection_Inter ('0',num2str(N),num2str(testVersion),num2str(rho),num2str(deg),num2str(SAIter));
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


clc;
clear;
testVersion = 13;
addpath('./Utility');
inputPath = ['../SourceData/test' num2str(testVersion) '/'];
vecDegree = [45 40 35 30 25 20 15 10 5];
bsX = 0; bsY = 0; % position of base station
N = 8; % number of total cameras
rho = 1;
SAIter = 300;
numAverage = 10;

vecDMCPElTime = [];
vecSAElTime = [];
vecMDSElTime = [];
vecBBElTime = [];
for i = 1:length(vecDegree)
    deg = vecDegree(i);
    vecBits = 8.*dlmread([inputPath 'outFiles/' num2str(deg) '/indepByte.txt']);
    
    eltimeDMCP = 0;
    for ttt = 1:numAverage
        tic();
        [imRatio countIter] = DMCP_InterNew ('0',num2str(N),num2str(testVersion),num2str(rho),num2str(deg));
        eltimeDMCP = eltimeDMCP + toc();
    end
    vecDMCPElTime = [vecDMCPElTime eltimeDMCP];
    
    %{
    eltimeSA = 0;
    for ttt = 1:numAverage
        tic();
        [imRatio noUse] = SAselection_Inter ('0',num2str(N),num2str(testVersion),num2str(rho),num2str(deg),num2str(SAIter));
        eltimeSA = eltimeSA + toc();
    end
    vecSAElTime = [vecSAElTime eltimeSA];
    %}
    
    eltimeMDS = 0;
    for ttt = 1:numAverage
        tic();
        [imRatio countIter] = MDS_proposed_Inter ('0',num2str(N),num2str(testVersion),num2str(rho),num2str(deg));
        eltimeMDS = eltimeMDS + toc();
    end
    vecMDSElTime = [vecMDSElTime eltimeMDS];
    
    eltimeBB = 0;
    for ttt = 1:numAverage
        tic();
        [imRatio countIter] = BBselection_betterPrune_Inter ('0',num2str(N),num2str(testVersion),num2str(rho),num2str(deg));
        eltimeBB = eltimeBB + toc();
    end
    vecBBElTime = [vecBBElTime eltimeBB];
end

figure(2);
plot(vecDegree,vecBBElTime,'*-','LineWidth',2,'DisplayName', ...
    'Proposed BB','Color',[0.8 0 0.1],'MarkerSize',10); hold on;
plot(vecDegree,vecMDSElTime,'^-','LineWidth',2,'DisplayName', ...
    'Graph approximation','Color',[1 0.9 0],'MarkerSize',10);
%plot(vecDegree,vecSAElTime,'x-','LineWidth',2,'DisplayName', ...
%    'Proposed SA','Color','c','MarkerSize',10);
plot(vecDegree,vecDMCPElTime,'o-','LineWidth',2,'DisplayName', ...
    'DMCP','Color',[0 0 0.8],'MarkerSize',10);

%set (gca, 'XTick',[5:1:9]);
%xt = get(gca, 'XTick');
%set (gca, 'XTickLabel', 2.^xt);
leg = legend('show','location','Best');
set(leg,'FontSize',12);
axis([-inf inf -inf inf]);
ylabel('Execution time (sec)','FontSize',11);
xlabel('Camera rotation (degree)','FontSize',11);
grid on;