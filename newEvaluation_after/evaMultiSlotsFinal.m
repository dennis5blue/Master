% Evaluation for multiple slots (i.e correlation among cameras might change)
clc;
clear;
testVersion = 11;
inputPath = ['../SourceData/test' num2str(testVersion) '/'];
N = 10;
rho = 10;
searchRng = 32;
bsX = 0;
bsY = 0;
alpha = 0.9; % weighted sum for average improvement ratio
numAverage = 10; % average time for exec time 

vecSlots = [1 8 9 2 6 10 3 7 5 4];
pos = dlmread([inputPath 'plotTopo/pos.txt']);
dir = dlmread([inputPath 'plotTopo/dir.txt']);

% BB
disp('BB');
vecIndepBits = [];
vecOverBits = [];
vecOverImprove = [];
vecOverBitsNoChange = [];
vecOverImproveNoChange = [];
vecOverBitsCondChange = [];
vecOverImproveCondChange = [];
vecIfReCalculated = [1];
vecBBElTime = [];
for nn = vecSlots
    vecBits = 8.*dlmread([inputPath 'outFiles/rng' num2str(searchRng) '/slot' num2str(nn) '/indepByte.txt']); % bits
    matCost = 8.*dlmread([inputPath 'outFiles/rng' num2str(searchRng) '/slot' num2str(nn) '/corrMatrix.txt']); % bits
    indepBits = sum(vecBits);
    for i = 1:N
        matCost(i,i) = vecBits(i);
    end
    matCost = matCost(1:N,1:N);
    vecBits = vecBits(1:N);
    eltime = 0;
    for ttt = 1:numAverage
        tic();
        [overBits vecSelection] = BBselection_multiSlots (num2str(N), num2str(testVersion), num2str(nn), num2str(searchRng), num2str(rho));
        eltime = eltime + toc();
    end
    vecBBElTime = [vecBBElTime eltime/numAverage];
    if nn == vecSlots(1)
        firstSlotSelection = vecSelection; % Use for static H
        prevSlotSelection = vecSelection; % Use for conditional changing H
        vecAveImproveRatio = CalImprovementForEachCam( firstSlotSelection, matCost, pos, bsX, bsY, rho );
        vecIfReCalculated = [vecIfReCalculated 0]; % Indicate that slot 2 does not required to recalculate H
        overBitsCondChange = overBits;
    else
        if vecIfReCalculated(length(vecIfReCalculated)) == 0
            overBitsCondChange = CalExactCostConsiderOverRange( prevSlotSelection, matCost, pos, bsX, bsY, rho ); % bits using the solution of 1st slot
            tempIR = CalImprovementForEachCam( prevSlotSelection, matCost, pos, bsX, bsY, rho );
        elseif vecIfReCalculated(length(vecIfReCalculated)) == 1
            overBitsCondChange = CalExactCostConsiderOverRange( vecSelection, matCost, pos, bsX, bsY, rho ); % bits using the solution of 1st slot
            tempIR = CalImprovementForEachCam( vecSelection, matCost, pos, bsX, bsY, rho );
            prevSlotSelection = vecSelection;
        end
        vecNewAveImproveRatio = alpha.*tempIR + (1-alpha).*vecAveImproveRatio;
        tempCheck = vecNewAveImproveRatio - vecAveImproveRatio;
        if sum(vecNewAveImproveRatio) < sum(vecAveImproveRatio)
            % If new average improvement ratio is smallar than the long term average improvement ratio, then recalculate in the next run
            vecIfReCalculated = [vecIfReCalculated 1];
        else % otherwise, no recalculation is needed
            vecIfReCalculated = [vecIfReCalculated 0]; 
        end
        vecAveImproveRatio = vecNewAveImproveRatio;
    end
    
    % record data for plotting
    vecIndepBits = [vecIndepBits indepBits];
    vecOverBits = [vecOverBits overBits];
    vecOverBitsNoChange = [vecOverBitsNoChange CalExactCostConsiderOverRange( firstSlotSelection, matCost, pos, bsX, bsY, rho )];
    vecOverImprove = [vecOverImprove 100*(indepBits - overBits)/indepBits];
    vecOverImproveNoChange = [vecOverImproveNoChange 100*(indepBits - CalExactCostConsiderOverRange( firstSlotSelection, matCost, pos, bsX, bsY, rho ))/indepBits];
    vecOverBitsCondChange = [vecOverBitsCondChange overBitsCondChange];
    vecOverImproveCondChange = [vecOverImproveCondChange 100*(indepBits - overBitsCondChange)/indepBits];
