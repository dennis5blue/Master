function [ ans ] = CalIncreaseEntropy( cam, corrMatrix, sched )
    ans = corrMatrix(cam,sched(1));
    for i=2:length(sched)
        if corrMatrix(cam,sched(i)) < ans
            ans = corrMatrix(cam,sched(i));
        end
    end
end

