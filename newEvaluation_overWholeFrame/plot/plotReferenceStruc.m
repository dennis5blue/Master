clear all;close all;
clc;
figure;

%% Parameters setting
addpath('../Utility/');
load('../mat/BBBetterPruneOutput2_test10_cam30_rng512.mat');
vecDirection = dlmread('../../SourceData/test10/plotTopo/dir.txt');
vecPosition = dlmread('../../SourceData/test10/plotTopo/pos.txt');
radius = 250;
r = 50; % parameter for arrow.m
%pos = vecPosition;

iFrames = find(bestSelection == 1);
numClusters = length(iFrames);
vecRefStruc = zeros(1,N);
for i = 1:N
    if ismember(i,iFrames)
        vecRefStruc(i) = i;
    else
        vecTmpCost = [];
        for j = 1:numClusters
            iCam = iFrames(j);
            if IfCanOverhear( pos(i,1),pos(i,2),pos(iCam,1),pos(iCam,2),bsX,bsY,rho ) == 1
                vecTmpCost = [vecTmpCost matCost(i,iCam)];
            else
                vecTmpCost = [vecTmpCost inf];
            end
        end
        [val idx] = sort(vecTmpCost,'ascend');
        vecRefStruc(i) = iFrames(idx(1));
    end
end
vecColor = ['y' 'm' 'c' 'r' 'g' 'b' 'k'];

%% Plot camera's sensing direction
circle(0,0,radius*sqrt(2));
hold on;
for cc = 1:numClusters
    head = iFrames(cc);
    xx = vecPosition(head,1);
    yy = vecPosition(head,2);
    theta = vecDirection(head);
    u = xx + r * cos(theta); % convert polar (theta,r) to cartesian
    v = yy + r * sin(theta);
    if cc <= length(vecColor)
        ARR = arrow([xx yy],[u v],'BaseAngle',30,'length',10,'width',0.5,...
            'EdgeColor',vecColor(cc), ...
            'FaceColor',vecColor(cc));
        set( get(get(ARR,'Annotation'),'LegendInformation'),...
            'IconDisplayStyle','off');
        hold on;
    else
        ARR = arrow([xx yy],[u v],'BaseAngle',30,'length',10,'width',0.5,...
            'EdgeColor',[0.8 (cc-1)/numClusters (cc-1)/numClusters], ...
            'FaceColor',[0.8 (cc-1)/numClusters (cc-1)/numClusters]);
        set( get(get(ARR,'Annotation'),'LegendInformation'),...
            'IconDisplayStyle','off');
        hold on;
    end
    
    members = find(vecRefStruc == head);
    for mm = 1:length(members)
        xx = vecPosition(members(mm),1);
        yy = vecPosition(members(mm),2);
        theta = vecDirection(members(mm));
        u = xx + r * cos(theta); % convert polar (theta,r) to cartesian
        v = yy + r * sin(theta);
        if cc <= length(vecColor)
            ARR = arrow([xx yy],[u v],'BaseAngle',30,'length',10,'width',0.5,...
                'EdgeColor',vecColor(cc), ...
                'FaceColor',vecColor(cc));
            set( get(get(ARR,'Annotation'),'LegendInformation'),...
                'IconDisplayStyle','off');
            hold on;
        else
            ARR = arrow([xx yy],[u v],'BaseAngle',30,'length',10,'width',0.5,...
                'EdgeColor',[0.8 (cc-1)/numClusters (cc-1)/numClusters], ...
                'FaceColor',[0.8 (cc-1)/numClusters (cc-1)/numClusters]);
            set( get(get(ARR,'Annotation'),'LegendInformation'),...
                'IconDisplayStyle','off');
            hold on;
        end
    end
end