end
vecIndepBits = vecIndepBits./(8*1024);
vecOverBits = vecOverBits./(8*1024);
vecOverBitsNoChange = vecOverBitsNoChange./(8*1024);
plotBBAlwaysChange = vecOverImprove;
plotBBCondChange = vecOverImproveCondChange;
plotBBNoChange = vecOverImproveNoChange;

% MDS
disp('MDS');
vecIndepBits = [];
vecOverBits = [];
vecOverImprove = [];
vecOverBitsNoChange = [];
vecOverImproveNoChange = [];
vecOverBitsCondChange = [];
vecOverImproveCondChange = [];
vecIfReCalculated = [1];
vecMDSElTime = [];

for nn = vecSlots
    vecBits = 8.*dlmread([inputPath 'outFiles/rng' num2str(searchRng) '/slot' num2str(nn) '/indepByte.txt']); % bits
    matCost = 8.*dlmread([inputPath 'outFiles/rng' num2str(searchRng) '/slot' num2str(nn) '/corrMatrix.txt']); % bits
    indepBits = sum(vecBits);
    for i = 1:N
        matCost(i,i) = vecBits(i);
    end
    matCost = matCost(1:N,1:N);
    vecBits = vecBits(1:N);
    
    eltime = 0;
    for ttt = 1:numAverage
        tic();
        [overBits vecSelection] = MDS_multiSlots (num2str(N), num2str(testVersion), num2str(nn), num2str(searchRng), num2str(rho));
        eltime = eltime + toc();
    end
    vecMDSElTime = [vecMDSElTime eltime/numAverage];
    if nn == vecSlots(1)
        firstSlotSelection = vecSelection; % Use for static H
        prevSlotSelection = vecSelection; % Use for conditional changing H
        %firstSlotSelection
        vecAveImproveRatio = CalImprovementForEachCam( firstSlotSelection, matCost, pos, bsX, bsY, rho );
        vecIfReCalculated = [vecIfReCalculated 0]; % Indicate that slot 2 does not required to recalculate H
        overBitsCondChange = overBits;
    else
        if vecIfReCalculated(length(vecIfReCalculated)) == 0
            overBitsCondChange = CalExactCostConsiderOverRange( prevSlotSelection, matCost, pos, bsX, bsY, rho ); % bits using the solution of 1st slot
            tempIR = CalImprovementForEachCam( prevSlotSelection, matCost, pos, bsX, bsY, rho );
        elseif vecIfReCalculated(length(vecIfReCalculated)) == 1
            overBitsCondChange = CalExactCostConsiderOverRange( vecSelection, matCost, pos, bsX, bsY, rho ); % bits using the solution of 1st slot
            tempIR = CalImprovementForEachCam( vecSelection, matCost, pos, bsX, bsY, rho );
            prevSlotSelection = vecSelection;
        end
        vecNewAveImproveRatio = alpha.*tempIR + (1-alpha).*vecAveImproveRatio;
        tempCheck = vecNewAveImproveRatio - vecAveImproveRatio;
        if sum(vecNewAveImproveRatio) < sum(vecAveImproveRatio)
            % If new average improvement ratio is smallar than the long term average improvement ratio, then recalculate in the next run
            vecIfReCalculated = [vecIfReCalculated 1];
        else % otherwise, no recalculation is needed
            vecIfReCalculated = [vecIfReCalculated 0]; 
        end
        vecAveImproveRatio = vecNewAveImproveRatio;
    end
    
    % record data for plotting
    vecIndepBits = [vecIndepBits indepBits];
    vecOverBits = [vecOverBits overBits];
    vecOverBitsNoChange = [vecOverBitsNoChange CalExactCostConsiderOverRange( firstSlotSelection, matCost, pos, bsX, bsY, rho )];
    vecOverImprove = [vecOverImprove 100*(indepBits - overBits)/indepBits];
    vecOverImproveNoChange = [vecOverImproveNoChange 100*(indepBits - CalExactCostConsiderOverRange( firstSlotSelection, matCost, pos, bsX, bsY, rho ))/indepBits];
    vecOverBitsCondChange = [vecOverBitsCondChange overBitsCondChange];
    vecOverImproveCondChange = [vecOverImproveCondChange 100*(indepBits - overBitsCondChange)/indepBits];
