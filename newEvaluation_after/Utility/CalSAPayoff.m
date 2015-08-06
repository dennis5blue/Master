function [ payoff ] = CalSAPayoff( ISelection, N, pos, bsX, bsY, rho, matCost )
    vecRefStructure = zeros(1,N);
    for i = 1:N
        if ismember(i,ISelection)
            vecRefStructure(i) = (i);
        else
            bestRef = i;
            for j = 1:length(ISelection)
                iCam = ISelection(j);
                if IfCanOverhear(pos(i,1),pos(i,2),pos(iCam,1),pos(iCam,2),bsX,bsY,rho) && matCost(i,iCam) <= matCost(i,bestRef)
                    bestRef = iCam;
                end
            end
            vecRefStructure(i) = bestRef;
        end
    end
	payoff = 0;
	for i = 1:N
        payoff = payoff + matCost(i,vecRefStructure(i));
	end
end

