function weight = weigh(currentCrop)
     weight = 0;
     
     squareSize = size(currentCrop, 1);
     subsampleSize = squareSize/10;
     
     weights = zeros(subsampleSize, subsampleSize);
     %Convolution Layer
     for i = 10:10:size(currentCrop, 1)
         for j = 10:10:size(currentCrop, 2)
             feature = currentCrop(i-9:i, j-9:j);
             W = sum(sum(feature));
             weights(i/subsampleSize, j/subsampleSize) = W;
         end
     end
    
     %Get Brightness
     brightList = []; % List of bright spots
     for i = 1:1:subsampleSize
         for j = 1:1:subsampleSize
            if weights(i,j) > 10000 %Brightness threshold
                brightList = [brightList; [i,j]];
            end
         end
     end
     
     if size(brightList,1)<1
         return
     end
     
     %Check Borders
     featurePieces = [];
     for i = 1:1:size(brightList, 1)
         currentSpot = brightList(i, :);
         for j = 1:1:size(brightList, 1)
             compareSpot = brightList(j, :);
             diff = square(compareSpot-currentSpot);
             if diff(1) && diff(2) == 1
                 featurePieces = [featurePieces; currentSpot];
                 break;
             end
         end
     end
     weight = size(featurePieces,1);
end