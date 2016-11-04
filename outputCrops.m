function y = outputCrops(handles)

    % Parse the crop list
    cropListString = get(handles.cropsText, 'String');
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
    
    [FileName, PathName, FilterIndex] = uigetfile('*.tif*', 'Select images to crop', 'MultiSelect', 'on');
    numFiles = size(FileName, 2);
    outPath = uigetdir('Select Output Location');
    for i=1:1:numFiles
        curFile = FileName(i);
        impath = cell2mat(strcat(PathName, curFile));
        image = imread(impath);
        for j=1:1:size(cropList, 1)
            cropPixels = [(cropList(j, 1)*100)-99, cropList(2)*100; (cropList(j, 2)*100)-99, cropList(2)*100];
            crop = image(cropPixels(1,1):cropPixels(1,2), cropPixels(2,1):cropPixels(2,2));
            % Save the crop 
        end
    end
    
end