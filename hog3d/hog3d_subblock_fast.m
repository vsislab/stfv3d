function [ histogram_subblock ] = hog3d_subblock_fast( subblock, bin_num )

[l,m,n] = size(subblock);
[projectionMatrix,project_6bins]=ComputeprojectionMatrix();
subblock=double(subblock);
[meangradientX,meangradientY,meangradientT]=gradient(subblock);

Qb2=zeros(l,m,n,bin_num);

if bin_num==6
    for bins=1:6
        Qb2(:,:,:,bins) = (meangradientX*projectionMatrix(1,bins)...
            +meangradientY*projectionMatrix(2,bins)...
            +meangradientT*projectionMatrix(3,bins))...
            ./(sqrt(meangradientX.*meangradientX+meangradientY.*meangradientY+meangradientT.*meangradientT)+(1e-7));
    end
    idx_positive=Qb2 > project_6bins;
    idx_negative=Qb2 <-project_6bins;
    idx_zero=(Qb2 <= project_6bins) & (Qb2 >=-project_6bins);
    
    Qb2(idx_positive)=Qb2(idx_positive)-project_6bins;
    Qb2(idx_negative)=-Qb2(idx_negative)-project_6bins;
    Qb2(idx_zero)    = 0;
    
    
    
elseif bin_num==10
    for bins=1:10
        Qb2(:,:,:,bins) = (meangradientX*projectionMatrix(1,bins)...
            +meangradientY*projectionMatrix(2,bins)...
            +meangradientT*projectionMatrix(3,bins))...
            ./(sqrt(meangradientX.*meangradientX+meangradientY.*meangradientY+meangradientT.*meangradientT)+(1e-7));
    end
    idx_positive=Qb2 > project_6bins;
    idx_negative=Qb2 <-project_6bins;
    idx_zero=(Qb2 <= project_6bins) & (Qb2 >=-project_6bins);
    
    Qb2(idx_positive)=Qb2(idx_positive)-project_6bins;
    Qb2(idx_negative)=-Qb2(idx_negative)-project_6bins;
    Qb2(idx_zero)    = 0;
    
end
histogram_subblock=zeros(1,bin_num);
for i=1:bin_num
    temp=sum(sum(sum(Qb2)));
    histogram_subblock(i) =temp(1,1,1,i);
end
histogram_subblock=histogram_subblock./(l*m*n);
histogram_subblock=histogram_subblock.*8;
end



