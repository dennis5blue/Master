clc;
clear;
addpath('../Utility');
load('../IframeStructure.mat');
inputPath = ['../' inputPath];

% Figure 1 is for BB convergence
figure(1);
plotLb = recordLb./(1024*8);
plotUb = recordUb./(1024*8);
iter = [1:length(plotUb)];
plot(iter,plotLb,'-','LineWidth',1,'DisplayName', ...
    'lower bound','Color','b','MarkerSize',10); hold on;
plot(iter,plotUb,'-','LineWidth',3,'DisplayName', ...
    'upper bound','Color','r','MarkerSize',10);
leg = legend('show','location','NorthEast');
set(leg,'FontSize',12);
axis([-inf inf -inf inf]);
ylabel('Transmission bytes (kB)','FontSize',11);
xlabel('Iteration','FontSize',11);
grid on;

% Figure 2 is for required txBytes
figure(2);

iFrames = find(bestSelection==1);
% Find the reference camera
whichIFrame = zeros(1,N);
for i = 1:N
    if ~ismember(i,iFrames)
        tempCost = matCost(i,iFrames);
        for j = 1:length(iFrames)
            if IfCanOverhear(pos(i,1),pos(i,2),pos(iFrames(j),1),pos(iFrames(j),2),bsX,bsY,rho) == 0
                tempCost(j) = inf;
            end
        end
        [val idx] = sort(tempCost,'ascend');
        whichIFrame(i) = iFrames(idx(1));
    else
        whichIFrame(i) = i;
    end
end

% Initialize vecGOP (group of pictures to be scheduled)
vecGOP = [];
for i = 1:length(iFrames)
    iCam = iFrames(i);
    corrPFrames = [];
    for j = 1:N
        if j ~= iCam
            if whichIFrame(j) == iCam
                corrPFrames = [corrPFrames j];
            end
        end
    end
    GOP = struct('iFrame',iCam,'pFrames',corrPFrames,'schedule',[],'refStructure',iCam.*ones(1,length(corrPFrames)));
    vecGOP = [vecGOP GOP];
end

sg = [0 32 64 128 256 512];
indep = [CalExactCost(ones(1,N),matCost)/(8*1024) 0 0 0 0 0];
for i = 2:length(sg)
    m_matCost = 8.*dlmread([inputPath 'outFiles/rng' num2str(sg(i)) '/corrMatrix.txt']);
    m_matCost = m_matCost(1:N,1:N);
    [ costRefI, costRefP ] = CalCostByRefStructure( m_matCost, vecBits, vecGOP );
    eval(['sg' num2str(sg(i)) ' = [0 0 0 0 0 0];']);
    eval(['sg' num2str(sg(i)) '(' num2str(i) ') = costRefI/(8*1024);']);
end
bar([1:length(sg)], indep, 'FaceColor', [1 0 0], 'DisplayName','Independent transmission'); hold on;
bar([1:length(sg)], sg32, 'FaceColor', [0 0.5 0.2], 'DisplayName','Search range = 32'); hold on;
bar([1:length(sg)], sg64, 'FaceColor', [0 0.5 0.4], 'DisplayName','Search range = 64'); hold on;
bar([1:length(sg)], sg128, 'FaceColor', [0 0.5 0.6], 'DisplayName','Search range = 128'); hold on;
bar([1:length(sg)], sg256, 'FaceColor', [0 0.5 0.8], 'DisplayName','Search range = 256'); hold on;
bar([1:length(sg)], sg512, 'FaceColor', [0 0.5 1], 'DisplayName','Search range = 512');

leg = legend('show','location','NorthEast');
set(leg,'FontSize',11);
axis([-inf inf 400 950]);
set(gca,'XTick',[]);
%set(gca,'YTick',[]);
%set(gca,'YColor','w');
%set(gca,'XColor','w');
set(gca,'XTickLabel',['']);
%set(gca,'YTickLabel',['']);
ylabel('Transmission bytes (kB)');
xlabel('');
grid on;