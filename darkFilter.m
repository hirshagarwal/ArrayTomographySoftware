function weight = darkFilter(currentCrop)
    weight = 0;
    squareSize = size(currentCrop, 1);
    subsampleSize = squareSize/10;
    
    weights = zeros(subsampleSize, subsampleSize);
    imshow(currentCrop);
    %Convolution Layer
    for i = 10:10:size(currentCrop, 1)
        for j = 10:10:size(currentCrop, 2)
            feature = currentCrop(i-9:i, j-9:j, :);
            W = sum(sum(sum(feature)));
            weights(i/subsampleSize, j/subsampleSize) = W;
        end
    end
    
    %Get Darkness
    darkList = [];
    for i = 1:1:subsampleSize
        for j = 1:1:subsampleSize
            if weights(i, j) < 300 %Darkness Threshold - This value could benefit from some testing
                darkList = [darkList; [i, j]];
               
            end
        end
    end
    
    if size(darkList, 1)<1
        return
    end
    
    %Check Borders
    featurePieces = [];
    for i = 1:1:size(darkList, 1)
        currentSpot = darkList(i, :);
        for j = 1:1:size(darkList, 1)
            compareSpot = darkList(j, :);
            diff = square(compareSpot-currentSpot);
            if diff(1) && diff(2) == 1
                featurePieces = [featurePieces; currentSpot];
                break;
            end
        end
    end
    weight = size(featurePieces, 1);
end