end
vecIndepBits = vecIndepBits./(8*1024);
vecOverBits = vecOverBits./(8*1024);
vecOverBitsNoChange = vecOverBitsNoChange./(8*1024);
plotMDSAlwaysChange = vecOverImprove;
plotMDSCondChange = vecOverImproveCondChange;
plotMDSNoChange = vecOverImproveNoChange;

% SA
disp('SA');
vecIndepBits = [];
vecOverBits = [];
vecOverImprove = [];
vecOverBitsNoChange = [];
vecOverImproveNoChange = [];
vecOverBitsCondChange = [];
vecOverImproveCondChange = [];
vecIfReCalculated = [1];
vecSAElTime = [];

for nn = vecSlots
    vecBits = 8.*dlmread([inputPath 'outFiles/rng' num2str(searchRng) '/slot' num2str(nn) '/indepByte.txt']); % bits
    matCost = 8.*dlmread([inputPath 'outFiles/rng' num2str(searchRng) '/slot' num2str(nn) '/corrMatrix.txt']); % bits
    indepBits = sum(vecBits);
    for i = 1:N
        matCost(i,i) = vecBits(i);
    end
    matCost = matCost(1:N,1:N);
    vecBits = vecBits(1:N);
    
    eltime = 0;
    cmuOverBits_SA = 0;
    for ttt = 1:numAverage
        tic();
        [overBits vecSelection] = SAselection_multiSlots (num2str(N),num2str(testVersion),num2str(nn),num2str(searchRng),num2str(rho),'15');
        eltime = eltime + toc();
        cmuOverBits_SA = cmuOverBits_SA + overBits;
    end
    vecSAElTime = [vecSAElTime eltime/numAverage];
    overBits = cmuOverBits_SA/numAverage;
    if nn == vecSlots(1)
        firstSlotSelection = vecSelection; % Use for static H
        prevSlotSelection = vecSelection; % Use for conditional changing H
        %firstSlotSelection
        vecAveImproveRatio = CalImprovementForEachCam( firstSlotSelection, matCost, pos, bsX, bsY, rho );
        vecIfReCalculated = [vecIfReCalculated 0]; % Indicate that slot 2 does not required to recalculate H
        overBitsCondChange = overBits;
    else
        if vecIfReCalculated(length(vecIfReCalculated)) == 0
            overBitsCondChange = CalExactCostConsiderOverRange( prevSlotSelection, matCost, pos, bsX, bsY, rho ); % bits using the solution of 1st slot
            tempIR = CalImprovementForEachCam( prevSlotSelection, matCost, pos, bsX, bsY, rho );
        elseif vecIfReCalculated(length(vecIfReCalculated)) == 1
            overBitsCondChange = CalExactCostConsiderOverRange( vecSelection, matCost, pos, bsX, bsY, rho ); % bits using the solution of 1st slot
            tempIR = CalImprovementForEachCam( vecSelection, matCost, pos, bsX, bsY, rho );
            prevSlotSelection = vecSelection;
        end
        vecNewAveImproveRatio = alpha.*tempIR + (1-alpha).*vecAveImproveRatio;
        tempCheck = vecNewAveImproveRatio - vecAveImproveRatio;
        if sum(vecNewAveImproveRatio) < sum(vecAveImproveRatio)
            % If new average improvement ratio is smallar than the long term average improvement ratio, then recalculate in the next run
            vecIfReCalculated = [vecIfReCalculated 1];
        else % otherwise, no recalculation is needed
            vecIfReCalculated = [vecIfReCalculated 0]; 
        end
        vecAveImproveRatio = vecNewAveImproveRatio;
    end
    
    % record data for plotting
    vecIndepBits = [vecIndepBits indepBits];
    vecOverBits = [vecOverBits overBits];
    vecOverBitsNoChange = [vecOverBitsNoChange CalExactCostConsiderOverRange( firstSlotSelection, matCost, pos, bsX, bsY, rho )];
    vecOverImprove = [vecOverImprove 100*(indepBits - overBits)/indepBits];
    vecOverImproveNoChange = [vecOverImproveNoChange 100*(indepBits - CalExactCostConsiderOverRange( firstSlotSelection, matCost, pos, bsX, bsY, rho ))/indepBits];
    vecOverBitsCondChange = [vecOverBitsCondChange overBitsCondChange];
    vecOverImproveCondChange = [vecOverImproveCondChange 100*(indepBits - overBitsCondChange)/indepBits];
