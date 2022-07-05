%크로마키 임계값
thdown_blue = [0.55, 0.43, 0.25];
thup_blue = [0.75, 1, 1];

drone = ryze()
cameraObj = camera(drone);
takeoff(drone);
moveup(drone, 'distance', 0.6);

while(1)
    frame = snapshot(cameraObj);

    frame_hsv = rgb2hsv(frame);

    [rows, cols, channels] = size(frame_hsv);       
    dst_hsv1 = double(zeros(size(frame_hsv)));      
    dst_hsv2 = double(zeros(size(frame_hsv)));
    dst_h = dst_hsv1(:, :, 1);
    dst_s = dst_hsv1(:, :, 2);
    dst_v = dst_hsv1(:, :, 3);

    for row = 1:rows
        for col = 1:cols
            if thdown_blue(1) < frame_hsv(row, col, 1) && frame_hsv(row, col, 1) < thup_blue(1) ...
                    && thdown_blue(2) < frame_hsv(row, col, 2) && frame_hsv(row, col, 2) < thup_blue(2) ...
                    && thdown_blue(3) < frame_hsv(row, col, 3) && frame_hsv(row, col, 3) < thup_blue(3)
                dst_hsv1(row, col, :) = [0, 0, 1];
            else
                dst_hsv2(row, col, :) = [0, 0, 1];
            end
        end
    end

    dst_rgb1 = hsv2rgb(dst_hsv1);
    dst_rgb2 = hsv2rgb(dst_hsv2);
    dst_gray = rgb2gray(dst_rgb1);

    corners1 = pgonCorners(dst_gray, 4);       % 바깥사각형 코너 좌표 검출

    p1 = corners1(4, :);         % 좌상단
    p2 = corners1(3, :);         % 우상단
    p3 = corners1(1, :);         % 좌하단
    p4 = corners1(2, :);         % 우하단

    roi_x = [corners1(1, 2) + 5, corners1(2, 2) - 5, corners1(3, 2) - 5, corners1(4, 2) + 5];  % roi범위 소량 확장
    roi_y = [corners1(1, 1) - 5, corners1(2, 1) - 5, corners1(3, 1) + 5, corners1(4, 1) + 5];  % roi범위 소량 확장
    roi = roipoly(dst_gray, roi_x, roi_y);         % 코너 좌표만큼 안쪽 이미지 roi

    dst_img = dst_rgb2 .* roi;       
    dst_gray = rgb2gray(dst_img);

    count_pixel = 0;
    center_row = 0;
    center_col = 0;
    for row = 1:rows                                
        for col = 1:cols
            if dst_gray(row, col) == 1          
                count_pixel = count_pixel + 1;      %검출될때마다 픽셀수 세기
                center_row = center_row + row;      %검출될때마다 가로좌표 더하기
                center_col = center_col + col;      %검출될때마다 세로좌표 더하기
            end        
        end
    end

    center_row = center_row / count_pixel;
    center_col = center_col / count_pixel;
    
    answer = [center_col, center_row]          % 센터좌표 검출

    subplot(2, 3, 1); imshow(frame);
    subplot(2, 3, 2); imshow(dst_rgb1);
    subplot(2, 3, 3); imshow(dst_rgb2);
    subplot(2, 3, 4); imshow(dst_img);
    subplot(2, 3, 5); imshow(dst_gray); hold on;
    plot(center_col, center_row, 'r*'); hold off;
    subplot(2, 3, 6); imshow(frame); hold on;
    plot(center_col, center_row, 'r*'); hold off;   
end

%land(droneObj);