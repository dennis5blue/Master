function GenerateCorrMatrix( c0, c1 )
    %addpath('../SubME_1.6');

    cam0 = str2num(c0);
    cam1 = str2num(c1);
    
    % For resolution 1280*720
    numX = 16;  numY = 9;
    
    targetCam.cam = cam0;
    targetCam.numX = numX;
    targetCam.numY = numY;
    targetCam.x = 0;
    targetCam.y = 0;
    
    refCam = targetCam;
    refCam.cam = cam1;
    
    ifShow = 0;
    
    corrMatrix = GetCorrMatrix(targetCam,refCam,ifShow);
    save(['corrMatrix_' num2str(c0) '_' num2str(c1) '.mat']);
end
