function [ prevCanHearCams ] = FindCanHearCamsSet( targetCam, iCam, vecRefCam, GOP, prevCams, pos, bsX, bsY, rho )
    % Find the set of cameras that targetCam can overhear from prevCams
    vecIfCanHear = zeros(1,length(prevCams));
    for kk = 1:length(prevCams)
        camCheck = prevCams(length(prevCams)-kk+1); % check from back to front
        % check if pCam can overhear camCheck
        if IfCanOverhear( pos(targetCam,1),pos(targetCam,2),pos(camCheck,1),pos(camCheck,2),bsX,bsY,rho ) == 1
            hearFlag = 1;
            while camCheck ~= iCam
                if camCheck == vecRefCam(find(GOP.pFrames==camCheck))
                    break;
                else
                    camCheck = vecRefCam(find(GOP.pFrames==camCheck));
                    hearFlag = IfCanOverhear( pos(targetCam,1),pos(targetCam,2),pos(camCheck,1),pos(camCheck,2),bsX,bsY,rho );
                end
            end
        elseif IfCanOverhear( pos(targetCam,1),pos(targetCam,2),pos(camCheck,1),pos(camCheck,2),bsX,bsY,rho ) == 0
            hearFlag = 0;
        end
        vecIfCanHear(length(prevCams)-kk+1) = hearFlag;
    end
    prevCanHearCams = prevCams(find(vecIfCanHear==1));
    prevCanHearCams = [prevCanHearCams targetCam];
end

