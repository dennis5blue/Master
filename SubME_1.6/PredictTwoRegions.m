function [PSNR] = PredictTwoRegions(camOpts0, camOpts1, ifShow)
    % camOpts requirments: (cam, numX, numY, x, y)
    % Parameters
    opts.BlockSize   = 4;
    opts.SearchLimit = 10;
    
    % Read image
    cam0 = ['imgs4/camera_',num2str(camOpts0.cam),'.png'];
    img0 = im2double(imread(cam0));
    cam1 = ['imgs4/camera_',num2str(camOpts1.cam),'.png'];
    img1 = im2double(imread(cam1));
    xSize = length(img0(1,:,1))/camOpts0.numX;
    ySize = length(img0(:,1,1))/camOpts0.numY;
    
    % Set target refernece region
    x0 = camOpts0.x; y0 = camOpts0.y;
    x1 = camOpts1.x; y1 = camOpts1.y;
    reg0 = img0((y0-1)*ySize+1:y0*ySize,(x0-1)*xSize+1:x0*xSize,:);
    reg1 = img1((y1-1)*ySize+1:y1*ySize,(x1-1)*xSize+1:x1*xSize,:);
    
    % Motion estimation
    [MVx, MVy] = Bidirectional_ME(reg0, reg1, opts);

    % Motion Compensation
    regMC = reconstruct(reg0, MVx, MVy, 0.5);

    % Evaluation
    [M N C] = size(regMC);
    Res  = regMC-reg1(1:M, 1:N, 1:C);
    MSE  = norm(Res(:), 'fro')^2/numel(regMC);
    PSNR = 10*log10(max(regMC(:))^2/MSE);
                
    % Show results
    if ifShow == 1
        figure(1);
        subplot(221);
        imshow(reg0); title('img_0');

        subplot(222);
        imshow(reg1); title('img_1');

        subplot(223);
        imshow(regMC); title('img_M');

        subplot(224); 
        T = sprintf('img_M - img_1, PSNR %3g dB', PSNR);
        imshow(rgb2gray(regMC)-rgb2gray(reg1(1:M, 1:N, :)), []); title(T);
    end
end
