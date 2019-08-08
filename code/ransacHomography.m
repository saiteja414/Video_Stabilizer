function [ tx,ty,th ] = ransacHomography( x1, x2, thresh )
%RANSACHOMOGRAPHY Summary of this function goes here
%   Detailed explanation goes here
ndash = size(x1,1);
s = RandStream('mlfg6331_64');
H = ones(3,3);
count = 0;
for i = 1:400
    y = datasample(s,1:ndash,2,'Replace',false);
    [tx1,ty1,th1] = homography(x1(y,:),x2(y,:));
    Htemp = [cos(th1) -sin(th1) tx1;sin(th1) cos(th1) ty1; 0 0 1];
    temp1 = Htemp*[x2 ones(ndash,1)]';
    temp2 = temp1./temp1(3,:);
    temp3 = (x1-temp2(1:2,:)').^2;
    countTemp = sum((temp3(:,1) + temp3(:,2))<=thresh);
    if countTemp >= count
        tx = tx1;
        ty = ty1;
        th = th1;
        count = countTemp;
    end
end

