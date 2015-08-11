clc;
clear;
addpath('../Utility');

inputFileName = ['../mat/SA/SAselectionGuided_test10_cam30_rng512_rho5_iter1000.mat'];
load(inputFileName);
plotRealGuide = vecRecordImprovement;
inputFileName = ['../mat/SA/SAselectionNoGuided_test10_cam30_rng512_rho5_iter1000_good.mat'];
load(inputFileName);
plotRealNoGuide = vecRecordImprovement;

% Start plotting figures
figure(1);
plot(1:length(plotRealNoGuide),plotRealNoGuide,'-','LineWidth',2,'DisplayName', ...
    'No Guided local search','Color','r','MarkerSize',10); hold on;
plot(1:length(plotRealGuide),plotRealGuide,'-','LineWidth',2,'DisplayName', ...
    'Guided local search','Color','b','MarkerSize',10); hold on;

%set (gca, 'XTick',[5:1:9]);
%xt = get(gca, 'XTick');
%set (gca, 'XTickLabel', 2.^xt);
leg = legend('show','location','Best');
set(leg,'FontSize',12);
axis([1 500 -inf inf]);
ylabel('Improvement ratio (%)','FontSize',12);
xlabel('Iteration','FontSize',12);
grid on;

clc;
clear;
inputFileName = ['../mat/SA/SAselectionGuided_test10_cam30_rng512_rho5_iter1000.mat'];
load(inputFileName);
indep = sum(vecBits)/(8*1024);
SA_guided = lowestPayoff/(8*1024);
inputFileName = ['../mat/SA/SAselectionNoGuided_test10_cam30_rng512_rho5_iter1000_good.mat'];
load(inputFileName);
SA_noGuided = lowestPayoff/(8*1024);

figure(2);
bar([1:3], [indep 0 0], 'FaceColor', [1 0 0], 'DisplayName','Independent transmission'); hold on;
bar([1:3], [0 SA_guided 0], 'FaceColor', [0 0.5 0.6], 'DisplayName','Guided SA'); hold on;
bar([1:3], [0 0 SA_noGuided], 'FaceColor', [0 0.5 0.8], 'DisplayName','No guided SA');
leg = legend('show','location','NorthEast');
set(leg,'FontSize',11);
axis([-inf inf 1000 1800]);
set(gca,'XTick',[]);
%set(gca,'YTick',[]);
%set(gca,'YColor','w');
%set(gca,'XColor','w');
set(gca,'XTickLabel',['']);
%set(gca,'YTickLabel',['']);
ylabel('Transmission bytes (kB)');
xlabel('');
grid on;