end
vecIndepBits = vecIndepBits./(8*1024);
vecOverBits = vecOverBits./(8*1024);
vecOverBitsNoChange = vecOverBitsNoChange./(8*1024);
plotSAAlwaysChange = vecOverImprove;
plotSACondChange = vecOverImproveCondChange;
plotSANoChange = vecOverImproveNoChange;

% DMCP
disp('DMCP');
vecIndepBits = [];
vecOverBits = [];
vecOverImprove = [];
vecOverBitsNoChange = [];
vecOverImproveNoChange = [];
vecOverBitsCondChange = [];
vecOverImproveCondChange = [];
vecIfReCalculated = [1];
vecDMCPElTime = [];

for nn = vecSlots
    vecBits = 8.*dlmread([inputPath 'outFiles/rng' num2str(searchRng) '/slot' num2str(nn) '/indepByte.txt']); % bits
    matCost = 8.*dlmread([inputPath 'outFiles/rng' num2str(searchRng) '/slot' num2str(nn) '/corrMatrix.txt']); % bits
    indepBits = sum(vecBits);
    for i = 1:N
        matCost(i,i) = vecBits(i);
    end
    matCost = matCost(1:N,1:N);
    vecBits = vecBits(1:N);
    
    eltime = 0;
    for ttt = 1:numAverage
        tic();
        [overBits vecSelection] = DMCP_MultiSlots (num2str(N),num2str(testVersion),num2str(nn),num2str(searchRng),num2str(rho));
        eltime = eltime + toc();
    end
    vecDMCPElTime = [vecDMCPElTime eltime/numAverage];
    if nn == vecSlots(1)
        firstSlotSelection = vecSelection; % Use for static H
        prevSlotSelection = vecSelection; % Use for conditional changing H
        %firstSlotSelection
        vecAveImproveRatio = CalImprovementForEachCam( firstSlotSelection, matCost, pos, bsX, bsY, rho );
        vecIfReCalculated = [vecIfReCalculated 0]; % Indicate that slot 2 does not required to recalculate H
        overBitsCondChange = overBits;
    else
        if vecIfReCalculated(length(vecIfReCalculated)) == 0
            overBitsCondChange = CalExactCostConsiderOverRange( prevSlotSelection, matCost, pos, bsX, bsY, rho ); % bits using the solution of 1st slot
            tempIR = CalImprovementForEachCam( prevSlotSelection, matCost, pos, bsX, bsY, rho );
        elseif vecIfReCalculated(length(vecIfReCalculated)) == 1
            overBitsCondChange = CalExactCostConsiderOverRange( vecSelection, matCost, pos, bsX, bsY, rho ); % bits using the solution of 1st slot
            tempIR = CalImprovementForEachCam( vecSelection, matCost, pos, bsX, bsY, rho );
            prevSlotSelection = vecSelection;
        end
        vecNewAveImproveRatio = alpha.*tempIR + (1-alpha).*vecAveImproveRatio;
        tempCheck = vecNewAveImproveRatio - vecAveImproveRatio;
        if sum(vecNewAveImproveRatio) < sum(vecAveImproveRatio)
            % If new average improvement ratio is smallar than the long term average improvement ratio, then recalculate in the next run
            vecIfReCalculated = [vecIfReCalculated 1];
        else % otherwise, no recalculation is needed
            vecIfReCalculated = [vecIfReCalculated 0]; 
        end
        vecAveImproveRatio = vecNewAveImproveRatio;
    end
    
    % record data for plotting
    vecIndepBits = [vecIndepBits indepBits];
    vecOverBits = [vecOverBits overBits];
    vecOverBitsNoChange = [vecOverBitsNoChange CalExactCostConsiderOverRange( firstSlotSelection, matCost, pos, bsX, bsY, rho )];
    vecOverImprove = [vecOverImprove 100*(indepBits - overBits)/indepBits];
    vecOverImproveNoChange = [vecOverImproveNoChange 100*(indepBits - CalExactCostConsiderOverRange( firstSlotSelection, matCost, pos, bsX, bsY, rho ))/indepBits];
    vecOverBitsCondChange = [vecOverBitsCondChange overBitsCondChange];
    vecOverImproveCondChange = [vecOverImproveCondChange 100*(indepBits - overBitsCondChange)/indepBits];
