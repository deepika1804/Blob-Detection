function detectBlobs (I,threshold,scale,n,k)
%% I: image on top of which you want to display the circles
%% threshold : value above which we consider an area to be blob
%% scale : To determine sigma value at each level
%% n: no of iterations to be performed
%% k : factor to increase or decrease the size
%%       
   %performing blob detection on 2-D grayscale image
    Im = rgb2gray(I);
    Im = im2double(Im);
    color = 'r';
    ln_wid = 1.5;
    
    % generating the laplacian filters for each level
    idx = 0;
    filter = cell(n,1);
    for i=1:1:n
        idx = idx+1;
        sigma = scale * k^(i-1);
        %performing scale normalization on filters
        filter{idx} = sigma^2 * fspecial('log', 2*ceil(sigma*3)+1, sigma);
    end
    
    % scale space for storing images at different scales
    scale_space = zeros(size(I,1),size(I,2),n);
    tic
    for i=1:1:n
       scale_space(:,:,i) = conv2(Im,filter{i},'same');
       %square of Laplacian in scale-space
       scale_space(:,:,i) = scale_space(:,:,i) .^ 2;
    end

    %calculating the maxima in scale space above some threshold
    for i=1:1:n
        sigma = scale * k^(i-1);
        sze = 5;
        mx = ordfilt2(scale_space(:,:,(i)),sze^2,ones(sze));
        scale_space(:,:,i) = (scale_space(:,:,i) == mx) & (scale_space(:,:,i)> threshold);
    end


    %loop to calculate the center points of blobs and their radii according
    %to their scale space
    idx = 0;
    CenterPointrows = [];
    CenterPointcols = [];
    sigmaResponse = [];
    for i=1:1:size(scale_space,1)
        for j=1:1:size(scale_space,2)
            [maxVal,idx] = max(scale_space(i,j,:));
            if(maxVal)
                CenterPointrows = [CenterPointrows; i];
                CenterPointcols=[CenterPointcols;j];
                radiiVal = (scale * k^(idx-1) * sqrt(2));
                sigmaResponse = [sigmaResponse;radiiVal];
            end
        end
    end

    %draw the circles on 2D image
    radii = sigmaResponse;
    cx = CenterPointcols;
    cy = CenterPointrows;
    rad = radii;
    show_all_circles(Im, cx,cy,rad, color, ln_wid,'With Increased Kernel Size');
    toc
    %downsampling the images and applying 1 filter on allscaleSpace = cell(n,1);
    scale_space = zeros(size(I,1),size(I,2),n);
    sigma = 1;
    idx = 0;
    r=[];
    c=[];
    sigmaResponse = [];
    tic
    %downsampling the images and applying LOG filter and then upsampling to
    %original size
    for j=1:1:n
        level = k^(j-1);
        resizedIm = imresize(Im,(1/level));
        sigma = 1;
        filterRes = fspecial('log', 2*ceil(sigma*3)+1, sigma);
        scaleSpace{j}(:,:) = conv2(resizedIm,filterRes,'same');
        scaleSpace{j}(:,:) = scaleSpace{j}(:,:).^2;
        scale_space(:,:,j) = imresize(scaleSpace{j}(:,:),[size(I,1) size(I,2)]);
    end
    
    %applying non maximum supression on images
    for j=1:1:n
        sigma = 1;
        sze = 5;
        mx = ordfilt2(scale_space(:,:,j),sze^2,ones(sze));
        scale_space(:,:,j) = ((scale_space(:,:,j) == mx) & (scale_space(:,:,j)> threshold));
    end
    
    %loop to calculate the center points of blobs and their radii according
    %to their scale space
    for i=1:1:size(scale_space,1)
        for j=1:1:size(scale_space,2)
            [maxVal,idx] = max(scale_space(i,j,:));
            if(maxVal)
               r = [r; i];
               c = [c;j];
               radiusVal = scale * k^(idx-1) * sqrt(2); 
               sigmaResponse = [sigmaResponse;radiusVal];
            end
        end
    end

    %draw the circles on 2D image
    radii = sigmaResponse;
    cx = c;
    cy = r;
    rad = radii;
    show_all_circles(Im, cx,cy,rad, color, ln_wid,'With Downsampled Images');
    toc
end

