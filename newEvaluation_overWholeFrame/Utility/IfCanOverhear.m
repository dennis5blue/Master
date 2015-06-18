function [ ans ] = IfCanOverhear( x1,y1,x2,y2,bsX,bsY,rho )
    % check if (x1,y1) can overhear (x2,y2)
    ans = -1;
    d1 = sqrt((x2-x1)^2 + (y2-y1)^2);
    d2 = sqrt((x2-bsX)^2 + (y2-bsY)^2);
    if d1 <= d2*rho
        ans = 1;
    else
        ans = 0;
    end
end

