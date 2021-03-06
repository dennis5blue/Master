function [ ans ] = FindMaxEntropyIncrease( Ns, candidates, corrMatrix, schedCams )
    temp = struct('cam',{},'increment',{});
    for i=1:length(candidates)
        temp(i).cam = candidates(i);
        temp(i).increment = CalIncreaseEntropy(candidates(i),corrMatrix,schedCams);
    end
    
    [values,index] = sort([temp.increment],'descend');  %# Sort all values, largest first
    if length(index) >= Ns
        ans = [temp(index(1:Ns)).cam]; % get the highest Ns ones 
    else
        ans = [temp(index(1:length(index))).cam]; % get all
    end
end

