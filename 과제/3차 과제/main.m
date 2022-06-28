for k = 1:5
    if k == 1
        src = imread("문제1.png");
    elseif k == 2
        src = imread("문제2.png");
    elseif k == 3
        src = imread("문제3.png");
    elseif k == 4
        src = imread("문제4.png");
    elseif k == 5
        src = imread("문제5.png");
    end
    
    src_hsv = rgb2hsv(src);
    thdown_green = [0.25, 40/240, 80/240];         
    thup_green = [0.40, 1, 1];

    [rows, cols, channels] = size(src_hsv);        

    dst_h = src_hsv(:, :, 1);
    dst_s = src_hsv(:, :, 2);
    dst_v = src_hsv(:, :, 3);

    dst_hsv1 = double(zeros(size(dst_h)));       
    dst_hsv2 = double(zeros(size(dst_h)));

    
    for row = 1:rows
        for col = 1:cols
           if thdown_green(1) < dst_h(row, col) && dst_h(row, col) < thup_green(1) ...
               && thdown_green(2) < dst_s(row, col) && dst_s(row, col) < thup_green(2) ...
               && thdown_green(3) < dst_v(row, col) && dst_v(row, col) < thup_green(3)
               dst_hsv1(row, col) = 1;
            else
                dst_hsv2(row, col) = 1;
            end
        end
    end
    
    dst_gray1 = im2gray(dst_hsv1);
    canny1 = edge(dst_gray1,'Canny');        

    corners = pgonCorners(canny1,4);
    
    count = 0;
    for i = 1:size(corners)
        count = count + 1;
    end

    a = [0 0 0 0]; % a4: 좌상 a3: 우상 a1: 좌하 a2: 우하
    if count == 3       
        for i = 1:size(corners)
            if corners(i,1) >= 718
                a(1) = a(1)+1;
                a(2) = a(2)+1;
            end
            if corners(i,1) <= 2
                a(3) = a(3)+1;
                a(4) = a(4)+1;
            end
            if corners(i,2) >= 958
                a(2) = a(2)+1;
                a(3) = a(3)+1;
            end
            if corners(i,2) <= 2
                a(4) = a(4)+1;
                a(1) = a(1)+1;
            end
        end
    end
    
    for i = 1:4
        if a(i) == 2
            if i == 4
                corners(i,2) = 4;
                corners(i,1) = 4;
            else
                for j = 4:-1:i+1
                    corners(j,1) = corners(j-1,1);
                    corners(j,2) = corners(j-1,2);
                end
                if i == 1 
                    corners(i,2) = 4;
                    corners(i,1) = 716;
                elseif i == 2
                    corners(i,2) = 956;
                    corners(i,1) = 716;
                elseif i == 3
                    corners(i,1) = 4;
                    corners(i,2) = 956;           
                end
            end
        end
    end
    
    for i = 1:4
        if i == 1
            corners(i,1) = corners(i,1)-4;
            corners(i,2) = corners(i,2)+4;
        end
        if i == 2
            corners(i,1) = corners(i,1)-4;
            corners(i,2) = corners(i,2)-4;
        end  
        if i == 3
            corners(i,1) = corners(i,1)+4;
            corners(i,2) = corners(i,2)-4;
        end  
        if i == 4
            corners(i,1) = corners(i,1)+4;
            corners(i,2) = corners(i,2)+4;
        end  
    end

    roi = roipoly(canny1,corners(:,2),corners(:,1));
    dst_img = dst_hsv2 .* roi;   
    figure,imshow(dst_img)

    dst_gray = im2gray(dst_img);
    canny = edge(dst_gray,'Canny');
    
    corner = pgonCorners(canny,4);
    hold on
    plot(corner(:,2),corner(:,1),'yo','MarkerFaceColor','r',...
                                'MarkerSize',12,'LineWidth',2);
    hold off
    polyin = polyshape(corner(:,2),corner(:,1)); 
    [x,y] = centroid(polyin); 
    hold on
    plot(x,y,'r*')
    hold off
    disp(k + ": " + x + "," + y) 
end

function corners = pgonCorners(BW,k,N)

   if nargin<3, N=360; end
  
    theta=linspace(0,360,N+1); theta(end)=[];
    IJ=bwboundaries(BW);
    IJ=IJ{1};
    centroid=mean(IJ);
    IJ=IJ-centroid;
    
    c=nan(size(theta));
    
    for i=1:N
        [~,c(i)]=max(IJ*[cosd(theta(i));sind(theta(i))]);
    end
    
    Ih=IJ(c,1); Jh=IJ(c,2);
    
    [H,~,~,binX,binY]=histcounts2(Ih,Jh,k);
     bin=sub2ind([k,k],binX,binY);
    
    [~,binmax] = maxk(H(:),k);
    
    [tf,loc]=ismember(bin,binmax);
    
    IJh=[Ih(tf), Jh(tf)];
    G=loc(tf);
    
    C=splitapply(@(z)mean(z,1),IJh,G);
    
    [~,perm]=sort( cart2pol(C(:,2),C(:,1)),'descend' );
    
    corners=C(perm,:)+centroid;
end