%크로마키 임계값
thdown_blue = [0.55, 0.43, 0.25];
thup_blue = [0.75, 1, 1];

% HSV Threshold Red
thdown_red1 = [0, 0.65, 0.25];
thup_red1 = [0.025, 1, 1];
thdown_red2 = [0.975, 0.65, 0.25];
thup_red2 = [1, 1, 1];

drone = ryze()
cameraObj = camera(drone);
takeoff(drone);
moveup(drone, 'distance', 0.4);

while(1)
    frame = snapshot(cameraObj);
    if sum(frame, 'all') == 0
        disp('frame error!');
    end

    src_hsv = rgb2hsv(frame);
    src_h = src_hsv(:,:,1);
    src_s = src_hsv(:,:,2);
    src_v = src_hsv(:,:,3);
    [rows, cols, channels] = size(src_hsv); 

    bw1 = (thdown_blue(1) < src_h) & (src_h < thup_blue(1)) & (thdown_blue(2) < src_s) & (src_s < thup_blue(2)); % 파란색 검출

          
    %dst_hsv1 = double(zeros(size(src_hsv)));      
    %dst_hsv2 = double(zeros(size(src_hsv)));

    if sum(bw1, 'all') < 5000
        moveforward(droneObj, 'distance', 0.3);
        disp('move forward and continue');
        continue;
    end

    sumLeftUp = sum(bw1(1:rows/2, 1:cols/2), 'all');             % 좌상단
    sumRightUp = sum(bw1(1:rows/2, cols/2:end), 'all');          % 우상단
    sumLeftDown = sum(bw1(rows/2:end, 1:cols/2), 'all');         % 좌하단    
    sumRightDown = sum(bw1(rows/2:end, cols/2:end), 'all');      % 우하단

    
    if(sumLeftUp == 0)                              % 좌상단에 크로마키가 없으면
        movedown(droneObj, 'distance', 0.3);        
        moveright(droneObj, 'distance', 0.3);
        disp('우하단 이동');
        continue;
    elseif(sumRightUp == 0)                         % 우상단에 크로마키가 없으면
        movedown(droneObj, 'distance', 0.3);       
        moveleft(droneObj, 'distance', 0.3);
        disp('좌하단 이동');
        continue;
    elseif(sumLeftDown == 0)                        % 좌하단에 크로마키가 없으면
        moveUp(droneObj, 'distance', 0.3);          
        moveright(droneObj, 'distance', 0.3);
        disp('우상단 이동');
        continue;
    elseif(sumRightDown == 0)                       % 우하단에 크로마키가 없으면
        moveUp(droneObj, 'distance', 0.3);          
        moveleft(droneObj, 'distance', 0.3);
        disp('좌상단 이동');
        continue;
    end

    bw2 = imfill(bw1,'holes');                  % 파란색 배경 안 원을 채움(내부가 채워진 사각형)        
    for row = 1:rows
        for col = 1:cols
            if bw1(row, col) == bw2(row, col)
                bw2(row, col) = 0;
            end
        end
    end

    if sum(bw2, 'all') > 20000
            % Detecting Center
            disp('Image Processing 2: Detecting Center');
            count_pixel = 0;
            center_row = 0;
            center_col = 0;
            for row = 1:rows
                for col = 1:cols
                    if bw2(row, col) == 1
                        count_pixel = count_pixel + 1;
                        center_row = center_row + row;
                        center_col = center_col + col;    
                    end        
                end
            end
            center_row = center_row / count_pixel;
            center_col = center_col / count_pixel;
            camera_mid_row = rows / 2;
            camera_mid_col = cols / 2;
            
            disp('Calculating Circle Center');
            moveRow = center_row - camera_mid_row;
            moveCol = center_col - camera_mid_col;
            
            right_cnt = 0;
            left_cnt = 0;
            up_cnt = 0;
            down_cnt = 0;
        else
            disp('Move Cromakey To Center');
            moveback(droneObj, 'distance', 0.4);
    end  
          

    camera_mid_row = rows / 2;
    camera_mid_col = cols / 2;
            
    disp('Calculating Circle Center');
    moveRow = center_row - camera_mid_row;
    moveCol = center_col - camera_mid_col;
    
    subplot(2, 2, 1); imshow(frame);
    subplot(2, 2, 2); imshow(bw1);
    subplot(2, 2, 3); imshow(bw2);
    subplot(2, 2, 4); imshow(frame); hold on;
    plot(center_col, center_row, 'r*'); hold off;
    
end