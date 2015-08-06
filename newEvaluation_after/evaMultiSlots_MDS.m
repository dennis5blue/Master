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

vecSlots = [1 8 9 2 6 10 3 7 5 4];
pos = dlmread([inputPath 'plotTopo/pos.txt']);
dir = dlmread([inputPath 'plotTopo/dir.txt']);
    
vecIndepBits = [];
vecOverBits = [];
vecOverImprove = [];
vecOverBitsNoChange = [];
vecOverImproveNoChange = [];
vecOverBitsCondChange = [];
vecOverImproveCondChange = [];
vecIfReCalculated = [1];

for nn = vecSlots
    vecBits = 8.*dlmread([inputPath 'outFiles/rng' num2str(searchRng) '/slot' num2str(nn) '/indepByte.txt']); % bits
    matCost = 8.*dlmread([inputPath 'outFiles/rng' num2str(searchRng) '/slot' num2str(nn) '/corrMatrix.txt']); % bits
    indepBits = sum(vecBits);
    for i = 1:N
        matCost(i,i) = vecBits(i);
    end
    matCost = matCost(1:N,1:N);
    vecBits = vecBits(1:N);
    
    [overBits vecSelection] = MDS_multiSlots (num2str(N), num2str(testVersion), num2str(nn), num2str(searchRng), num2str(rho));
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

% Plot figures
figure(1);
%plot([1:length(vecSlots)],vecIndepBits,'*-','LineWidth',2,'DisplayName', ...
%    'Independent transmission','Color','b','MarkerSize',10); hold on;
plot([1:length(vecSlots)],vecOverImprove,'^-','LineWidth',2,'DisplayName', ...
    'Dynamic cost matrix (baseline)','Color','r','MarkerSize',10); hold on;
plot([1:length(vecSlots)],vecOverImproveCondChange,'*-','LineWidth',2,'DisplayName', ...
    'Dynamic cost matrix (proposed)','Color','b','MarkerSize',10); hold on;
plot([1:length(vecSlots)],vecOverImproveNoChange,'o-','LineWidth',2,'DisplayName', ...
    'Static cost matrix','Color','g','MarkerSize',10); hold on;



%set (gca, 'XTick',[5:1:9]);
%xt = get(gca, 'XTick');
%set (gca, 'XTickLabel', 2.^xt);
leg = legend('show','location','Best');
set(leg,'FontSize',12);
axis([-inf inf -inf inf]);
ylabel('Improvement ratio (%)','FontSize',11);
xlabel('Round','FontSize',11);
grid on;
%saveas(gca,'~/Desktop/ggg.pdf')