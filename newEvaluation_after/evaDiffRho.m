clc;
clear;
addpath('./Utility');

vecImprovBB = [];
vecImprovMDS_proposed = [];
vecImprovMDS_baseline = [];
plotRho = [0.2 0.4 0.6 0.8 1.0 1.2 1.4];
searchRng = 512;
N = 25;
testVersion = 10;
for i = 1:length(plotRho)
    rho = plotRho(i)
    
    ratio = 100*BBselection_betterPrune(num2str(N),num2str(testVersion),num2str(searchRng),num2str(rho));
    vecImprovBB = [vecImprovBB ratio]
    ratio = 100*MDS_proposed(num2str(N),num2str(testVersion),num2str(searchRng),num2str(rho));
    vecImprovMDS_proposed = [vecImprovMDS_proposed ratio]
    ratio = 100*MDS_baseline(num2str(N),num2str(testVersion),num2str(searchRng),num2str(rho));
    vecImprovMDS_baseline = [vecImprovMDS_baseline ratio]
end

% Start plotting figures
figure(1);
plot(plotRho,vecImprovBB,'^-','LineWidth',2,'DisplayName', ...
    'BB algorithm','Color','r','MarkerSize',10); hold on;
plot(plotRho,vecImprovMDS_proposed,'s-','LineWidth',2,'DisplayName', ...
    'Graph approximation (proposed)','Color','b','MarkerSize',10); hold on;
plot(plotRho,vecImprovMDS_baseline,'o-','LineWidth',2,'DisplayName', ...
    'Graph approximation (baseline)','Color','m','MarkerSize',10);

%set (gca, 'XTick',[5:1:9]);
%xt = get(gca, 'XTick');
%set (gca, 'XTickLabel', 2.^xt);
leg = legend('show','location','NorthWest');
set(leg,'FontSize',12);
axis([-inf inf -inf inf]);
ylabel('Improvement ratio (%)','FontSize',11);
xlabel('Overhearing range parameter (\rho)','FontSize',11);
grid on;