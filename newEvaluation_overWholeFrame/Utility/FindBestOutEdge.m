function [ vecBestOutEdge ] = FindBestOutEdge( vecAdjGraph,matCost )
    % find the outEdge with minimum cost (i.e. best reference camera)
    N = length(vecAdjGraph);
    vecBestOutEdge = zeros(1,N);
    for cam = 1:N
        m_node = vecAdjGraph(cam);
        m_outEdge = m_node.outEdge;
        bestRef = 0;
        bestCost = inf;
        for i = 1:length(m_outEdge)
            refCam = m_outEdge(i);
            if matCost(cam,refCam) < bestCost
                bestCost = matCost(cam,refCam);
                bestRef = refCam;
            end
        end
        vecBestOutEdge(cam) = bestRef;
    end
end

