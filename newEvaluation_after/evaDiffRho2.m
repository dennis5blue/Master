clc;
clear;
addpath('./Utility');

plotRho = [0.5 1.0 1.5 2.0];
searchRng = 512;
N = 25;
testVersion = 10;

numAlgs = 4;
matPlot = zeros(length(plotRho),numAlgs);
for i = 1:length(plotRho)
    rho = plotRho(i);
    
    ratio = 100*DMCP('0',num2str(N),num2str(testVersion),num2str(searchRng),num2str(rho));
    matPlot(i,1) = ratio;
    
    ratio = 100*SAselection ('0',num2str(N),num2str(testVersion),num2str(searchRng),num2str(rho),'500');
    matPlot(i,2) = ratio;
    
    ratio = 100*MDS_proposed('0',num2str(N),num2str(testVersion),num2str(searchRng),num2str(rho));
    matPlot(i,3) = ratio;
    
    ratio = 100*BBselection_betterPrune('0',num2str(N),num2str(testVersion),num2str(searchRng),num2str(rho));
    matPlot(i,4) = ratio;
end

% Start plotting figures
%{
figure(1);
plot(plotRho,vecImprovBB,'^-','LineWidth',2,'DisplayName', ...
    'Proposed BB','Color',[0.85 0 0],'MarkerSize',10); hold on;
plot(plotRho,vecImprovMDS,'s-','LineWidth',2,'DisplayName', ...
    'Graph approximation','Color',[1 0.6471 0],'MarkerSize',10); hold on;
plot(plotRho,vecImprovSA,'o-','LineWidth',2,'DisplayName', ...
    'Proposed SA','Color',[0 0.8980 0.9333],'MarkerSize',10); hold on;
plot(plotRho,vecImprovDMCP,'x-','LineWidth',2,'DisplayName', ...
    'DMCP','Color',[0 0 0.85],'MarkerSize',10); hold on;
%}


figure(1);
l{1}='DMCP'; l{2}='Proposed SA'; l{3}='Graph approximation'; l{4}='Proposed BB';
x1 = sprintf('40%c', char(176));
x2 = sprintf('30%c', char(176));
x3 = sprintf('20%c', char(176));
x4 = sprintf('10%c', char(176));
str = {'40';'30';'20';'10'};

f = bar(matPlot,1.5);
set(gca, 'XTickLabel',plotRho, 'XTick',1:numel(str))
legend(f,l);

%set(gca,'XTick',[]);
%set(gca,'YTick',[]);
%set(gca,'YColor','w');
%set(gca,'XColor','w');
%set(gca,'YTickLabel',['']);
leg = legend('show','location','NorthWest');
set(leg,'FontSize',12);
axis([-inf inf -inf inf]);
ylabel('Improvement ratio (%)','FontSize',11);
xlabel('Overhearing range parameter (\rho)','FontSize',11);
grid on;