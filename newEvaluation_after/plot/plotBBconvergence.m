% Figure 1 is for BB convergence (baseline lb estimation)
figure(1);
load('../mat/BBoutput_test10_cam20_rng512_rho5.mat');
inputPath = ['../' inputPath];
plotLb = recordLb./(1024*8);
plotUb = recordUb./(1024*8);
for i = 1:length(plotLb)
    if plotLb(i) > plotUb(i)
        plotLb(i) = plotUb(i);
    end
end
plotBaselineLb = plotLb;
plotBaselineUb = plotUb;
%
load('../mat/BBBetterPruneOutput2_test10_cam20_rng512_rho5.mat');
plotLb = recordLb./(1024*8);
plotUb = recordUb./(1024*8);
for i = 1:length(plotLb)
    if plotLb(i) > plotUb(i)
        plotLb(i) = plotUb(i);
    end
end
plotProposedLb = plotLb;
plotProposedUb = plotUb;

semilogx(1:length(plotBaselineLb),plotBaselineLb,'--','LineWidth',2,'DisplayName', ...
    'lower bound (baseline)','Color','b','MarkerSize',10); hold on;
semilogx(1:length(plotBaselineUb),plotBaselineUb,'-','LineWidth',2,'DisplayName', ...
    'upper bound (baseline)','Color','b','MarkerSize',10); hold on;
semilogx(1:length(plotProposedLb),plotProposedLb,'--','LineWidth',2,'DisplayName', ...
    'lower bound (proposed)','Color','r','MarkerSize',10); hold on;
semilogx(1:length(plotProposedUb),plotProposedUb,'-','LineWidth',2,'DisplayName', ...
    'upper bound (proposed)','Color','r','MarkerSize',10); hold on;
leg = legend('show','location','NorthEast');
set(leg,'FontSize',12);
axis([-inf inf -inf inf]);
ylabel('Transmission bytes (kB)','FontSize',11);
xlabel('Iteration','FontSize',11);
grid on;

clear;
% Figure 2 is for comparing depth first search and proposed branching metric
figure(2);
load('../mat/BBBetterPruneOutputDepthFirst2_test10_cam20_rng512_rho5.mat');
inputPath = ['../' inputPath];
plotLb = recordLb./(1024*8);
plotUb = recordUb./(1024*8);
for i = 1:length(plotLb)
    if plotLb(i) > plotUb(i)
        plotLb(i) = plotUb(i);
    end
end
plotBaselineLb = plotLb;
plotBaselineUb = plotUb;
%
load('../mat/BBBetterPruneOutput2_test10_cam20_rng512_rho5.mat');
plotLb = recordLb./(1024*8);
plotUb = recordUb./(1024*8);
for i = 1:length(plotLb)
    if plotLb(i) > plotUb(i)
        plotLb(i) = plotUb(i);
    end
end
plotProposedLb = plotLb;
plotProposedUb = plotUb;
semilogx(1:length(plotBaselineLb),plotBaselineLb,'--','LineWidth',2,'DisplayName', ...
    'lower bound (depth first)','Color','b','MarkerSize',10); hold on;
semilogx(1:length(plotBaselineUb),plotBaselineUb,'-','LineWidth',2,'DisplayName', ...
    'upper bound (depth first)','Color','b','MarkerSize',10); hold on;
semilogx(1:length(plotProposedLb),plotProposedLb,'--','LineWidth',2,'DisplayName', ...
    'lower bound (proposed)','Color','r','MarkerSize',10); hold on;
semilogx(1:length(plotProposedUb),plotProposedUb,'-','LineWidth',2,'DisplayName', ...
    'upper bound (proposed)','Color','r','MarkerSize',10); hold on;
leg = legend('show','location','NorthEast');
set(leg,'FontSize',12);
axis([-inf inf -inf inf]);
ylabel('Transmission bytes (kB)','FontSize',11);
xlabel('Iteration','FontSize',11);
grid on;


clear;
% Figure 3 is for number of nodes in queue
figure(3);
load('../mat/BBoutput_test10_cam20_rng512_rho5.mat');
plotBaseline = recordNumInQueue;
load('../mat/BBBetterPruneOutput2_test10_cam20_rng512_rho5.mat');
plotProposed = recordNumInQueue;

semilogx(1:length(plotBaseline),plotBaseline,'-','LineWidth',2,'DisplayName', ...
    'Baseline lb estimation','Color','b','MarkerSize',10); hold on;
semilogx(1:length(plotProposed),plotProposed,'-','LineWidth',2,'DisplayName', ...
    'Proposed lb estimation','Color','r','MarkerSize',10); hold on;
leg = legend('show','location','NorthEast');
set(leg,'FontSize',12);
axis([-inf inf -inf inf]);
ylabel('Number of unpruned nodes','FontSize',11);
xlabel('Iteration','FontSize',11);
grid on;