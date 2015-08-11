clc;
clear;
addpath('../Utility');

figure(1);
load('../mat/MDS/MDSBaselineOutput_test10_cam30_rng512_rho5.mat');
indep = [sum(vecBits)/(8*1024) 0 0];
MDSbaseline = [0 totalCost/(8*1024) 0];
load('../mat/MDS/MDSProposedOutput2_test10_cam30_rng512_rho5.mat');
MDSproposed = [0 0 totalCost/(8*1024)];

bar([1:length(indep)], indep, 'FaceColor', [1 0 0], 'DisplayName','Independent transmission'); hold on;
bar([1:length(indep)], MDSbaseline, 'FaceColor', [0 0.5 0.8], 'DisplayName','Minimum weight dominating set (baseline)'); hold on;
bar([1:length(indep)], MDSproposed, 'FaceColor', [0 0.5 1], 'DisplayName','Minimum weight dominating set (proposed)');

leg = legend('show','location','NorthEast');
set(leg,'FontSize',11);
axis([-inf inf 1400 1880]);
set(gca,'XTick',[]);
%set(gca,'YTick',[]);
%set(gca,'YColor','w');
%set(gca,'XColor','w');
set(gca,'XTickLabel',['']);
%set(gca,'YTickLabel',['']);
ylabel('Transmission bytes (kB)');
xlabel('');
grid on;