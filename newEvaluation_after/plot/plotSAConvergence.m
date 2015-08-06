clc;
clear;
addpath('../Utility');

inputFileName = ['../mat/SAselectionGuided_test12_cam24_rng512_rho1_iter5000.mat'];
load(inputFileName);
plotRealGuide = (sum(vecBits) - vecRecordPayoff)./sum(vecBits);
plotGeoGuide = (sum(vecBits) - vecRecordPayoff_GeoTech)./sum(vecBits);

inputFileName = ['../mat/SAselectionNoGuided_test12_cam24_rng512_rho1_iter5000.mat'];
load(inputFileName);
plotRealNoGuide = (sum(vecBits) - vecRecordPayoff)./sum(vecBits);
plotGeoNoGuide = (sum(vecBits) - vecRecordPayoff_GeoTech)./sum(vecBits);


% Start plotting figures
figure(1);
%plot(1:iterLimit,plotRealGuide,'-','LineWidth',2,'DisplayName', ...
%    'Guide','Color','g','MarkerSize',10); hold on;
%plot(1:iterLimit,plotGeoGuide,'-','LineWidth',2,'DisplayName', ...
%    'Geo Guide','Color','c','MarkerSize',10); hold on;

plot(1:iterLimit,plotRealNoGuide,'-','LineWidth',2,'DisplayName', ...
    'Proposed camera correlation estimation','Color','b','MarkerSize',10); hold on;
plot(1:iterLimit,plotGeoNoGuide,'-','LineWidth',2,'DisplayName', ...
    'Geometric camera correlation model','Color','r','MarkerSize',10); hold on;

%set (gca, 'XTick',[5:1:9]);
%xt = get(gca, 'XTick');
%set (gca, 'XTickLabel', 2.^xt);
leg = legend('show','location','Best');
set(leg,'FontSize',12);
axis([1 500 0 0.5]);
ylabel('Reduction ratio','FontSize',12);
xlabel('Iteration','FontSize',12);
grid on;