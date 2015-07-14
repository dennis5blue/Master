clc;
clear;
testVersion = 11;
inputPath = ['../../SourceData/test' num2str(testVersion) '/'];
N = 10;
rho = 10;
searchRng = 32;
bsX = 0;
bsY = 0;

vecSlots = [1 8 9 2 6 10 3 7 5 4];
pos = dlmread([inputPath 'plotTopo/pos.txt']);
dir = dlmread([inputPath 'plotTopo/dir.txt']);
inputPath = ['../../SourceData/test' num2str(testVersion) '/'];

for round = 1:10
    if round == 1
        vecSeletion =  [0     1     0     0     1     1     0     0     1     0]; % 1
    elseif round == 2
        vecSeletion =  [0     0     1     0     0     0     1     0     0     1]; % 8
    elseif round == 3
        vecSeletion =  [0     0     1     0     1     1     0     0     1     1]; % 9
    elseif round == 4
        vecSeletion =  [0     0     1     0     0     0     1     0     0     1]; % 2
    elseif round == 5
        vecSeletion =  [0     0     1     0     0     0     1     0     0     1]; % 6
    elseif round == 6
        vecSeletion =  [0     0     1     0     1     0     1     0     0     1]; % 10
    elseif round == 7
        vecSeletion =  [0     0     1     0     1     0     1     0     0     1]; % 3
    elseif round == 8
        vecSeletion =  [0     0     1     0     0     0     1     0     0     1]; % 7
    elseif round == 9
        vecSeletion =  [0     0     1     0     1     0     1     0     1     0]; % 5
    elseif round == 10
        vecSeletion = [0     0     1     0     1     0     1     0     1     0]; % 4
    end

    vecBits = 8.*dlmread([inputPath 'outFiles/rng' num2str(searchRng) '/slot' num2str(vecSlots(round)) '/indepByte.txt']); % bits
    matCost = 8.*dlmread([inputPath 'outFiles/rng' num2str(searchRng) '/slot' num2str(vecSlots(round)) '/corrMatrix.txt']); % bits
    indepBits = sum(vecBits);
    for i = 1:N
        matCost(i,i) = vecBits(i);
    end
    matCost = matCost(1:N,1:N);
    vecBits = vecBits(1:N);

    vecRefStru = zeros(1,N);
    iFrames = find(vecSeletion==1);
    for cam = 1:N
        if vecSeletion(cam) == 1
            vecRefStru(cam) = cam;
        else
            vecCost = [];
            for i = 1:iFrames
                iCam = iFrames(i);
                vecCost = [vecCost matCost(cam,iCam)];
            end
            [val idx] = sort(vecCost,'ascend');
            vecRefStru(cam) = iFrames(idx(1));
        end
    end

    %round = round
    slot = vecSlots(round);
    %vecRefStru
end

% Start plotting
vecPlotIndepPsnr = [];
vecPlotOverPsnr = [];
rS = 1;
rE = 10;
for round = rS:rE
    indepPsnr = sum(dlmread(['../../imageTest/outFiles/indep_round' num2str(round) '.txt']))/N;
    overPsnr = sum(dlmread(['../../imageTest/outFiles/over_round' num2str(round) '.txt']))/N;
    vecPlotIndepPsnr = [vecPlotIndepPsnr indepPsnr];
    vecPlotOverPsnr = [vecPlotOverPsnr overPsnr];
end

figure(1);
plot(rS:rE,vecPlotIndepPsnr,'^-','LineWidth',2,'DisplayName', ...
    'Independent encoding','Color','b','MarkerSize',10); hold on;
plot(rS:rE,vecPlotOverPsnr,'o-','LineWidth',2,'DisplayName', ...
    'Overhearing encoding','Color','r','MarkerSize',10);
leg = legend('show','location','NorthEast');
set(leg,'FontSize',12);
%axis([-inf inf 38.65 38.715]);
ylabel('PSNR of reconstructed image','FontSize',11);
xlabel('Round','FontSize',11);
grid on;