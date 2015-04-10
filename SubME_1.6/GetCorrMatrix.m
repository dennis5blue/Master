function [corrMatrix] = GetCorrMatrix(c0, c1, numX, numY, ifShow)
    % c0 , c1: camera index; numX, numY: number of regions;
    % Parameters
    opts.BlockSize   = 4;
    opts.SearchLimit = 10;

    % Read image
    cam0 = ['imgs/camera_',num2str(c0),'.png'];
    cam1 = ['imgs/camera_',num2str(c1),'.png'];
    img0 = im2double(imread(cam0));
    img1 = im2double(imread(cam1));

    xSize = length(img0(:,1,1))/numX;
    ySize = length(img0(1,:,1))/numY;
    
    x0 = 1; y0 = 1; x1 = 1; y1 = 1;
    reg0 = img0((x0-1)*xSize+1:x0*xSize, (y0-1)*ySize+1:y0*ySize,:);
    reg1 = img1((x1-1)*xSize+1:x1*xSize, (y1-1)*ySize+1:y1*ySize,:);

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
