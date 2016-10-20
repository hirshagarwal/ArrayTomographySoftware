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
    
    
    
    
end
