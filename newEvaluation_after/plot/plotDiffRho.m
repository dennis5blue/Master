clc;
clear;
addpath('../Utility');

plotImproveRefI = [];
plotImproveRefP= [];
plotRho = [0.1:0.1:1.2];
searchRng = 512;
for i = 1:length(plotRho)
    rho = plotRho(i);
    inputFileName = ['../mat/PframeScheduling_cam20_rho' num2str(rho) '_alg3.mat'];
    load(inputFileName);
    inputPath = ['../' inputPath];
    indepBits = 0;
    for i = 1:N
        indepBits = indepBits + matCost(i,i);
    end
    m_newMatCost = 8.*dlmread([inputPath 'outFiles/rng' num2str(searchRng) '/corrMatrix.txt']);
    m_newMatCost = m_newMatCost(1:N,1:N);
    [costRefI, costRefP] = CalCostByRefStructure( m_newMatCost, vecBits, vecGOP );
    if length(plotImproveRefI) > 0
        if 100*(indepBits-costRefI)/indepBits > plotImproveRefI(length(plotImproveRefI))
            plotImproveRefI = [plotImproveRefI 100*(indepBits-costRefI)/indepBits];
        else
            plotImproveRefI = [plotImproveRefI plotImproveRefI(length(plotImproveRefI))];
        end
        if 100*(indepBits-costRefP)/indepBits > plotImproveRefP(length(plotImproveRefP));
            plotImproveRefP = [plotImproveRefP 100*(indepBits-costRefP)/indepBits];
        else
            plotImproveRefP = [plotImproveRefP plotImproveRefP(length(plotImproveRefP))];
        end
    else
        plotImproveRefI = [plotImproveRefI 100*(indepBits-costRefI)/indepBits];
        plotImproveRefP = [plotImproveRefP 100*(indepBits-costRefP)/indepBits];
    end
end

% Start plotting figures
figure(1);
plot(plotRho,plotImproveRefP,'*-','LineWidth',2,'DisplayName', ...
    'Reference from I-frame or P-frame','Color','b','MarkerSize',10); hold on;
plot(plotRho,plotImproveRefI,'*-','LineWidth',2,'DisplayName', ...
    'Reference only from I-frame','Color','r','MarkerSize',10);

%set (gca, 'XTick',[5:1:9]);
%xt = get(gca, 'XTick');
%set (gca, 'XTickLabel', 2.^xt);
leg = legend('show','location','NorthWest');
set(leg,'FontSize',12);
axis([-inf inf -inf inf]);
ylabel('Improve ratio (%)','FontSize',11);
xlabel('\rho','FontSize',11);
grid on;