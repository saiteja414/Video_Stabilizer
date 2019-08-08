function [ tx,ty,th ] = homography( p2, p1 )
%HOMOGRAPHY Summary of this function goes here
%   Detailed explanation goes here
p11 = p1(1,:)';
p12 = p1(2,:)';

p21 = p2(1,:)';
p22 = p2(2,:)';

m1 = (p11 + p12)/2;
m2 = (p21 + p22)/2;

p11 = p11 - m1;
p12 = p12 - m1;

p21 = p21 - m2;
p22 = p22 - m2;

c = 0.5*(p21*p11' + p22*p12');
[U,S,V] = svd(c);

R = U * [1 0 ;0 det(U*V')] * V';
th=atan2(R(2,1),R(1,1));

t = m2 - R * m1;

tx = t(1);
ty = t(2);

end

