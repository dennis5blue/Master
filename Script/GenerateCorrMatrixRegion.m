function GenerateCorrMatrixRegion( r0X, r0Y, c0, c1 )
    %addpath('../SubME_1.6');
    % r0: which region of c0
    cam0 = str2num(c0);
    cam1 = str2num(c1);
    
    % For resolution 1280*720
    numX = 16;  numY = 9;
    
    targetCam.cam = cam0;
    targetCam.numX = numX;
    targetCam.numY = numY;
    targetCam.x = str2num(r0X);
    targetCam.y = str2num(r0Y);
    
    refCam = targetCam;
    refCam.cam = cam1;
    
    ifShow = 0;
    
    corrMatrix = GetCorrMatrixRegion(targetCam,refCam,ifShow);
    save(['./mat4/corrMatrix_' num2str(r0X) '_' num2str(r0Y) '_' num2str(c0) '_' num2str(c1) '.mat']);
end
