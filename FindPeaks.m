function [roi peak] = FindPeaks(inimg, minsize, maxsize, t, contiguous, verbose, showslices, colors)

%function [roi peak] = FindPeaks(inimg, minsize, maxsize, t, contiguous, verbose,  showslices, colors)
%
%       Find peaks and uses watershed algorithm to grow regions from them.
%
%       inimg       - input image (file name or 3D matrix)
%       minsize     - minimal size of the resulting ROI  [0]
%       maxize      - maximum size of the resulting ROI  [inf]
%       t           - threshold value [-5]
%                     if threshold is negative it will compute the value above which only t% of the signal is
%       contiguous  - should the roi be converted to contiguos objects [false]
%       verbose     - whether to report the peaks (1) and also be verbose (2) [false]
%       showslices  - whether to show slices [false]
%       colors      - what colormap to use lines / jet / prism / flag [lines]
%
%    Grega Repovs, 2016-10-29 (Adapted from mri_FindPeaks)
%

if nargin < 8 || isempty(colors),     colors      = 'lines'; end
if nargin < 7 || isempty(showslices), showslices  = true;   end % Modified
if nargin < 6 || isempty(verbose),    verbose     = true;   end % Modified
if nargin < 5 || isempty(contiguous), contiguous  = false;   end
if nargin < 4 || isempty(t),          t           = -5;      end
if nargin < 3 || isempty(maxsize),    maxsize     = inf;     end
if nargin < 2 || isempty(minsize),    minsize     = 1;       end

% --- Script verbosity

report = false;
if verbose == 1
    verbose = false;
    report  = true;
elseif verbose == 2
    verbose = true;
    report  = true;
end

% --- Prepare input

if ischar(inimg)
    img.hdr = imfinfo(inimg);
    img.dim = [img.hdr(1).Width img.hdr(1).Height length(img.hdr)];
    img.data = zeros(img.dim);
    for n = 1:img.dim(3)
        img.data(:,:,n) = imread(inimg, n);
    end
    img.data = double(img.data);
else
    img.data = inimg;
    img.dim  = size(inimg);
end


% --- estimate threshold

if t < 0
    alldata = sort(img.data(:));
    t = alldata(round(length(alldata) * (1 + t/100)));
end


% --- Set up and threshold data

data  = zeros(size(img.data)+2);
data(2:(img.dim(1)+1),2:(img.dim(2)+1),2:(img.dim(3)+1)) = img.data;
data(data < t) = 0;

% --- Find all the relevant maxima

if verbose, fprintf('\n---> identifying intial set of peaks'); end

p    = 0;
peak = [];

for x = 2:img.dim(1)+1
    for y = 2:img.dim(2)+1
        for z = 2:img.dim(3)+1
            if data(x, y, z) > 0 && data(x, y, z) == max(max(max(data((x-1):(x+1), (y-1):(y+1), (z-1):(z+1)))))
                p = p + 1;
                peak(p).xyz   = [x, y, z];
                peak(p).value = data(x, y, z);
            end
        end
    end
end


% --- prepare voxel data

[vind, ~, vval] = find(reshape(data, [], 1));
[~, s] = sort(vval, 1, 'descend');

[x, y, z] = ind2sub(size(data), vind(s));
% vlist = [x y z];
nvox = length(vval);

seg = zeros(size(data));
bpx = zeros(size(data));
okv = zeros(nvox, 1);

% --- First flooding

if verbose, fprintf('\n---> flooding %d peaks', length(peak)); end

for n = 1:length(peak)
    seg(peak(n).xyz(1), peak(n).xyz(2), peak(n).xyz(3)) = n;
    peak(n).size = 1;
end
for n = 1:nvox
    if seg(x(n), y(n), z(n)) > 0
        okv(n) = 1;
    end
end