%% Plot camera's position
counter = 0;
magicFlag = 1;
for cc = 1:numClusters
    head = iFrames(cc);
    if cc <= length(vecColor)
        CAMPOS = plot(vecPosition(head,1),vecPosition(head,2), ...
            'MarkerFaceColor', vecColor(cc), ...
            'MarkerEdgeColor', vecColor(cc), ...
            'Marker', 's',...
            'LineStyle','none', ...
            'MarkerSize', 10, ...
            'DisplayName','I-frame camera');
        set( get(get(CAMPOS,'Annotation'),'LegendInformation'),...
                'IconDisplayStyle','off');
        %{
        if vecColor(cc) == 'k'
            set( get(get(CAMPOS,'Annotation'),'LegendInformation'),...
                'IconDisplayStyle','on');
        end
        %}
        text(vecPosition(head,1)+5.5,vecPosition(head,2)+5.5,num2str(head)); 
        hold on;
    else
        CAMPOS = plot(vecPosition(head,1),vecPosition(head,2), ...
            'MarkerFaceColor', [0.8 (cc-1)/numClusters (cc-1)/numClusters], ...
            'MarkerEdgeColor', [0.8 (cc-1)/numClusters (cc-1)/numClusters], ...
            'Marker', 's',...
            'LineStyle','none', ...
            'MarkerSize', 10, ...
            'DisplayName','I-frame camera');
        set( get(get(CAMPOS,'Annotation'),'LegendInformation'),...
                'IconDisplayStyle','off');
        text(vecPosition(head,1)+5.5,vecPosition(head,2)+5.5,num2str(head)); 
        hold on;
    end
    counter = counter + 1;
    
    members = find(vecRefStruc == head);
    for mm = 1:length(members)
        if members(mm) ~= head
            if cc <= length(vecColor)
                CAMPOS = plot(vecPosition(members(mm),1),vecPosition(members(mm),2), ...
                    'MarkerFaceColor', vecColor(cc), ...
                    'MarkerEdgeColor', vecColor(cc), ...
                    'Marker', 'o',...
                    'LineStyle','none', ...
                    'MarkerSize', 7.5, ...
                    'DisplayName','P-frame camera');
                set( get(get(CAMPOS,'Annotation'),'LegendInformation'),...
                    'IconDisplayStyle','off');
                %{
                if vecColor(cc) == 'k' && magicFlag == 1
                    set( get(get(CAMPOS,'Annotation'),'LegendInformation'),...
                        'IconDisplayStyle','on');
                    magicFlag = 0;
                end
                %}
                text(vecPosition(members(mm),1)+5.5,vecPosition(members(mm),2)+5.5,num2str(members(mm))); 
                hold on;
            else
                CAMPOS = plot(vecPosition(members(mm),1),vecPosition(members(mm),2), ...
                    'MarkerFaceColor', [0.8 (cc-1)/numClusters (cc-1)/numClusters], ...
                    'MarkerEdgeColor', [0.8 (cc-1)/numClusters (cc-1)/numClusters], ...
                    'Marker', 'o',...
                    'LineStyle','none', ...
                    'MarkerSize', 7.5, ...
                    'DisplayName','I-frame camera');
                set( get(get(CAMPOS,'Annotation'),'LegendInformation'),...
                    'IconDisplayStyle','off');
                text(vecPosition(members(mm),1)+5.5,vecPosition(members(mm),2)+5.5,num2str(members(mm))); 
                hold on;
            end
            counter = counter + 1;
        end
    end
end


%% Plot base station
plot(bsX,bsY,'^', ... 
    'MarkerSize',15, ...
    'MarkerFaceColor',[1 0.5 0.5],...
    'MarkerEdgeColor','k',...
    'DisplayName','Data aggregator',...
    'LineStyle','none');

CAMPOS = plot(inf,inf, ...
    'MarkerFaceColor', [1 0.5 0.5], ...
    'MarkerEdgeColor', 'k', ...
    'Marker', 's',...
    'LineStyle','none', ...
    'MarkerSize', 10, ...
    'DisplayName','P-frame camera');
set( get(get(CAMPOS,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','on');

CAMPOS = plot(inf,inf, ...
    'MarkerFaceColor', [1 0.5 0.5], ...
    'MarkerEdgeColor', 'k', ...
    'Marker', 'o',...
    'LineStyle','none', ...
    'MarkerSize', 7.5, ...
    'DisplayName','P-frame camera');
set( get(get(CAMPOS,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','on');

%% Set legend
%set(gca,'XTick',[]);
%set(gca,'YTick',[]);
%set(gca,'YColor','w');
%set(gca,'XColor','w');
%set(gca,'XTickLabel',['']);
%set(gca,'YTickLabel',['']);
axis([-radius*sqrt(2) radius*sqrt(2) -radius*sqrt(2) radius*sqrt(2)]);
grid on;
legend = legend('show');
set(legend,'FontSize',10,'Location','NorthEast');
hold off;