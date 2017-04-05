function [ histogram ] = hog3d_cell( meangradientX, meangradientY, meangradientT, bin_num )
goldenRatio = 1.6180339887;
projectionThresholdDodecahedron = 0.44721359549995792770...
    *sqrt(1+goldenRatio*goldenRatio);
projectionThresholdIcosahedron = 0.74535599249992989801;
if bin_num==6
    projectionMatrix=zeros(3,6);
    projectionMatrix(1,1) = 0;
    projectionMatrix(2,1) = 1;
    projectionMatrix(3,1) = goldenRatio;
    
    projectionMatrix(1,2) = 0;
    projectionMatrix(2,2) = -1;
    projectionMatrix(3,2) = goldenRatio;
    
    projectionMatrix(1,3) = 1;
    projectionMatrix(2,3) = goldenRatio;
    projectionMatrix(3,3) = 0;
    
    projectionMatrix(1,4) = -1;
    projectionMatrix(2,4) = goldenRatio;
    projectionMatrix(3,4) = 0;
    
    projectionMatrix(1,5) = goldenRatio;
    projectionMatrix(2,5) = 0;
    projectionMatrix(3,5) = 1;
    
    projectionMatrix(1,6) = -goldenRatio;
    projectionMatrix(2,6) = 0;
    projectionMatrix(3,6) = 1;
elseif bin_num==10
    projectionMatrix(1,1) = 1;
    projectionMatrix(2,1) = 1;
    projectionMatrix(3,1) = 1;
    
    projectionMatrix(1,2) = -1;
    projectionMatrix(2,2) = -1;
    projectionMatrix(3,2) = 1;
    
    projectionMatrix(1,3) = -1;
    projectionMatrix(2,3) = 1;
    projectionMatrix(3,3) = 1;
    
    projectionMatrix(1,4) = 1;
    projectionMatrix(2,4) = -1;
    projectionMatrix(3,4) = 1;
    
    projectionMatrix(1,5) = 0;
    projectionMatrix(2,5) = 1/goldenRatio;
    projectionMatrix(3,5) = goldenRatio;
    
    projectionMatrix(1,6) = 0;
    projectionMatrix(2,6) = -1/goldenRatio;
    projectionMatrix(3,6) = goldenRatio;
    
    projectionMatrix(1,7) = 1/goldenRatio;
    projectionMatrix(2,7) = goldenRatio;
    projectionMatrix(3,7) = 0;
    
    projectionMatrix(1,8) = 1/goldenRatio;
    projectionMatrix(2,8) = -1*goldenRatio;
    projectionMatrix(3,8) = 0;
    
    projectionMatrix(1,9) = goldenRatio;
    projectionMatrix(2,9) = 0;
    projectionMatrix(3,9) = 1/goldenRatio;
    
    projectionMatrix(1,10) = -1*goldenRatio;
    projectionMatrix(2,10) = 0;
    projectionMatrix(3,10) = 1/goldenRatio;
end

project_6bins = projectionThresholdDodecahedron*sqrt(1+goldenRatio*goldenRatio);
%%

project_10bins = projectionThresholdIcosahedron*sqrt(3);


if bin_num==6
    for bins=1:6
        Qb2(bins) = (meangradientX*projectionMatrix(1,bins)...
            +meangradientY*projectionMatrix(2,bins)...
            +meangradientT*projectionMatrix(3,bins))...
            ./(sqrt(meangradientX*meangradientX+meangradientY*meangradientY+meangradientT*meangradientT)+(1e-7));
    end
    for bins =1:6
        if Qb2(bins) > project_6bins
            Qb2(bins) = Qb2(bins)-project_6bins;
        elseif Qb2(bins) < -project_6bins
            Qb2(bins) = -Qb2(bins)-project_6bins;
        else
            Qb2(bins) = 0;
        end
    end
    
    histogram = Qb2;
elseif bin_num==10
    for bins=1:10
        Qb2(bins) = (meangradientX*projectionMatrix(1,bins)...
            +meangradientY*projectionMatrix(2,bins)...
            +meangradientT*projectionMatrix(3,bins))...
            ./(sqrt(meangradientX*meangradientX+meangradientY*meangradientY+meangradientT*meangradientT)+(1e-7));
    end
    for bins =1:10
        if Qb2(bins) > project_10bins
            Qb2(bins) = Qb2(bins)-project_10bins;
        elseif Qb2(bins) < -project_10bins
            Qb2(bins) = -Qb2(bins)-project_10bins;
        else
            Qb2(bins) = 0;
        end
    end
    histogram = Qb2;
    
end






end