end
vecIndepBits = vecIndepBits./(8*1024);
vecOverBits = vecOverBits./(8*1024);
vecOverBitsNoChange = vecOverBitsNoChange./(8*1024);
plotDMCPAlwaysChange = vecOverImprove;
plotDMCPCondChange = vecOverImproveCondChange;
plotDMCPNoChange = vecOverImproveNoChange;

% Plot figure 1
figure(1);
plot([1:length(vecSlots)],plotBBAlwaysChange,'^-','LineWidth',2,'DisplayName', ...
    'Dynamic cost matrix (baseline re-estimation)','Color','r','MarkerSize',10); hold on;
plot([1:length(vecSlots)],plotBBCondChange,'s-','LineWidth',2,'DisplayName', ...
    'Dynamic cost matrix (proposed re-estimation)','Color','b','MarkerSize',10); hold on;
plot([1:length(vecSlots)],plotBBNoChange,'o-','LineWidth',2,'DisplayName', ...
    'Static cost matrix','Color','m','MarkerSize',10); hold on;

leg = legend('show','location','Best');
set(leg,'FontSize',12);
axis([-inf inf -inf inf]);
ylabel('Improvement ratio (%)','FontSize',11);
xlabel('Round','FontSize',11);
grid on;

% plot figure 2
figure(2);
plot([1:length(vecSlots)],vecBBElTime,'*-','LineWidth',2,'DisplayName', ...
    'Proposed BB','Color',[0.8 0 0.1],'MarkerSize',10); hold on;
plot([1:length(vecSlots)],vecMDSElTime,'^-','LineWidth',2,'DisplayName', ...
    'Graph approximation','Color',[1 0.9 0],'MarkerSize',10);
plot([1:length(vecSlots)],vecSAElTime,'x-','LineWidth',2,'DisplayName', ...
    'Proposed SA','Color','c','MarkerSize',10);
plot([1:length(vecSlots)],vecDMCPElTime,'o-','LineWidth',2,'DisplayName', ...
    'DMCP','Color',[0 0 0.8],'MarkerSize',10);

