function [] = CartoonNizer_2016csb1057(I)

image = im2double(I);
I=double(I);
[hue,s,v]=rgb2hsv(I);
cb =  0.148* I(:,:,1) - 0.291* I(:,:,2) + 0.439 * I(:,:,3) + 128;
cr =  0.439 * I(:,:,1) - 0.368 * I(:,:,2) -0.071 * I(:,:,3) + 128;
[w, h]=size(I(:,:,1));
segment = zeros(w,h);
for i=1:w
    for j=1:h            
        if  140<=cr(i,j) && cr(i,j)<=165 && 140<=cb(i,j) && cb(i,j)<=195 && 0.01<=hue(i,j) && hue(i,j)<=0.1     
            segment(i,j)=1;            
        else       
            segment(i,j) = 0;
        end    
    end
end
%figure,imshow(segment);
se = strel('disk',14,4);
segment = imdilate(segment,se);
%figure,imshow(segment);
se = strel('disk',20,4);
segment = imerode(segment,se);
%figure,imshow(segment);

img = (I)/255;
origimg = img;
sigma_d = 2;
sigma_r = 0.1;
sharpen  = [1 1];
img = applycform(img,makecform('srgb2lab'));
[X,Y] = meshgrid(-5:5,-5:5);
img2 = exp(-(X.^2+Y.^2)/(2*sigma_d^2));
sigma_r = 100*sigma_r;
dim = size(img);
rowss = dim(1);
colss = dim(2);
B = zeros(rowss,colss);
for i = 6:rowss-5
   for j = 6:colss-5    
         I = img(i-5:i+5,j-5:j+5,:);
         L = I(:,:,1)-img(i,j,1);
         a = I(:,:,2)-img(i,j,2);
         b = I(:,:,3)-img(i,j,3);
         H = exp(-(L.^2+a.^2+b.^2)/(2*sigma_r^2));
         F = H.*img2((i-5:i+5)-i+6,(j-5:j+5)-j+6);
         total = sum(F(:));
         B(i,j,1) = sum(sum(F.*I(:,:,1)))/total;
         B(i,j,2) = sum(sum(F.*I(:,:,2)))/total;
         B(i,j,3) = sum(sum(F.*I(:,:,3)))/total;              
   end
end

[gradx,grady] = gradient(B(:,:,1)/100);
img2 = sqrt(gradx.^2+grady.^2);
img2(img2>0.2) = 0.2;
img2 = img2/0.2;
E = img2;
E(E<0.3) = 0;
S = diff(sharpen)*img2+sharpen(1);
qab = B; ddd = 100/(7);
qab(:,:,1) = (1/ddd)*qab(:,:,1);
qab(:,:,1) = ddd*round(qab(:,:,1));
qab(:,:,1) = qab(:,:,1)+(ddd/2)*tanh(S.*(B(:,:,1)-qab(:,:,1)));
Q = applycform(qab,makecform('lab2srgb'));
C = repmat(1-E,[1 1 3]).*Q;
%figure,imshow(C);
%figure,imshow(origimg);
dimensions = size(image);
h = fspecial('gaussian',[5,5],7);
B = imfilter(image,h);

for i=1:dimensions(1)
    for j=1:dimensions(2)
        if(segment(i,j)~=0)
            image(i,j,1) = C(i,j,1);
            image(i,j,2) = C(i,j,2);
            image(i,j,3) = C(i,j,3);
        else
            image(i,j,1) = B(i,j,1);
            image(i,j,2) = B(i,j,2);
            image(i,j,3) = B(i,j,3);
        end
    end
end
figure,imshow(image);
imwrite(image,'cartoon.jpg');

end