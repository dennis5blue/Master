function [ profit ] = CalProfit( next, sched, unsched, numCams, reg )
    % next: next camera to schedule
    %sched = sched(1:length(sched)-1); % remove last element since it is -1
    profit = 0;
    for i = 1:length(unsched)
        cam = unsched(i);
        if cam ~= next
            %disp(['Reconstruct view ' num2str(cam) ' by view ' num2str(next) ': ']);
            corrMatrix = load(['../Script/mat/corrMatrix_' num2str(cam) '_' num2str(next) '.mat'],'corrMatrix');
            corrMatrix = corrMatrix.corrMatrix;
            for j = 1:length(sched)
                % if a region can be reconstruct from previous scheduled views, then we set the value to zero
                schedCam = sched(j);
                %disp(['Reconstruct view ' num2str(cam) ' by view ' num2str(schedCam) ': ']);
                tempCorrMat = load(['../Script/mat/corrMatrix_' num2str(cam) '_' num2str(schedCam) '.mat'],'corrMatrix');
                tempCorrMat = tempCorrMat.corrMatrix;
                corrMatrix = corrMatrix - tempCorrMat;
                corrMatrix(corrMatrix<0) = 0;
            end
            profit = profit + length(find(corrMatrix==1));
        end
    end
end

