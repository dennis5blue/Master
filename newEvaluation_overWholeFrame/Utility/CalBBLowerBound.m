function [ lb ] = CalBBLowerBound( matRoute, matCost )
    % matRoute(i,j) = 1 means path i->j must be selected
    % matRoute(i,j) = -1 means path i->j cannot be selected
    % matRoute(i,j) = 0 means whether path i->j is selected or not is possible
    lb = 0;
    N = length(matCost(1,:));
    rowRemove = [];
    colRemove = [];
    for i = 1:N
        camUnSelect = find(matRoute(i,:) == -1);
        matCost(camUnSelect) = inf;
        camSelect = find(matRoute(i,:) == 1);
        if length(camSelect)>1
            disp('Error!! Pass a node multiple times!!');
        elseif length(camSelect) == 1
            lb = lb + matCost(i,camSelect);
            rowRemove = [rowRemove i];
            colRemove = [colRemove camSelect];
        end
    end

    % reduce cost matrix
    matCost(rowRemove,:) = [];
    matCost(:,colRemove) = [];

    % check if matCost is still a square matrix 
    if length(matCost(1,:)) ~= length(matCost(:,1))
        disp('Error!! matCost is not a square matrix');
    end

    for i = 1:length(matCost(1,:))
        lb = lb + min(matCost(i,:));
        matCost(i,:) = matCost(i,:) - min(matCost(i,:))*ones(1,length(matCost(1,:)));
    end
    for i = 1:length(matCost(1,:))
        lb = lb + min(matCost(:,i));
        matCost(:,i) = matCost(:,i) - min(matCost(:,i))*ones(length(matCost(1,:)),1);
    end
end

