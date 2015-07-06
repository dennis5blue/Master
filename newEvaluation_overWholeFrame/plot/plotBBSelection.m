clc;
clear;
addpath('../Utility');

% Figure 1 is for BB convergence (baseline lb estimation)
figure(1);
load('../mat/BBoutput_test10_cam20_rng512.mat');
inputPath = ['../' inputPath];
plotLb = recordLb./(1024*8);
plotUb = recordUb./(1024*8);
iter = [1:length(plotUb)];
plot(iter,plotLb,'-','LineWidth',1,'DisplayName', ...
    'lower bound (baseline)','Color','b','MarkerSize',10); hold on;
plot(iter,plotUb,'-','LineWidth',3,'DisplayName', ...
    'upper bound (baseline)','Color','r','MarkerSize',10); hold on;
leg = legend('show','location','NorthEast');
set(leg,'FontSize',12);
axis([-inf inf -inf inf]);
ylabel('Transmission bytes (kB)','FontSize',11);
xlabel('Iteration','FontSize',11);
grid on;

clear;
% Figure 2 is for BB convergence (proposed lb esimation)
figure(2);
load('../mat/BBBetterPruneOutput_test10_cam20_rng512.mat');
inputPath = ['../' inputPath];
plotLb = recordLb./(1024*8);
plotUb = recordUb./(1024*8);
iter = [1:length(plotUb)];
plot(iter,plotLb,'-','LineWidth',1,'DisplayName', ...
    'lower bound (proposed)','Color','b','MarkerSize',10); hold on;
plot(iter,plotUb,'-','LineWidth',3,'DisplayName', ...
    'upper bound (proposed)','Color','r','MarkerSize',10); hold on;
leg = legend('show','location','NorthEast');
set(leg,'FontSize',12);
axis([-inf inf -inf inf]);
ylabel('Transmission bytes (kB)','FontSize',11);
xlabel('Iteration','FontSize',11);
grid on;

clear;
% Figure 3 is for required txBytes (with different search range)
figure(3);
load('../mat/BBBetterPruneOutput_test10_cam20_rng512.mat');
inputPath = ['../' inputPath];
iFrames = find(bestSelection==1);
sg = [0 128 256 512];
indep = [sum(vecBits)/(8*1024) 0 0 0];
for i = 2:length(sg)
    m_matCost = 8.*dlmread([inputPath 'outFiles/rng' num2str(sg(i)) '/corrMatrix.txt']);
    m_matCost = m_matCost(1:N,1:N);
    for j = 1:N
        m_matCost(j,j) = vecBits(j);
    end
    m_totalCost = 0;
    for j = 1:N
        if ismember(j,iFrames)
            m_totalCost = m_totalCost + vecBits(j);
        else
            m_candidateCost = [];
            for k = 1:N
                if ismember(k,iFrames)
                    m_candidateCost = [m_candidateCost m_matCost(j,k)];
                end
            end
            m_totalCost = m_totalCost + min(m_candidateCost);
        end
    end
    eval(['sg' num2str(sg(i)) ' = [0 0 0 0];']);
    eval(['sg' num2str(sg(i)) '(' num2str(i) ') = m_totalCost/(8*1024);']);
end
bar([1:length(sg)], indep, 'FaceColor', [1 0 0], 'DisplayName','Independent transmission'); hold on;
%bar([1:length(sg)], sg32, 'FaceColor', [0 0.5 0.2], 'DisplayName','Search range = 32'); hold on;
%bar([1:length(sg)], sg64, 'FaceColor', [0 0.5 0.4], 'DisplayName','Search range = 64'); hold on;
bar([1:length(sg)], sg128, 'FaceColor', [0 0.5 0.6], 'DisplayName','Search range = 128'); hold on;
bar([1:length(sg)], sg256, 'FaceColor', [0 0.5 0.8], 'DisplayName','Search range = 256'); hold on;
bar([1:length(sg)], sg512, 'FaceColor', [0 0.5 1], 'DisplayName','Search range = 512');

leg = legend('show','location','NorthEast');
set(leg,'FontSize',11);
axis([-inf inf 1000 1230]);
set(gca,'XTick',[]);
%set(gca,'YTick',[]);
%set(gca,'YColor','w');
%set(gca,'XColor','w');
set(gca,'XTickLabel',['']);
%set(gca,'YTickLabel',['']);
ylabel('Transmission bytes (kB)');
xlabel('');
grid on;

clear;
% Figure 4 is for complexity increment
figure(4);
numBBIter = [];
numBBBaselineIter = [32 898 27807 552507];
numBruteForceIter = [];
vec_nc = [5 10 15 20 25 30];
for i = 1:length(vec_nc)
    nc = vec_nc(i);
    fileName = ['../mat/BBBetterPruneOutput_test10_cam' num2str(nc) '_rng512.mat'];
    load(fileName);
    numBBIter = [numBBIter length(recordUb)];
    numBruteForceIter = [numBruteForceIter 2^nc];
end

semilogy(vec_nc,numBruteForceIter,'-*','LineWidth',2,'DisplayName', ...
    'Brute force algorithm','Color','k','MarkerSize',10); hold on;
semilogy(vec_nc(1:4),numBBBaselineIter,'-*','LineWidth',2,'DisplayName', ...
    'Branch-and-bound algorithm (baseline)','Color','r','MarkerSize',10); hold on;
semilogy(vec_nc,numBBIter,'-*','LineWidth',2,'DisplayName', ...
    'Branch-and-bound algorithm (proposed)','Color','b','MarkerSize',10);
leg = legend('show','location','NorthWest');
set(leg,'FontSize',12);
axis([-inf inf -inf inf]);
ylabel('Required iterations','FontSize',11);
xlabel('Number of cameras','FontSize',11);
grid on;