thdown_blue = [0.55, 0.43, 0.25];
thup_blue = [0.75, 1, 1];

% HSV Threshold Red
thdown_red1 = [0, 0.65, 0.25];
thup_red1 = [0.025, 1, 1];
thdown_red2 = [0.975, 0.65, 0.25];
thup_red2 = [1, 1, 1];

% HSV Threshold Purple
thdown_purple = [0.725, 0.25, 0.25];
thup_purple = [0.85, 1, 1];

right_cnt = 0;
left_cnt = 0;
up_cnt = 0;
down_cnt = 0;
activeForward = 1;

droneObj = ryze()
cameraObj = camera(droneObj);
takeoff(droneObj);
moveup(droneObj, 'distance', 0.4);
loopBreak = 0;

while 1
    disp('1단계 루프 수행 중!');
    clear moveRow;
    clear moveCol;
    % HSV Convert
    disp('----------------- HSV Converting --------------------');
    frame = snapshot(cameraObj);
    if sum(frame, 'all') == 0
        continue
    end
    src_hsv = rgb2hsv(frame);
    src_h = src_hsv(:,:,1);
    src_s = src_hsv(:,:,2);
    src_v = src_hsv(:,:,3);
    [rows, cols, channels] = size(src_hsv);

    % Image Preprocessing
    bw1 = (thdown_blue(1) < src_h) & (src_h < thup_blue(1)) & (thdown_blue(2) < src_s) & (src_s < thup_blue(2)); % 파란색 검출 
    if sum(bw1, 'all') < 5000
        if activeForward == 1
            activeForward = 0;
            moveforward(droneObj, 'distance', 1);       % 맵에 따라서(크로마키의 앞뒤 위치에 따라서) 없애야 할 수도 있음
        end
        
        if right_cnt < 3
            right_cnt = right_cnt + 1;
            moveright(droneObj, 'distance', 0.5);
            continue;
        elseif right_cnt == 3
            if up_cnt < 3
                up_cnt = up_cnt + 1;
                moveup(droneObj, 'distance', 0.5);
                continue;
            elseif up_cnt == 3
                up_cnt = up_cnt + 1;
                movedown(droneObj, 'distance', 1.5);
                continue;
            elseif down_cnt < 3
                down_cnt = down_cnt + 1;
                movedown(droneObj, 'distance', 0.5);
                continue;
            elseif down_cnt == 3
                down_cnt = down_cnt + 1;
                moveup(droneObj, 'distance', 1.5);
                continue;
            else
                right_cnt = right_cnt + 1;
                moveleft(droneObj, 'distnace', 1.5);
                continue;
            end
        elseif left_cnt < 3
            left_cnt = left_cnt + 1;
            moveleft(droneObj, 'distance', 0.5);
            continue;
        elseif left_cnt == 3
            if up_cnt < 3
                up_cnt = up_cnt + 1;
                moveup(droneObj, 'distance', 0.5);
                continue;
            elseif up_cnt == 3
                up_cnt = up_cnt + 1;
                movedown(droneObj, 'distance', 1.5);
                continue;
            elseif down_cnt < 3
                down_cnt = down_cnt + 1;
                movedown(droneObj, 'distance', 0.5);
                continue;
            elseif down_cnt == 3
                down_cnt = down_cnt + 1;
                moveup(droneObj, 'distance', 1.5);
                continue;
            else
                left_cnt = left_cnt + 1;
                moveright(droneObj, 'distnace', 1.5);
                continue;
            end
        end
    else
        right_cnt = 0;
        left_cnt = 0;
        up_cnt = 0;
        down_cnt = 0;
    end
    
    % Move To Center
    sumUp = sum(bw1(1:rows/2, :), 'all');             % 상단 절반
    sumDown = sum(bw1(rows/2:end, :), 'all');         % 하단 절반
    sumLeft = sum(bw1(:, 1:cols/2), 'all');           % 좌측 절반
    sumRight = sum(bw1(:, cols/2:end), 'all');        % 우측 절반
    
    if(sumUp == 0)                                  % 상단에 크로마키가 없으면
        movedown(droneObj, 'distance', 0.5);        % 하단으로 이동
    elseif(sumDown == 0)                            % 하단에 크로마키가 없으면
        moveup(droneObj, 'distance', 0.5);          % 상단으로 이동 -----------------------------------------------------
    elseif(sumLeft == 0)                            % 좌측에 크로마키가 없으면
        moveright(droneObj, 'distance', 0.5);       % 우측으로 이동
    elseif(sumRight == 0)                           % 우측에 크로마키 없으면
        moveleft(droneObj, 'distance', 0.5);        % 좌측으로 이동
    else                                            % 4개의 사분면 모두에 크로마키가 존재하면 원 검출
        % 구멍을 채우기 전후를 비교, 원이 아닌부분 0(검은색), 원 부분 1(흰색)
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
%             if up_cnt < 1
%                 up_cnt = up_cnt + 1;
%                 moveup(droneObj, 'distance', 0.2); %-----------------------------------------------------------------------
%                 continue;
%             elseif right_cnt < 1
%                 right_cnt = right_cnt + 1;
%                 moveright(droneObj, 'distance', 0.2);
%                 continue;
%             elseif down_cnt < 2
%                 down_cnt = down_cnt + 1;
%                 movedown(droneObj, 'distance', 0.2);
%                 continue;
%             elseif left_cnt < 2
%                 left_cnt = left_cnt + 1;
%                 moveleft(droneObj, 'distance', 0.2);
%                 continue;
%             else
%                 moveup(droneObj, 'distance', 0.4);
%                 continue;
%             end
%             if(sumUp > sumDown)                         % 상단 크로마키 > 하단 크로마키
%                 disp('MoveUp');
%                 moveup(droneObj, 'distance', 0.2);      % 상단으로 이동
%             else                                        % 상단 크로마키 < 하단 크로마키
%                 disp('MoveDown');
%                 movedown(droneObj, 'distance', 0.2);    % 하단으로 이동
%             end
%             
%             if(sumLeft > sumRight)                      % 좌측 크로마키 > 우측 크로마키
%                 disp('MoveLeft');
%                 moveleft(droneObj, 'distance', 0.2);	% 좌측으로 이동
%             else                                        % 좌측 크로마키 < 우측 크로마키
%                 disp('MoveRight');
%                 moveright(droneObj, 'distance', 0.2);   % 우측으로 이동
%             end
        end     
    end
    
    try
        disp('Move Drone Very Carefully!!!');
        if (-100 < moveRow && moveRow < 100) && (-100 < moveCol && moveCol < 100)
            movedown(droneObj, 'distance', 0.2);
            bw2_pix_num = sum(bw2, 'all');
            if 110000 < bw2_pix_num
                disp('Circle And Drone Center Matched!! Try Passing Ring');
                moveforward(droneObj, 'distance', 2.15);
                while 1
                    frame = snapshot(cameraObj);
                    if sum(frame, 'all') == 0
                        continue;
                    end
                    src_hsv = rgb2hsv(frame);
                    src_h = src_hsv(:, :, 1);
                    src_s = src_hsv(:, :, 2);
                    src_v = src_hsv(:, :, 3);

                    % Image Preprocessing
                    bw_red = ((thdown_red1(1) < src_h & src_h < thup_red1(1)) & (thdown_red1(2) < src_s & src_s < thup_red1(2))) ...            % 빨간색1범위 검출
                           + ((thdown_red2(1) < src_h & src_h < thup_red2(1)) & (thdown_red2(2) < src_s & src_s < thup_red2(2)));               % 빨간색2범위 검출
                    bw_purple = (thdown_purple(1) < src_h) & (src_h < thup_purple(1)) & (thdown_purple(2) < src_s) & (src_s < thup_purple(2));  % 보라색범위 검출           

                    subplot(2, 2, 1), imshow(frame);
                    subplot(2, 2, 2), imshow(frame);
                    subplot(2, 2, 3), imshow(bw_red);
                    subplot(2, 2, 4), imshow(bw_purple);

                    % 빨간색 혹은 보라색 검출할 때까지 전진
                    sum(bw_red, 'all')
                    if (sum(bw_purple, 'all') > 1000)                          % 보라색이 검출되면
                        disp('Purple Color Detected!!! Drone Turn Left');
                        land(droneObj);                                     % Landing
                        return;                                             % 프로그램 종료
                    elseif(sum(bw_red, 'all') > 1000)                       % 빨간색이 검출되면
                        disp('RED Color Detected!!! Drone Landing');
                        turn(droneObj, deg2rad(-90));                       % Turn Left, 다음동작 크로마키 검출, 지난 링을 건드리지 않도록 일정거리 전진
                        moveforward(droneObj, 'distance', 1.2);
                        right_cnt = 0;
                        left_cnt = 0;
                        up_cnt = 0;
                        down_cnt = 0;
                        activeForward = 1;
                        loopBreak = 1;
                        break;
                    else
                        % 여기에 표식탐색 기능 추가
                        disp('Missing Sign!! Try Detecting Sign');
                        if down_cnt < 1
                            down_cnt = down_cnt + 1;
                            movedown(droneObj, 'distance', 0.2);
                            continue;
                        elseif up_cnt < 1
                            up_cnt = up_cnt + 1;
                            moveup(droneObj, 'distance', 0.4);
                            continue;
                        elseif left_cnt < 1
                            left_cnt = left_cnt + 1;
                            movedown(droneObj, 'distance', 0.2);
                            moveleft(droneObj, 'distance', 0.2);
                            continue;
                        elseif right_cnt < 1
                            right_cnt = right_cnt + 1;
                            moveright(droneObj, 'distance', 0.4);
                            continue;
                        else
                            moveleft(droneObj, 'distance', 0.2);
                            right_cnt = 0;
                            left_cnt = 0;
                            up_cnt = 0;
                            down_cnt = 0;
                        end
                    end
                end

                if loopBreak == 1
                    break;
                end
                

            elseif (bw2_pix_num < 110000)
                moveforward(droneObj, 'distance', 0.3);                 % 맵에 따라서 1m단위로 링을 배치한다면 0.5, 아니라면 0.2 or 0.25
            end      
            
        elseif moveRow < -100
            disp('MoveUp');
            moveup(droneObj, 'Distance', 0.2)
        elseif 100 < moveRow
            disp('MoveDown');
            movedown(droneObj, 'Distance', 0.2)
        elseif moveCol < -100
            disp('MoveLeft');
            moveleft(droneObj, 'Distance', 0.2)
        elseif 100 < moveCol
            disp('MoveRight');
            moveright(droneObj, 'Distance', 0.2)
        end

        disp('There is Circle Center Coordinates');
        subplot(2, 2, 1), imshow(frame);
        subplot(2, 2, 2), imshow(frame); hold on;
        plot(center_col, center_row, 'r*'); hold off;
        subplot(2, 2, 3), imshow(bw1); hold on;
        plot(center_col, center_row, 'r*'); hold off;
        subplot(2, 2, 4), imshow(bw2); hold on;
        plot(center_col, center_row, 'r*'); hold off;
        clear center_col;
        clear center_row;
   catch exception
        disp('There is no Circle Center Coordinates');
        subplot(2, 2, 1), imshow(frame);
        subplot(2, 2, 2), imshow(frame);
        subplot(2, 2, 3), imshow(bw1);
    end
    pause(1);
end