while min(okv) == 0
    bpx(:) = 0;
    for n = 1:nvox

        if okv(n) > 0
            continue
        end

        % check the neighborhood

        u = unique(seg((x(n)-1):(x(n)+1), (y(n)-1):(y(n)+1), (z(n)-1):(z(n)+1)));
        u = u(u>0);

        if length(u) == 1  % assign the value
            seg(x(n), y(n), z(n)) = u;
            peak(u).size = peak(u).size + 1;
            okv(n) = 1;
        elseif length(u) > 1                % put it to the closest peak
            mdist = inf;
            for k = u(:)'
                cdist = sqrt(sum(([x(n) y(n) z(n)] - peak(k).xyz).^2));
                if cdist < mdist
                    mdist = cdist;
                    cparc = k;
                end
            end
            bpx(x(n), y(n), z(n)) = cparc;
            peak(cparc).size = peak(cparc).size + 1;
            okv(n) = 1;
        end
    end
    seg = seg + bpx;
end

% --- reassign ROI too small

if ~isempty(peak)
    small = peak([peak.size] < minsize);
else
    small = [];
end

while ~isempty(small)

    rsize = min([small.size]);
    rtgts = find([peak.size]==rsize);

    if verbose, fprintf('\n---> %d regions too small, refilling %d regions of size %d', length(small), length(rtgts), rsize); end

    for rtgt = rtgts(:)';

        [vind, ~, vval] = find(seg(:) == rtgt);
        [~, s]    = sort(vval, 1, 'descend');
        [x, y, z] = ind2sub(size(data), vind(s));
        nvox      = length(vval);

        done = false;
        for n = 1:nvox

            u = unique(seg((x(n)-1):(x(n)+1), (y(n)-1):(y(n)+1), (z(n)-1):(z(n)+1)));
            u = u(u > 0 & u ~= rtgt);

            if length(u) == 1
                seg(seg==rtgt) = u;
                peak(u).size = peak(u).size + peak(rtgt).size;
                done = true;
                break

            elseif length(u) > 1
                for m = 1:nvox
                    cparc = 0;
                    mdist = inf;
                    for k = u(:)';
                        cdist = sqrt(sum(([x(m) y(m) z(m)] - peak(k).xyz).^2));
                        if cdist < mdist
                            mdist = cdist;
                            cparc = k;
                        end
                    end
                    seg(x(m), y(m), z(m)) = cparc;
                    peak(cparc).size = peak(cparc).size + 1;
                end
                done = true;
                break
            end
        end
        if ~done
            seg(seg==rtgt) = 0;
        end
        peak(rtgt).size = 0;
    end
    small = peak([peak.size] > rsize & [peak.size] < minsize);
end



% --- Trim regions that are too large

if ~isempty(peak)
    big = find([peak.size] > maxsize);
else
    big = [];
end

if ~isempty(big) && verbose, fprintf('\n\n---> found %d ROI that are too large', length(big)); end

for b  = big(:)'

    np = 0;
    seg(seg==(b)) = -1;
    plist = zeros(peak(b).size, 4);

    if verbose, fprintf('\n---> reflooding region %d', b); end

    x = peak(b).xyz(1);
    y = peak(b).xyz(2);
    z = peak(b).xyz(3);

    peak(b).size = 1;
    seg(x, y, z) = b;
    [seg, plist, np] = addPriority(data, seg, plist, x, y, z, np);

    while np > 0

        x = plist(1,1);
        y = plist(1,2);
        z = plist(1,3);

        plist(1:np,:) = plist(2:(np+1),:);
        np = np - 1;

        seg(x, y, z) = b ;
        peak(b).size = peak(b).size + 1;
        [seg, plist, np] = addPriority(data, seg, plist, x, y, z, np);

        if peak(b).size >= maxsize
            break
        end
    end
end
seg(seg<1) = 0;

% --- join contiguous regions

if contiguous

    seg   = bwlabeln(seg > 0);
    stats = regionprops(seg, 'Centroid', 'Area');

    nroi = length(stats);
    peak = [];
    for n = 1:nroi
        peak(n).xyz   = round(stats(n).Centroid);
        peak(n).label = n;
        peak(n).size  = stats(n).Area;
    end
end


% --- relabel to consecutive labels

c = 1;
for p = 1:length(peak)
    if peak(p).size > 0
        seg(seg == p) = c;
        peak(p).label = c;
        c = c + 1;
    end
