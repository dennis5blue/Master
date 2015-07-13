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
numAverage = 1000;

vecSlots = [1 8 9 2 6 10 3 7 5 4];
pos = dlmread([inputPath 'plotTopo/pos.txt']);
dir = dlmread([inputPath 'plotTopo/dir.txt']);

%% BB
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

%% MDS
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

%% Plot figure 1
f1 = figure(1);
plot([1:length(vecSlots)],plotBBAlwaysChange,'^-','LineWidth',2,'DisplayName', ...
    'Dynamic cost matrix (baseline, BB)','Color','r','MarkerSize',10); hold on;
plot([1:length(vecSlots)],plotMDSAlwaysChange,'^--','LineWidth',2,'DisplayName', ...
    'Dynamic cost matrix (baseline, graph)','Color','r','MarkerSize',10); hold on;
plot([1:length(vecSlots)],plotBBCondChange,'*-','LineWidth',2,'DisplayName', ...
    'Dynamic cost matrix (proposed, BB)','Color','b','MarkerSize',10); hold on;
plot([1:length(vecSlots)],plotMDSCondChange,'*--','LineWidth',2,'DisplayName', ...
    'Dynamic cost matrix (proposed, graph)','Color','b','MarkerSize',10); hold on;
plot([1:length(vecSlots)],plotBBNoChange,'o-','LineWidth',2,'DisplayName', ...
    'Static cost matrix (BB)','Color','m','MarkerSize',10); hold on;
plot([1:length(vecSlots)],plotMDSNoChange,'o--','LineWidth',2,'DisplayName', ...
    'Static cost matrix (graph)','Color','m','MarkerSize',10);

leg = legend('show','location','Best');
set(leg,'FontSize',12);
axis([-inf inf -inf 11.5]);
ylabel('Improvement ratio (%)','FontSize',11);
xlabel('Round','FontSize',11);
grid on;
ti = get(gca,'TightInset');
set(gca,'Position',[ti(1) ti(2) 1-ti(3)-ti(1) 1-ti(4)-ti(2)]);
set(gca,'units','centimeters');
pos = get(gca,'Position');
ti = get(gca,'TightInset');
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize', [pos(3)+ti(1)+ti(3)+0.4 pos(4)+ti(2)+ti(4)+0.5]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition',[0 0 pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
saveas(f1,'~/Desktop/improvementOutput.pdf');

%% plot figure 2
f2 = figure(2);
plot([1:length(vecSlots)],vecBBElTime,'o-','LineWidth',2,'DisplayName', ...
    'Proposed BB algorihm','Color','b','MarkerSize',10); hold on;
plot([1:length(vecSlots)],vecMDSElTime,'^-','LineWidth',2,'DisplayName', ...
    'Graph approximation','Color','r','MarkerSize',10); hold on;

%set (gca, 'XTick',[5:1:9]);
%xt = get(gca, 'XTick');
%set (gca, 'XTickLabel', 2.^xt);
leg = legend('show','location','NorthWest');
set(leg,'FontSize',12);
axis([-inf inf 0 0.4]);
ylabel('Execution time (sec)','FontSize',11);
xlabel('Round','FontSize',11);
grid on;
ti = get(gca,'TightInset');
set(gca,'Position',[ti(1) ti(2) 1-ti(3)-ti(1) 1-ti(4)-ti(2)]);
set(gca,'units','centimeters');
pos = get(gca,'Position');
ti = get(gca,'TightInset');
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize', [pos(3)+ti(1)+ti(3)+0.4 pos(4)+ti(2)+ti(4)+0.5]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition',[0 0 pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
saveas(f2,'~/Desktop/Timeoutput.pdf');