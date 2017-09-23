function y = Crop(flatPath, handles)
    clc;
    % Get the file path
    disp(flatPath);
    % Setup the figure
    axes(handles.mainFigure);
   
    % Read the image
    flattened = imread(flatPath);
    
     % Filter Out Edges
        % TODO Make this method more intelligent
    cropX = size(flattened, 1);    
    cropY = size(flattened, 2);
    sizeX = floor(cropX/100)*100;
    sizeY = floor(cropY/100)*100;
    offset = 100;
    % Sets the size of the matrix that will hold all of the crops
    cropsN = sizeX/100;
    cropsM = sizeY/100;
    
    %flattened = flattened(101:sizeX - (100), 101:sizeY-(100), :);
    display(size(flattened, 2));
    flattened = flattened(1:sizeX+1, 1:sizeY+1, :);
    % Show the base image
    imshow(flattened);
    
    %Get Image Stats
    imM = size(flattened, 1); % Image Rows
    imN = size(flattened, 2); % Image Cols
    
        % Superimpose Grid
    gridSize = round(imM/10, -2);
    
    % Display Grid
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
    
    % Set the figure to the alternate one
    axes(handles.secondFigure);
    
    % Create the matrix to hold the weights
    weights = zeros(cropsN, cropsM); % For the weights of light areas
    darkWeights = zeros(cropsN, cropsM); % For the weights of dark areas
    % TODO: Display analysing images text (and progress?)
    
for i = 1:1:(cropsN) % Will iterate through the height of the image
    for j = 1:1:(cropsM) % Will iterate through the width of the image
        currentCropNum = [i, j]; % Select the current crop
        % Choose pixels for the current crop
        currentCropPix = [100*currentCropNum(1)-99, 100*currentCropNum(1); 100*currentCropNum(2)-99, 100*currentCropNum(2)];
        display(currentCropPix);
        currentCrop = flattened(currentCropPix(1,1):currentCropPix(1,2), currentCropPix(2,1):currentCropPix(2,2), :);
        % Run filter on current crop
            hWeight = 0; % This is the highest weight of the three crops layers
            for k = 1:1:3 % Run through each of the 3 layers of the image
                % Weight the current crop
                weight = weigh(currentCrop(:,:,k));
                % Show the crop
                imshow(currentCrop(:,:,:));
                drawnow;
                if weight>hWeight
                    hWeight = weight;
                end
            end
            darkWeight = darkFilter(currentCrop(:, :, :)); % Weigh the darkness
            weights(i, j) = hWeight; % Set the weight in the matrix to the highest weight    
            darkWeights(i, j) = darkWeight;
                
    end
end

imshow(weights);
cropped = flattened; % Get the base image to edit
% Show an image without the bad crops
cropList = [];
for i = 1:1:size(weights, 1)
    for j = 1:1:size(weights, 2)
        currentCrop = cropped((i*100)-99:(i*100), ((j*100)-99):(j*100), :);
        if weights(i,j) >=4 || darkWeights(i, j) > 10
            darkWeight = darkWeights(i,j);
            lightWeight = weights(i, j);
            remove = [(i*100)-99, (i*100); (j*100)-99, (j*100)];
            imshow(currentCrop);
            cropped(remove(1,1):remove(1,2), remove(2,1):remove(2,2), :) = 0;
        else
            coordinates = strcat(num2str(i), ', ', num2str(j));
            cropList = [cropList; [i, j]];
        end
    end
end

% Overlay grid

imshow(cropped);

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
    
% Generate string list of crops
cropListString = '';
for i = 1:1:size(cropList, 1)
    if cropList(i, 1) > 1 && cropList(i, 2) < cropsM
      cropListString = strcat(cropListString, '(',num2str(cropList(i, 1)),',',num2str(cropList(i, 2)), ');');
    end
end
% Output the list of crops    
set(handles.cropsText, 'string', cropListString);

end
