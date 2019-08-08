%% Read Video & Setup Environment
clear
clc
close all hidden
[FileName,PathName] = uigetfile({'*.avi'; '*.mp4'},'Select shaky video file');
cd mmread
vid=mmread(strcat(PathName,FileName));
cd ..
s=vid.frames;
outV=s;

%% Your code here
F = size(s,2);

tx = zeros(F);
ty = zeros(F);
th = zeros(F);

tx1 = zeros(F);
ty1 = zeros(F);
th1 = zeros(F);


Hc = eye(3);

for i = 1:F-1
    im1 = s(i).cdata;
    im2 = s(i+1).cdata;
    g1 = rgb2gray(im1);
    p1 = detectSURFFeatures(g1);
    [f1, p1] = extractFeatures(g1, p1);
    
    g2 = rgb2gray(im2);
    p2 = detectSURFFeatures(g2);
    [f2, p2] = extractFeatures(g2, p2);
    
    idx = matchFeatures(f1,f2,'Unique',true);
    
    fp1 = p1(idx(:,1),:);
    fp2 = p2(idx(:,2),:);
    
    [x,y,thet] = ransacHomography(fp2.Location,fp1.Location,3);
    
    tx(i) = x;
    ty(i) = y;
    th(i) = thet;
    
    %R = H(1:2,1:2);
end

for i=2:F
    tx(i) = tx(i)+tx(i-1);
    ty(i) = ty(i)+ty(i-1);
    th(i) = th(i)+th(i-1);
end


for i = 2:F
    minBound = max(2, i-15);
    maxBound = min(i+15,F);
    
    tx1(i) = mean(tx(minBound:maxBound));
    ty1(i) = mean(ty(minBound:maxBound));
    th1(i) = mean(th(minBound:maxBound));
    
end
% iter=1:size(tx,1);
% figure(100000),plot(iter,tx1,iter,tx,iter,ty1,iter,ty,iter,th1,iter,th)

tx = tx1-tx;
ty = ty1-ty;
th = th1-th;

for i=1:F-1
    H = [cos(th(i)) -sin(th(i)) tx(i);sin(th(i)) cos(th(i)) ty(i); 0 0 1];

    im2 = s(i+1).cdata;
    outV(i+1).cdata = imwarp(im2,affine2d(H'),'OutputView',imref2d(size(im2)));
end



%% Write Video
vfile=strcat(PathName,'combined_',FileName);
ff = VideoWriter(vfile);
ff.FrameRate = 30;
open(ff)

for i=1:F
    f1 = s(i).cdata;
    f2 = outV(i).cdata;
    vframe=cat(1,f1,f2);
    writeVideo(ff, vframe);
end
close(ff)

%% Display Video
figure
msgbox(strcat('Combined Video Written In ', vfile), 'Completed')
displayvideo(outV,0.01)
