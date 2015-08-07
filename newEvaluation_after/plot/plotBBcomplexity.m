clc;
clear;
addpath('../Utility');

plotRho = [0.1:0.1:1 1.5:0.5:5];
plotIterRequired_BB = [];
plotIterRequired_MDS = [];
for rho = plotRho
    inputFileName = ['../mat/BB/Proposed/BBBetterPruneOutput2_test10_cam20_rng512_rho' num2str(rho) '.mat'];
    load(inputFileName);
    plotIterRequired_BB = [plotIterRequired_BB length(recordUb)];
    
    inputFileName = ['../mat/MDS/MDSProposedOutput2_test10_cam20_rng512_rho' num2str(rho) '.mat'];
    load(inputFileName);
    plotIterRequired_MDS = [plotIterRequired_MDS countIter];
end


% Start plotting figures
figure(1);

semilogy(plotRho,plotIterRequired_BB,'*-','LineWidth',2,'DisplayName', ...
    'BB algorithm','Color','b','MarkerSize',10); hold on;
plot(plotRho,plotIterRequired_MDS,'^-','LineWidth',2,'DisplayName', ...
    'Graph approximation','Color','r','MarkerSize',10);

%set (gca, 'XTick',[5:1:9]);
%xt = get(gca, 'XTick');
%set (gca, 'XTickLabel', 2.^xt);
leg = legend('show','location','Best');
set(leg,'FontSize',12);
%axis([1 500 0 0.5]);
ylabel('Time complexity (required iterations)','FontSize',12);
xlabel('Overhearing range parameter (\rho)','FontSize',12);
grid on;