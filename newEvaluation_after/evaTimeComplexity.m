clc;
clear;
addpath('../Utility');

plotRho = [0.1:0.1:1 1.5:0.5:5];
plotIterRequired_BB = [];
plotIterRequired_MDS = [];
plotIterRequired_SA = [];
plotIterRequired_DMCP = [];
for rho = plotRho
    inputFileName = ['./mat/BB/Proposed/BBBetterPruneOutput2_test10_cam20_rng512_rho' num2str(rho) '.mat'];
    load(inputFileName);
    plotIterRequired_BB = [plotIterRequired_BB length(recordUb)];
    
    inputFileName = ['./mat/MDS/MDSProposedOutput2_test10_cam20_rng512_rho' num2str(rho) '.mat'];
    load(inputFileName);
    plotIterRequired_MDS = [plotIterRequired_MDS countIter];
    
    plotIterRequired_SA = [plotIterRequired_SA 500]; % refer to evaDiffRho2.m
    
    DMCP('1','20','10','512',num2str(rho));
    inputFileName = ['./mat/DMCP/DMCP_test10_cam20_rng512_rho' num2str(rho) '.mat'];
    load(inputFileName);
    plotIterRequired_DMCP = [plotIterRequired_DMCP countIter];
end


% Start plotting figures
figure(1);

semilogy(plotRho,plotIterRequired_BB,'*-','LineWidth',2,'DisplayName', ...
    'Proposed BB','Color',[0.8 0 0.1],'MarkerSize',10); hold on;
semilogy(plotRho,plotIterRequired_SA,'x-','LineWidth',2,'DisplayName', ...
    'Proposed SA','Color','c','MarkerSize',10); hold on;
plot(plotRho,plotIterRequired_MDS,'^-','LineWidth',2,'DisplayName', ...
    'Graph approximation','Color',[1 0.9 0],'MarkerSize',10);
plot(plotRho,plotIterRequired_DMCP,'o-','LineWidth',2,'DisplayName', ...
    'DMCP','Color',[0 0 0.8],'MarkerSize',10);

%set (gca, 'XTick',[5:1:9]);
%xt = get(gca, 'XTick');
%set (gca, 'XTickLabel', 2.^xt);
leg = legend('show','location','Best');
set(leg,'FontSize',12);
%axis([1 500 0 0.5]);
ylabel('Time complexity (required iterations)','FontSize',12);
xlabel('Overhearing range parameter (\rho)','FontSize',12);
grid on;