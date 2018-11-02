function out = CountShapes_2016csb1057(rgb)


%gray_image = rgb2gray(rgb);
im = im2bw(rgb,0.5);
%figure,imshow(im);
gray_image = im;
se = strel('line',3,90);
gray_image = imdilate(gray_image,se);
%figure, imshow(gray_image);
[row,col] = size(gray_image);

%figure,imshow(gray_image);
gray_image = bwareaopen(gray_image, 2500);
gray_image2 = zeros(row,col);
for i=1:row
    for j=1:col
        if(gray_image(i,j)==1)
            gray_image2(i,j) = 0;
        elseif (gray_image(i,j)==0)
            gray_image2(i,j) = 1;
        end
    end
end

gray_image2 = bwareaopen(gray_image2, 250);
se = strel('line',3,90);
gray_image2 = imerode(gray_image2,se);
gray_image2 = edge(gray_image2,'canny');
%figure, imshow(gray_image2);

% CC = bwconncomp(gray_image2);
% numPixels = cellfun(@numel,CC.PixelIdxList);
% [biggest,idx] = max(numPixels);
% gray_image(CC.PixelIdxList{idx}) = 1;
% figure,imshow(gray_image);


% % 
gray_image = gray_image2;
figure,imshow(rgb);
centerList = [];
radiiList = [];
listRadii = [60,100,150,200,250];
for i=60:30:250
    [centers,radii] = imfindcircles(gray_image,[i,i+30],'Sensitivity',0.946,'Method','twostage');
    centerList = [centerList; centers];
    radiiList = [radiiList; radii];
end
viscircles(centerList,radiiList);
f = getframe(gca);
im = frame2im(f);
dim = size(centerList);
dim(1);
disp('THE NUMBER OF RINGS ARE: ');
disp(dim(1));
imwrite(im,'finalCircles.jpg');
out = dim(1);


end