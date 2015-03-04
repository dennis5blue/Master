function [ ans ] = GetSumEntropy( camsVec, H )
    ans = 0;
    for i=1:length(camsVec)
        ans = ans + H(1).indep(camsVec(i));
    end
end


