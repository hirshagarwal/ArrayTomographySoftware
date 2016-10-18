[FileName,PathName] = uigetfile('*.jpg','Select The Flattened Image');
flattenedPath = strcat(PathName, FileName);
disp(flattenedPath);
%Read whole image
clc;
close all;
disp(FileName);
impath = flattenedPath;
flattened = imread(impath);
figure;
imshow(flattened);

%Get Image Stats
imM = size(flattened, 1); %Image Rows
imN = size(flattened, 2); %Image Cols

%Superimpose Grid
gridSize = 100;

    %Display Grid
    hold on;
    for k = 1:gridSize:imM
        x = [1 imN];
        y = [k k];
        plot(x,y,'Color', 'w', 'LineStyle', '-');
        plot(x,y,'Color', 'k', 'LineStyle', ':');
    end

    for k = 1:gridSize:imN
        x = [k, k];
        y = [1, imM];
        plot(x, y, 'Color', 'w', 'LineStyle', '-');
        plot(x, y, 'Color', 'k', 'LineStyle', ':');
    end
    hold off;

%Filter Out Crops
cropsM = 1300/gridSize;
cropsN = 1000/gridSize;


weights = zeros(cropsN, cropsM);
disp('Analysing Images...');
%set(handles.statusText, 'string', 'Analysing Images...');
figure;

for i = 1:1:(cropsN)
    for j = 1:1:(cropsM)
        currentCropNum = [i, j]; %Choose a crop
        currentCropPix = [100*currentCropNum(1)-99, 100*currentCropNum(1); 100*currentCropNum(2)-99, 100*currentCropNum(2)];
            %Current Crop Pix [startX, endX; startY, endY]
        %Select the current crop
        currentCrop = flattened(currentCropPix(1, 1):currentCropPix(1,2), currentCropPix(2,1):currentCropPix(2,2), :);
            %Run Filter on current crop
                %Analyse each layer
                hWeight = 0;
            for k = 1:1:3
                %Show the crop
                    currentText = strcat(num2str(i),', ', num2str(j), ', ', num2str(k));
                    %set(handles.currentIm, 'string', currentText);
                    imshow(currentCrop(:,:,k));
                    drawnow;
                %Weigh the crop
                weight = weigh(currentCrop(:,:,k));
                if weight>hWeight
                    hWeight = weight;
                end
            end
            weight = hWeight;
            weights(i, j) = weight;
            
    end 
end
imshow(weights);
cropped = flattened;

disp('Removing All Bad Crops');
%set(handles.statusText, 'string', 'Removing Bad Crops');
%Remove Bad Crops
cropList = [];
for i = 1:1:size(weights, 1)
    for j = 1:1:size(weights, 2)        
        if weights(i,j) >= 4
            remove = [(i*100)-99, (i*100); (j*100)-99, (j*100)];
            cropped(remove(1,1):remove(1,2),remove(2,1):remove(2,2), :) = 100;
        else
            coordinates = strcat(num2str(i),', ' ,num2str(j));
            cropList = [cropList; [i, j]];
        end
    end
end

blackFlattened = flattened;
%Run Through Black Filter
finalList = []
for i = 1:1:size(cropList, 1)
    pixels = cropList(i, :);
    subsample = blackFlattened(pixels(1)*100-99:pixels(1)*100,pixels(2)*100-99:pixels(2)* 100, :);
    imshow(subsample);
    weight = darkFilter(subsample);
    if weight < 10
        finalList = [finalList; pixels];
    end
end

% Build crops from final image


%Remove Edges
cropped(end-50:end, :, :) = 0;
%set(handles.statusText, 'string', 'Done');
%imshow(cropped);
  %TODO Weight black spots as well as white spot
  
  %Remove edges
  edgedArray = finalList;
  finalList = [];
  for i=1:1:size(edgedArray)
      currentItem = edgedArray(i, 1);
      if edgedArray(i, 1) ~= 1 && edgedArray(i, 1) ~= 10 && edgedArray(i, 2) ~= 13
          finalList = [finalList; edgedArray(i, :)];
      end
  end
  
%Generate Tensor of Good Crops
finalImage = flattened;
cropTensor = [];
%figure;

path = uigetdir('');

for i = 1:1:size(finalList)
    currentCrop = finalList(i, :);
    x = (currentCrop(1)-1)*100;
    y = (currentCrop(2)-1)*100;
    crop = finalImage(x+1:x+100, y+1:y+100, :);
    cropTensor = [cropTensor, crop];
    filePath = strcat(path, '\crop');
    filePath = strcat(filePath, num2str(i));
    filePath = strcat(filePath, '.tif');
    imwrite(crop, filePath);
    imshow(cropTensor);
end