%set (gca, 'XTick',[5:1:9]);
%xt = get(gca, 'XTick');
%set (gca, 'XTickLabel', 2.^xt);
leg = legend('show','location','NorthWest');
set(leg,'FontSize',12);
axis([-inf inf 0 0.25]);
ylabel('Execution time (sec)','FontSize',11);
xlabel('Round','FontSize',11);
grid on;
%ti = get(gca,'TightInset');
%set(gca,'Position',[ti(1) ti(2) 1-ti(3)-ti(1) 1-ti(4)-ti(2)]);
%set(gca,'units','centimeters');
%pos = get(gca,'Position');
%ti = get(gca,'TightInset');
%set(gcf, 'PaperUnits','centimeters');
%set(gcf, 'PaperSize', [pos(3)+ti(1)+ti(3)+0.4 pos(4)+ti(2)+ti(4)+0.5]);
%set(gcf, 'PaperPositionMode', 'manual');
%set(gcf, 'PaperPosition',[0 0 pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
%saveas(f2,'~/Desktop/Timeoutput.pdf');

% plot figure 3
vecCmuBBElTime_baseline = [vecBBElTime(1)];
vecCmuMDSElTime_baseline = [vecMDSElTime(1)];
vecCmuSAElTime_baseline = [vecSAElTime(1)];
vecCmuDMCPElTime_baseline = [vecDMCPElTime(1)];
vecCmuBBElTime_proposed = [vecBBElTime(1)];
vecCmuMDSElTime_proposed = [vecMDSElTime(1)];
vecCmuSAElTime_proposed = [vecSAElTime(1)];
vecCmuDMCPElTime_proposed = [vecDMCPElTime(1)];
for run = 2:length(vecSlots)
    BBtime = vecCmuBBElTime_baseline(length(vecCmuBBElTime_baseline)) + vecBBElTime(run);
    MDStime = vecCmuMDSElTime_baseline(length(vecCmuMDSElTime_baseline)) + vecMDSElTime(run);
    SAtime = vecCmuSAElTime_baseline(length(vecCmuSAElTime_baseline)) + vecSAElTime(run);
    DMCPtime = vecCmuDMCPElTime_baseline(length(vecCmuDMCPElTime_baseline)) + vecDMCPElTime(run);
    vecCmuBBElTime_baseline = [vecCmuBBElTime_baseline BBtime];
    vecCmuMDSElTime_baseline = [vecCmuMDSElTime_baseline MDStime];
    vecCmuSAElTime_baseline = [vecCmuSAElTime_baseline SAtime];
    vecCmuSAElTime_baseline = [vecCmuSAElTime_baseline DMCPtime];
    if vecIfReCalculated(run) == 1
        BBtime = vecCmuBBElTime_proposed(length(vecCmuBBElTime_proposed)) + vecBBElTime(run);
        MDStime = vecCmuMDSElTime_proposed(length(vecCmuMDSElTime_proposed)) + vecMDSElTime(run);
        SAtime = vecCmuSAElTime_proposed(length(vecCmuSAElTime_proposed)) + vecSAElTime(run);
        DMCPtime = vecCmuDMCPElTime_proposed(length(vecCmuDMCPElTime_proposed)) + vecDMCPElTime(run);
    else
        BBtime = vecCmuBBElTime_proposed(length(vecCmuBBElTime_proposed));
        MDStime = vecCmuMDSElTime_proposed(length(vecCmuMDSElTime_proposed));
        SAtime = vecCmuSAElTime_proposed(length(vecCmuSAElTime_proposed));
        DMCPtime = vecCmuDMCPElTime_proposed(length(vecCmuDMCPElTime_proposed));
    end
    vecCmuBBElTime_proposed = [vecCmuBBElTime_proposed BBtime];
    vecCmuMDSElTime_proposed = [vecCmuMDSElTime_proposed MDStime];
    vecCmuSAElTime_proposed = [vecCmuSAElTime_proposed SAtime];
    vecCmuDMCPElTime_proposed = [vecCmuDMCPElTime_proposed DMCPtime];
end
figure(3);
plot([1:length(vecSlots)],vecCmuBBElTime_baseline,'s-','LineWidth',2,'DisplayName', ...
    'Baseline re-estimation (BB)','Color','black','MarkerSize',10); hold on;
plot([1:length(vecSlots)],vecCmuBBElTime_proposed,'*-','LineWidth',2,'DisplayName', ...
    'Proposed re-estimation (BB)','Color',[0.8 0 0.1],'MarkerSize',10); hold on;
plot([1:length(vecSlots)],vecCmuMDSElTime_proposed,'^-','LineWidth',2,'DisplayName', ...
    'Proposed re-estimation (graph)','Color',[1 0.9 0],'MarkerSize',10);
plot([1:length(vecSlots)],vecCmuSAElTime_proposed,'x-','LineWidth',2,'DisplayName', ...
    'Proposed re-estimation (SA)','Color','c','MarkerSize',10);
plot([1:length(vecSlots)],vecCmuDMCPElTime_proposed,'o-','LineWidth',2,'DisplayName', ...
    'Proposed re-estimation (DMCP)','Color',[0 0 0.8],'MarkerSize',10);

leg = legend('show','location','NorthWest');
set(leg,'FontSize',12);
axis([-inf inf -inf inf]);
ylabel('Cumulative execution time (sec)','FontSize',11);
xlabel('Round','FontSize',11);
grid on;

% Plot figure 4
figure(4);
plot([1:length(vecSlots)],plotBBAlwaysChange,'s-','LineWidth',2,'DisplayName', ...
    'Performance upper bound','Color','black','MarkerSize',10); hold on;
plot([1:length(vecSlots)],plotBBCondChange,'*-','LineWidth',2,'DisplayName', ...
    'Proposed BB','Color',[0.8 0 0.1],'MarkerSize',10); hold on;
plot([1:length(vecSlots)],plotMDSCondChange,'^-','LineWidth',2,'DisplayName', ...
    'Graph approximation','Color',[1 0.9 0],'MarkerSize',10); hold on;
plot([1:length(vecSlots)],plotSACondChange,'x-','LineWidth',2,'DisplayName', ...
    'Proposed SA','Color','c','MarkerSize',10); hold on;
plot([1:length(vecSlots)],plotDMCPCondChange,'o-','LineWidth',2,'DisplayName', ...
    'DMCP','Color',[0 0 0.8],'MarkerSize',10); hold on;

leg = legend('show','location','Best');
set(leg,'FontSize',12);
axis([-inf inf -inf 11.5]);
ylabel('Improvement ratio (%)','FontSize',11);
xlabel('Round','FontSize',11);
grid on;