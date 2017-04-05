function [ para ] = my_0_5_getBBox_test( para )

% flexible of leg; auto temporal
stepN = 0;
para.dir.saveBBoxFile = [para.dir.saveBBoxes '\BBox-flx.mat'];
para.saveBBoxFlag = true;

if exist(para.dir.saveBBoxFile,'file')
	temp = load(para.dir.saveBBoxFile);
	para.BBoxes = temp.para.BBoxes;
else
    BBoxes = cell(0);
    loaddir = para.dir.loadSequences;
    dlist = my_dir(loaddir);
    for d = 1:length(dlist)
        ddlist = my_dir(dlist{d});
        for dd = 1:length(ddlist)
            imgdir = ddlist{dd};

imglist = my_dir(imgdir);

if para.fv.usePart_pos<=1
    BBox = [];
elseif para.fv.usePart_pos==2
    BBox = zeros(length(imglist), 4*8); % TBD
elseif para.fv.usePart_pos==3
    BBox = zeros(length(imglist), 4*6);
    index = para.indexes{d, dd};
    breakFlag = false;
    if isempty(index)
        breakFlag = true;
    end
    if ~breakFlag
    
    part_pos1 = [...
        23  4 43 24;...
        6 24 33 70;...
        20 24 46 70;...
        33 24 59 70;...
        6 71 32 124;...
        33 71 59 124]';
    part_pos2 = [...
        23  4 43 24;...
        6 24 33 70;...
        20 24 46 70;...
        33 24 59 70;...
        20 71 46 124;...
        20 71 46 124]';
    
    BBox(abs(index(sign(index)>0)),:) = repmat(part_pos1(:)',sum(sign(index)>0),1);
    BBox(abs(index(sign(index)<0)),:) = repmat(part_pos2(:)',sum(sign(index)<0),1);
    indexAbs = abs(index);
    for i=indexAbs(1):indexAbs(end)
        if any(indexAbs==i); continue; end
        i1 = max(indexAbs(indexAbs<i));
        i2 = min(indexAbs(indexAbs>i));
        if ~stepN
            stepW = (i2-i)/(i2-i1);
        else
            stepW = floor((i2-i)/(i2-i1)*stepN)/(stepN-1);
        end
        BBox(i,:) = BBox(i1,:)*stepW + BBox(i2,:)*(1-stepW);
    end
    end
end

BBoxes{d,dd} = BBox;   

progress('Calculate Body-Action BBox', (d-1)*length(ddlist)+dd, length(dlist)*length(ddlist));
         end
    end
    
    para.BBoxes = BBoxes;
    if para.saveBBoxFlag
        if ~exist(para.dir.saveBBoxes, 'dir'); my_mkdir(para.dir.saveBBoxes); end;
        save(para.dir.saveBBoxFile, 'para');
    end
end

end

