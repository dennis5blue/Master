function [ lb ] = CalBBLowerBound2( route, matCost )
    lb = 0;
    N = length(matCost(1,:));
    rowRemove = [];
    colRemove = [];
    if length(route) > 1
        for i = 2:length(route)
            cam = route(i-1);
            next = route(i);
            lb = lb + matCost(cam,next);
            rowRemove = [rowRemove cam];
            colRemove = [colRemove next];
        end
        % reduce cost matrix
        matCost(rowRemove,:) = [];
        matCost(:,colRemove) = [];
    end

    % check if matCost is still a square matrix 
    if length(matCost(1,:)) ~= length(matCost(:,1))
        disp('Error!! matCost is not a square matrix');
    end

    temp = [];
    for i = 1:length(matCost(1,:))
        temp = [temp min(matCost(i,:))];
    end
    temp = sort(temp,'ascend');
    for i = 1:length(temp)-1
        lb = lb + temp(i);
    end
end

