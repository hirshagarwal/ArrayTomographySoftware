function y = Crop(flatPath, handles)
    clc;
    % Get the file path
    disp(flatPath);
    % Setup the figure
    axes(handles.mainFigure);
    
    % Read the image
    flattened = imread(flatPath);
    
    % Show the base image
    imshow(flattened);
    
    %Get Image Stats
    imM = size(flattened, 1); % Image Rows
    imN = size(flattened, 2); % Image Cols
    
    % Superimpose Grid
    gridSize = round(imM/10, -2);
    
    % Display Grid
    hold on;
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
    
    % Filter Out Edges
        % TODO Make this method more intelligent
    % Sets the size of the matrix that will hold all of the crops
    cropsM = 1300/gridSize;
    cropsN = 1000/gridSize;
    
    % Create the matrix to hold the weights
    weights = zeros(cropsN, cropsM); % For the weights of light areas
    darkWeights = zeros(cropsN, cropsM); % For the weights of dark areas
    % TODO: Display analysing images text (and progress?)
    
for i = 1:1:(cropsN) % Will iterate through the height of the image
    for j = 1:1:(cropsM) % Will iterate through the width of the image
        currentCropNum = [i, j]; % Select the current crop
        % Choose pixels for the current crop
        currentCropPix = [100*currentCropNum(1)-99, 100*currentCropNum(1); 100*currentCropNum(2)-99, 100*currentCropNum(2)];
        % Select the currrent crop and store in tensor
        currentCrop = flattened(currentCropPix(1,1):currentCropPix(1,2), currentCropPix(2,1):currentCropPix(2,2));
        % Run filter on current crop
            hWeight = 0; % This is the highest weight of the three crops layers
            hDarkWeight = 0;
            for k = 1:1:3 % Run through each of the 3 layers of the image
                % Weight the current crop
                weight = weigh(currentCrop(:,:,k));
                weight = darkFilter(currentCrop(:, :, k));
                % Show the crop
                imshow(currentCrop(:,:,k));
                drawnow;
                if weight>hWeight
                    hWeight = weight;
                end
            end
            weights(i, j) = weight; % Set the weight in the matrix to the highest weight    
                
    end
end
    
    
end