end

% --- remove empty peaks

if ~isempty(peak)
    peak = peak([peak.size]>0);
end

% --- embedd ROI

roi.data = seg(2:(img.dim(1)+1),2:(img.dim(2)+1),2:(img.dim(3)+1));
roi.dim = img.dim;


% --- gather statistics

if isempty(peak)
    if report, fprintf('\n===> No peaks to report on!\n'); end
else

    roiinfo.cijk = getROICentroids(roi.data);
    roiinfo.cxyz = [roiinfo.cijk(:,1:2) * 0.10245880127424224 roiinfo.cijk(:,3) * 0.07];
    roiinfo.ijk  = [reshape([peak.label], [],1) reshape([peak.xyz], 3, [])' - 1];
    roiinfo.xyz  = [roiinfo.ijk(:,1:2) * 0.10245880127424224 roiinfo.ijk(:,3) * 0.07];

    if report, fprintf('\n===> peak report\n'); end

    for p = 1:length(peak)
        peak(p).ijk = peak(p).xyz - 1;
        peak(p).xyz = roiinfo.xyz(p, end-2:end);
        peak(p).value = img.data(peak(p).ijk(1), peak(p).ijk(2), peak(p).ijk(3));
        peak(p).Centroid = roiinfo.cxyz(p, end-2:end);
        % peak(p).WeightedCentroid = roiinfo.wcxyz(p, end-2:end);

        if report, fprintf('\nROI:%3d  label: %3d  value: %5.1f  voxels: %3d  peak indeces: %3d %3d %3d  peak: %5.1f %5.1f %5.1f  centroid: %5.1f %5.1f %5.1f', p, peak(p).label, peak(p).value, peak(p).size, peak(p).ijk, peak(p).xyz, peak(p).Centroid); end
    end

    if report, fprintf('\n'); end
end


% --- save the resulting image if file was an input

if ischar(inimg)
    [fpath, fname, fext] = fileparts(inimg);
    outFileName = fullfile(fpath, [fname '_roi' fext]);
    for n = 1:roi.dim(3)
        imwrite(roi.data(:,:,n), outFileName, 'WriteMode', 'append',  'Compression','none');
    end
end

% --- display a slice

if showslices
    nroi = max(roi.data(:));
    cslice = 1;
    f = figure;
    image(roi.data(:,:,cslice));

    switch colors
        case 'jet'
            cmap = jet(nroi);
        case 'prism'
            cmap = prism(nroi);
        case 'flag'
            cmap = flag(nroi);
        otherwise
            cmap = lines(nroi);
    end

    cmap(1,:) = [0 0 0];
    colormap(cmap);

    while true
        k = waitforbuttonpress;
        k = get(f,'CurrentCharacter');
        if k == 'u'
            cslice = min(roi.dim(3), cslice+1);
        elseif k == 'd'
            cslice = max(1, cslice-1);
        elseif k == 'q'
            break
        end
        image(roi.data(:,:,cslice));
    end
    close();
end

% --- the end

if verbose, fprintf('\n===> DONE\n'); end



% --- SUPPORT FUNCTIONS

function [seg, plist, np] = addPriority(data, seg, plist, x, y, z, np)

    for xi = x-1:x+1
        for yi = y-1:y+1
            for zi = z-1:z+1
                if seg(xi, yi, zi) == -1
                    seg(xi, yi, zi) = -2;
                    np = np + 1;
                    v  = data(xi, yi, zi);
                    for n = 1:np
                        if v > plist(n, 4)
                            plist(n+1:np+1,:) = plist(n:np,:);
                            plist(n,:) = [xi, yi, zi, v];
                            break
                        end
                    end
                end
            end
        end
    end


% --> getting ROI Centroids

function [xyz] = getROICentroids(roi)

    stats = regionprops(roi, 'Centroid');
    rois  = sort(unique(roi));
    rois  = rois(rois>0);
    xyz   = [];
    if ~isempty(rois)
        xyz = [rois reshape([stats(rois).Centroid], 3, [])'];
        xyz = xyz(:, [1 3 2 4]);
    end


