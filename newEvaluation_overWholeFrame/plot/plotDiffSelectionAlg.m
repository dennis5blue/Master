clc;
clear;
addpath('../Utility');

figure(1);
load('../mat/BBBetterPruneOutput_test10_cam30_rng512.mat');
inputPath = ['../' inputPath];
iFrames = find(bestSelection==1);
indep = [sum(vecBits)/(8*1024) 0 0 0];
load('../mat/MDSProposedOutput2_test10_cam30_rng512_rho5.mat');
MDSproposed = [0 totalCost/(8*1024) 0 0];
SA = [0 0 1553 0];
load('../mat/BBBetterPruneOutput_test10_cam30_rng512.mat');
BB = [0 0 0 finalTxBits/(8*1024)];

bar([1:length(indep)], indep, 'FaceColor', [1 0 0], 'DisplayName','Independent transmission'); hold on;
bar([1:length(indep)], MDSproposed, 'FaceColor', [0 0.5 1], 'DisplayName','Proposed grpah approximation algorithm'); hold on;
bar([1:length(indep)], SA, 'FaceColor', [0 0.5 0.8], 'DisplayName','Proposed SA algorithm'); hold on;
bar([1:length(indep)], BB, 'FaceColor', [0 0.5 0.6], 'DisplayName','Proposed BB algorithm'); 

leg = legend('show','location','NorthEast');
set(leg,'FontSize',11);
axis([-inf inf 1300 1880]);
set(gca,'XTick',[]);
%set(gca,'YTick',[]);
%set(gca,'YColor','w');
%set(gca,'XColor','w');
set(gca,'XTickLabel',['']);
%set(gca,'YTickLabel',['']);
ylabel('Transmission bytes (kB)','FontSize',12);
xlabel('');
grid on;

