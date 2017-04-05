function [ para ] = my_0_4_getIndex_test( para )

para.dir.saveOfImgs = [para.dir.saveIndexes '\Imgs'];
para.dir.saveOfEnergy = [para.dir.saveIndexes '\Energy'];
para.dir.saveOfResults = [para.dir.saveIndexes '\test' para.dir.testIndexN '\Results'];
para.dir.saveOfIndex = [para.dir.saveIndexes '\test' para.dir.testIndexN '\Indexes'];
para.dir.saveOfPictures = [para.dir.saveIndexes '\test' para.dir.testIndexN '\Pictures'];
para.dir.saveOfPR = [para.dir.saveIndexes '\test' para.dir.testIndexN '\PR'];
para.dir.saveOfIndexFile = [para.dir.saveOfIndex '\indexes.mat'];

orientations = [];
indexes = [];
indexValues = [];
indexValues2 = [];
indexValues3 = [];
indexValues4 = [];

if exist(para.dir.saveOfIndexFile,'file')
	temp = load(para.dir.saveOfIndexFile);
	para.indexes = temp.para.indexes;
	para.indexValues = temp.para.indexValues;
	para.orientations = temp.para.orientations;
	
else
	
loaddir = para.dir.loadSequences;
dlist = dir(loaddir);
for d = 3:length(dlist)
	cam_id = dlist(d).name(end);
	ddlist = dir([loaddir '\' dlist(d).name]);
	for dd = 3:(para.sampleN+2)

        [~, dataset] = fileparts(para.dir.root);
        if strcmp(dataset,'i-LIDS-VID') || strcmp(dataset,'prid_2011')
            per_id = ddlist(dd).name(end-2:end);
        else
            nameList = regexp(ddlist(dd).name, '_', 'split');
            per_id = ddlist(dd).name(end-2:end);
            for i=2:length(nameList)
                if strcmpi(nameList{i}(1), 'R')
                    per_id = nameList{i}(2:end);
                    break
                end
            end
        end
		imgdir = [loaddir '\' dlist(d).name '\' ddlist(dd).name];

% load image sequence
imglist = dir(imgdir);
imgs = [];
ii = 1;
for i = 3:length(imglist)
	img = imread([imgdir '\' imglist(i).name]);
	imgs = cat(4, imgs, img);
	ii = ii + 1;
end

GaussionSize = [5];
for i = 1:length(GaussionSize)
para.of.GaussionSize = GaussionSize(i);

para        = fun_0_5_ofFiles(para, cam_id, per_id);
[E, vxMean] = fun_1_ofProcess(imgs, para);
[index, E_g_filt, E_f_filt, indexabs, indexG, indexGabs, indexV, indexVabs] = fun_2_ofFilter(E, para);
[indexValue, indexValue2, indexValue3, indexValue4] = fun_3_ofValues(index, E_g_filt, E_f_filt, para.of.maxR, indexV);

fname = ['Index' para.files.indexName];

showFlag = false;

if showFlag
    figure(i); clf(i);	hold on; xlim([0, length(E)]);
    % plot(E,'g');
    plot(E_g_filt, '-b');
    plot(indexGabs,interp1(1:length(E_g_filt),E_g_filt,indexGabs),'b.',...
        'LineWidth',5,...
        'MarkerSize',20);	% evaluate
    plot(E_f_filt,'-r');
    
    % plot indexValue
    for j=1:length(index)-2
        indexB = indexabs(j);
        indexE = indexabs(j+2);
        if indexValue(2,j) == -1
            plot(indexB:indexE,E_f_filt(indexB:indexE),'-g');
        end
    end
    
    plot(indexabs,interp1(1:length(E_f_filt),E_f_filt,indexabs),'r.',...
        'LineWidth',5,...
        'MarkerSize',20);	% evaluate
    
    figure(i+10);
    Img = [];
    rowN = 4;	% 4
    if ~isempty(index) && index(1) >= 0
        startN = 1;
    else
        startN = 0;
    end
    allN = ceil((length(indexabs)-startN+1)/rowN)*rowN;
    endN = allN+startN-1;
    for j = startN:rowN:endN
        imgTemp = [];
        for jj = 1:rowN
            drawN = j+jj-1;
            if drawN==0 || drawN>length(indexabs)
                imgTemp = cat(1, imgTemp, zeros(size(imgs(:,:,:,1))));
            else
                imgTemp = cat(1, imgTemp, imgs(:,:,:,indexabs(j+jj-1)));
            end
        end
        Img = cat(2, Img, imgTemp);
    end
    imshow(Img);
    
    figure(i+20); clf(i+20);
    subplot(2,1,1);
    Img = [];
    rowN = 1;	% 4
    startN = 1;
    allN = ceil((length(indexabs)-startN+1)/rowN)*rowN;
    endN = allN+startN-1;
    for j = startN:rowN:endN
        imgTemp = [];
        for jj = 1:rowN
            drawN = j+jj-1;
            if drawN==0 || drawN>length(indexabs)
                imgTemp = cat(1, imgTemp, zeros(size(imgs(:,:,:,1))));
            else
                imgTemp = cat(1, imgTemp, imgs(:,:,:,indexabs(j+jj-1)));
            end
        end
        Img = cat(2, Img, imgTemp);
    end
    set(gca,'Position',[0.02 0.7 0.96 0.25]);
    imshow(Img);
    
    subplot(2,1,2);
    set(gca,'Position',[.05 .05 .9 .6]);
    hold on; xlim([0, length(E)]); grid on;
    % plot(E,'g');
    plot(E_g_filt, '-b');
    plot(indexGabs,interp1(1:length(E_g_filt),E_g_filt,indexGabs),'b.',...
        'LineWidth',5,...
        'MarkerSize',20);	% evaluate
    plot(E_f_filt,'-r');
    for j=1:length(index)-2
        indexB = indexabs(j);
        indexE = indexabs(j+2);
        if indexValue(2,j) == -1
            plot(indexB:indexE,E_f_filt(indexB:indexE),'-g');
        end
    end
    plot(indexabs,interp1(1:length(E_f_filt),E_f_filt,indexabs),'r.',...
        'LineWidth',5,...
        'MarkerSize',20);	% evaluate
    
    if size(indexValue,1)>=2
        % plot indexValue
        temp1 = indexValue(2,1:end-1);
        rate = (max(E_g_filt)-min(E_g_filt))/(max(temp1)-min(temp1));
        plot(indexabs(2:end-1),(temp1-min(temp1))*rate+min(E_g_filt),'y.','MarkerSize',20);
        
        % plot indexValue2
        temp2 = indexValue2(2,1:end-1);
        rate = (max(E_g_filt)-min(E_g_filt))/(max(temp2)-min(temp2));
        plot(indexabs(2:end-1),(temp2-min(temp2))*rate+min(E_g_filt),'g.','MarkerSize',20);
        
        % plot indexValue3
        temp2 = indexValue3(2,1:end-1);
        rate = (max(E_g_filt)-min(E_g_filt))/(max(temp2)-min(temp2));
        plot(indexabs(2:end-1),(temp2-min(temp2))*rate+min(E_g_filt),'c.','MarkerSize',20);
        
        % plot indexValue4
        temp2 = indexValue4(2,1:end-1);
        rate = (max(E_g_filt)-min(E_g_filt))/(max(temp2)-min(temp2));
        plot(indexabs(2:end-1),(temp2-min(temp2))*rate+min(E_g_filt),'m.','MarkerSize',20);
    end
end

indexes{d-2, dd-2} = index;
indexValues{d-2, dd-2} = indexValue;
indexValues2{d-2, dd-2} = indexValue2;
indexValues3{d-2, dd-2} = indexValue3;
indexValues4{d-2, dd-2} = indexValue4;
orientations{d-2, dd-2} = vxMean;	% -1:r; 1:l

progress('Extract walking cycles', dd-2, para.sampleN );

end

if para.saveIndexFlag
	my_mkdir(para.dir.saveOfIndex);
	my_mkdir(para.dir.saveOfResults);
	my_mkdir(para.dir.saveOfPictures);
	my_mkdir(para.dir.saveOfPR);
	save([para.dir.saveOfIndex '\' fname '.mat'],...
		'para', 'E', 'index', 'E_g_filt', 'E_f_filt', 'indexValue');
    if showFlag
        saveas(i,[para.dir.saveOfResults '\OfShows' fname '.bmp'],'bmp');
        saveas(i+10,[para.dir.saveOfPictures '\FragShows' fname '.bmp'],'bmp');
        saveas(i+20,[para.dir.saveOfPR '\PRShows' fname '.bmp'],'bmp');
    end
end

	end
end

para.indexes = indexes;
para.indexValues = indexValues;
para.indexValues2 = indexValues2;
para.indexValues3 = indexValues3;
para.indexValues4 = indexValues4;
para.orientations = orientations;
if para.saveIndexFlag
	my_mkdir(para.dir.saveOfIndex);
	save([para.dir.saveOfIndex '\indexes.mat'], 'para');
end

end

end
