function y = outputCrops(handles)
    axes(handles.secondFigure);
    % Parse the crop list
    cropListString = get(handles.cropsText, 'String');
    startNum = str2num(get(handles.startNumText, 'String'));
    cropTuples = strsplit(cropListString, ';');
    cropList = [];
    for i=1:1:size(cropTuples, 2)-1
        currentCropString = cropTuples(i);
        xyString = strsplit(cell2mat(currentCropString), ',');
        xString = cell2mat(xyString(1));
        yString = cell2mat(xyString(2));
        xVal = str2num(xString(2:end));
        yVal = str2num(yString(1:end-1));
        cropList = [cropList; xVal,yVal];
    end

    % The crop list can now be used to generate crops
    
    % Get the number of files to crop
    %numFiles = str2num(get(handles.cropNum, 'String'));
    
    [FileName, PathName, FilterIndex] = uigetfile('*.tif*', 'Select images to crop');
    %numFiles = size(FileName, 2);
    outPath = uigetdir('Select Output Location');
    set(handles.infoText, 'string', 'Working...');
    currentImageNum = startNum;
    %for i=1:1:numFiles
        curFile = FileName;
        impath = strcat(PathName, curFile);
        %curFile = cell2mat(curFile);
        curFile = curFile(1:end-4);
        info = imfinfo(impath);
        num_images = numel(info);
        for j=1:1:size(cropList, 1)
            for k=1:1:num_images
                image = imread(impath, k);
                cropPixels = [(cropList(j, 1)*100)-99, cropList(j, 1)*100; (cropList(j, 2)*100)-99, cropList(j, 2)*100];
                crop = image(cropPixels(1,1):cropPixels(1,2), cropPixels(2,1):cropPixels(2,2));
                % Save the crop 
                
                imshow(crop);
                drawnow;
                outputPath = strcat(outPath, '\crop', num2str(currentImageNum),'.tif');
                imshow(crop);
                imwrite(crop, outputPath, 'writemode', 'append');
            end
            currentImageNum = currentImageNum + 1;
        end
   % end
    
    set(handles.infoText, 'string', 'Done');
    disp('Cropping Complete');
    filename = 'Crop Data.xlsx';
    xlData = {'Crop', 'Case', 'Block', 'Image', 'Notes'};
    
    for i=startNum:1:num_images
        xlData = {xlData; i, '', '', '', ''};
    end
    
    xlswrite(filename,A);
end