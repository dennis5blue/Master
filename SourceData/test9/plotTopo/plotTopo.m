clear all;close all;
figure;

%% Parameters setting
vecDirection = dlmread('./dir.txt');
vecPosition = dlmread('./pos.txt');
numCams = 30;
radius = 250;
r = 50; % parameter for arrow.m

%% Plot camera's sensing direction
circle(0,0,radius*sqrt(2));
hold on;
for ii = 1:numCams
    xx = vecPosition(ii,1);
    yy = vecPosition(ii,2);
    theta = vecDirection(ii);
    u = xx + r * cos(theta); % convert polar (theta,r) to cartesian
    v = yy + r * sin(theta);
    ARR = arrow([xx yy],[u v],'BaseAngle',30,'length',10,'width',0.5,...
        'EdgeColor',[0 0 1],'FaceColor',[0 0 1]);
    set( get(get(ARR,'Annotation'),'LegendInformation'),...
        'IconDisplayStyle','off');
    hold on;
end

%% Plot camera's position
plot(vecPosition(:,1),vecPosition(:,2), ...
    'MarkerFaceColor', [0 0 0.5], ...
    'MarkerEdgeColor',[0 0 0.5], ...
    'Marker', 'o',...
    'LineStyle','none', ...
    'MarkerSize', 7.5, ...
    'DisplayName','Camera');
hold on;

%% Plot base station
plot(0,0,'^', ... 
    'MarkerSize',15, ...
    'MarkerFaceColor','r',...
    'MarkerEdgeColor','k',...
    'DisplayName','Data aggregator',...
    'LineStyle','none');

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
set(legend,'FontSize',10,'Location','SouthEast');
hold off;