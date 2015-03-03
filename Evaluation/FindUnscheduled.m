function [ unschedule ] = FindUnscheduled( numCam, sched )
    ans = [];
    for i=1:numCam
        isSched = 0;
        for j=1:length(sched)
            if i==sched(j)
                isSched = 1;
            end
        end
        if isSched == 0
            ans = [ans i];
        end
    end
    unschedule = ans;
end

