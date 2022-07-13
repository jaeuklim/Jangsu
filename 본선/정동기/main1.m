%크로마키 임계값
thdown_blue = [0.55, 0.43, 0.25];
thup_blue = [0.75, 1, 1];

% 드론 행동 결정 표식 HSV 임계값
thdown_red1 = [0, 0.65, 0.25];
thup_red1 = [0.025, 1, 1];
thdown_red2 = [0.975, 0.65, 0.25];
thup_red2 = [1, 1, 1];
thdown_green = [0.25, 40/240, 80/240];         
thup_green = [0.40, 1, 1];
%thdown_green = [0.275, 0.5, 0.25];
%thup_green = [0.325, 1, 1];
thdown_purple = [0.725, 0.25, 0.25];
thup_purple = [0.85, 1, 1];

right_cnt = 0;
left_cnt = 0;
up_cnt = 0;
down_cnt = 0;
level_cnt =1 ;
circle_cnt = 0; % 수정

droneObj = ryze()
cameraObj = camera(droneObj);
takeoff(droneObj);
moveup(droneObj, 'distance', 0.3);

while(1)
    frame = snapshot(cameraObj);
    if sum(frame, 'all') == 0
        disp('frame error!');
        continue;
    end

    src_hsv = rgb2hsv(frame);
    src_h = src_hsv(:,:,1);
    src_s = src_hsv(:,:,2);
    src_v = src_hsv(:,:,3);
    [rows, cols, channels] = size(src_hsv); 
    
    bw1 = (thdown_blue(1) < src_h) & (src_h < thup_blue(1)) & (thdown_blue(2) < src_s) & (src_s < thup_blue(2)); % 파란색 검출

    sumUp = sum(bw1(1:rows/2, :), 'all');             % 상단 절반
    sumDown = sum(bw1(rows/2:end, :), 'all');         % 하단 절반
    sumLeft = sum(bw1(:, 1:cols/2), 'all');           % 좌측 절반
    sumRight = sum(bw1(:, cols/2:end), 'all');        % 우측 절반

    
    if (level_cnt ~= 1)
        if(sumLeft == 0 && sumRight == 0 && level_cnt == 2) % 수정
            disp('2단계 크로마키없음 우측으로 이동');
            moveright(droneObj, 'distance', 0.6);       
            continue;
        elseif(sumLeft == 0 && sumRight == 0 && level_cnt == 3)
            disp('3단계 크로마키없음 위&뒤로 이동');
            moveup(droneObj, 'distance', 0.3);
            moveback(droneObj, 'distance', 0.3);
            continue;
        elseif(sumRight > 1000 && sumLeft==0)
            disp('우측크로마키만 발견 우측으로 이동');
            moveright(droneObj, 'distance', 0.3);
            continue;
        elseif(sumLeft > 1000 && sumRight == 0) 
            disp('좌측크로마키만 발견 좌측으로 이동');         
            moveleft(droneObj, 'distance', 0.3);
            continue;
        else
            if(sumUp == 0)
                disp('아래크로마키만 발견 아래로 이동');
                movedown(droneObj, 'distance', 0.3);
                continue;
            elseif(sumDown==0)
                disp('위크로마키만 발견 위로 이동');
                moveup(droneObj, 'distance', 0.3);
                continue;
            end
        end
    end

    subplot(2, 1, 1), imshow(frame);
    subplot(2, 1, 2), imshow(bw1); 

    
    bw2 = imfill(bw1,'holes');                  % 파란색 배경 안 원을 채움(내부가 채워진 사각형)        
    for row = 1:rows
        for col = 1:cols
            if bw1(row, col) == bw2(row, col)
                bw2(row, col) = 0;
            end
        end
    end
    
    if (sum(bw2, 'all') > 10000 && circle_cnt == 0) %수정
        % Detecting Center
        disp('원검출! 원 센터 좌표 구하기');
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
                
        disp('센터 좌표 확인! 카메라 좌표와 일치화 진행중');
        moveRow = center_row - camera_mid_row;
        moveCol = center_col - camera_mid_col;
    
        subplot(2, 2, 1), imshow(frame);
        subplot(2, 2, 2), imshow(frame); hold on;
        plot(center_col, center_row, 'r*'); hold off;
        subplot(2, 2, 3), imshow(bw1); hold on;
        plot(center_col, center_row, 'r*'); hold off;
        subplot(2, 2, 4), imshow(bw2); hold on;
        plot(center_col, center_row, 'r*'); hold off;
        circle_cnt = 1; % 수정
        %*********************************************여기에 추가함
        while (1)
            frame1 = snapshot(cameraObj);
            if sum(frame1, 'all') == 0
                disp('frame error!');
                continue;
            end
            hsvcount = 0; %수정
            src_hsv = rgb2hsv(frame1);
            disp('frame hsv변환');
            [rows, cols, channels] = size(src_hsv);
            dst_h = src_hsv(:, :, 1);
            dst_s = src_hsv(:, :, 2);
            dst_v = src_hsv(:, :, 3);
            dst_hsv1 = double(zeros(size(dst_h)));
            for row = 1:rows
                for col = 1:cols
                    if thdown_blue(1) < dst_h(row, col) && dst_h(row, col) < thup_blue(1) ...
                    && thdown_blue(2) < dst_s(row, col) && dst_s(row, col) < thup_blue(2) ...
                    && thdown_blue(3) < dst_v(row, col) && dst_v(row, col) < thup_blue(3)
                        dst_hsv1(row, col) = 1;
                    end
                end
            end 
            disp('2중 포문 완료');
            gray = im2gray(dst_hsv1);
            disp('그레이 변환완료');
            canny = edge(gray,'Canny');
            disp('코너함수시작');
            %수정
            if(dst_hsv1(5,5) == 0 && dst_hsv1(5,715) == 0 && dst_hsv1(955,5) == 0 && dst_hsv1(955,715) == 0)
                hsvcount = hsvcount + 1;
            end
            if (hasvcount == 4)
                corners = pgonCorners(canny,4);
                disp('코너 검출완료');
            else
                moveback(droneObj,'Distance',0.2);
                continue;
            end
	        count = 0; %코너 개수 구하기
   	        for i = 1:size(corners)
        	    count = count + 1;
            end
            figure,imshow(canny);
            hold on
            plot(corners(:,2),corners(:,1),'yo','MarkerFaceColor','r',...
            'MarkerSize',12,'LineWidth',2);
            while (1)
                if (corners(1,1) - corners(2,1) >2 || corners(4,1) - corners(3,1) > 2 )
                    disp("왼쪽 각도 회전")
                    turn(droneObj,deg2rad(-3));
                    continue;
                elseif (corners(1,1) - corners(2,1)<-2 || corners(4,1) - corners(3,1) < 2)
                    disp("오른쪽 각도 회전")
                    turn(droneObj,deg2rad(3));
                    continue;
                else
                    disp("correct")
                    cnt = cnt + 1;
                    break;
                end
            end
            if (cnt == 1)
                break;
            end
        end
    elseif (circle_cnt == 0)
            disp('원 미검출, 뒤로 드론 이동');
            moveback(droneObj, 'distance', 0.3);
            moveup(droneObj, 'Distance', 0.2);
            continue;                
    end

    try   
        disp('드론 센터 좌표 맞추기');
        if (-100 < moveRow && moveRow < 100) && (-100 < moveCol && moveCol < 100)
            movedown(droneObj, 'distance', 0.2);
            bw2_pix_num = sum(bw2, 'all')
            if bw2_pix_num >100000
                disp('링 통과 중');
                moveforward(droneObj, 'distance', 0.9);
                moveforward(droneObj, 'distance', 0.9);
                
                while 1
                    disp('표식검출작업 시작');
                    frame = snapshot(cameraObj);
                    if sum(frame, 'all') == 0
                        disp('frame error!');
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
                    bw_green = (thdown_green(1) < src_h) & (src_h < thup_green(1)) & (thdown_green(2) < src_s) & (src_s < thup_green(2));


                    subplot(2, 2, 1), imshow(frame);
                    subplot(2, 2, 2), imshow(bw_red);
                    subplot(2, 2, 2), imshow(bw_green);
                    subplot(2, 2, 4), imshow(bw_purple);

                    
                    red = sum(bw_red, 'all')
                    green = sum(bw_green, "all")
                    purple = sum(bw_purple, 'all')
                    
                    if(sum(bw_red, 'all') > 2000 && level_cnt == 3) %수정: 1단계      
                        disp('빨간색 검출! 우회전!');
                        sum(bw_red, 'all')
                        level_cnt = 2; % 이부분 수정
                        turn(droneObj, deg2rad(90));                  
                        moveforward(droneObj, 'distance', 1.1);
                        loopBreak = 1;
                        circle_cnt = 0; %수정
                        break;                        
                    elseif(sum(bw_green, "all")>3200 && level_cnt == 2) %수정
                        disp('초록색 검출! 각도 변경!')
                        sum(bw_green, "all")
                        level_cnt = 3; %수정
                        turn(droneObj, deg2rad(90));
                        moveforward(droneObj, 'distance', 1.1);
                        turn(droneObj, deg2rad(45));
                        moveforward(droneObj, 'distance', 0.4);
                        activeForward = 1;
                        loopBreak = 1;
                        cnt = 0;
                        circle_cnt = 0; % 수정
                        break;
                    elseif (sum(bw_purple, 'all') > 3000 && level_cnt == 1)     %수정
                        sum(bw_purple, 'all')
                        disp('보라색 검출! 착지!');
                        land(droneObj);                                  
                    elseif(level_cnt == 1 && sum(bw_red, "all") == 0)
                        disp("빨강 표식 검출 불가!! 조금뒤로")
                        moveback(droneObj, 'Distance',0.2);
                    elseif(level_cnt == 2 && sum(bw_green, "all")==0)
                        disp("초록 표식 검출 불가!! 조금뒤로")
                        moveback(droneObj, 'Distance',0.2);
                    elseif(level_cnt == 3 && sum(bw_purple, "all")==0)
                        disp("보라 표식 검출 불가!! 조금뒤로")
                        moveback(droneObj, 'Distance',0.2);
                    else                        
                        disp("표식을 향해 전진중")
                        moveforward(droneObj,'Distance',0.2);               
                    end
                end

                if loopBreak == 1
                    loopBreak = 0;
                    continue
                end
                

            elseif (bw2_pix_num > 70000)
                disp('원에 좀 더 접근중');
                moveforward(droneObj, 'distance', 0.4); % 맵에 따라서 1m단위로 링을 배치한다면 0.5, 아니라면 0.2 or 0.25
            elseif (bw2_pix_num > 40000)
                disp("원에 조금씩 접근중")
                moveforward(droneObj, 'Distance', 0.4);
            elseif (bw2_pix_num < 40000)
                disp('원에 1m 접근');
                moveforward(droneObj, 'distance', 1.0);
            end      
            
        elseif moveRow < -100
            disp('좌표 일치화 진행중, MoveUp');
            moveup(droneObj, 'Distance', 0.2)
        elseif 100 < moveRow
            disp('좌표 일치화 진행중, MoveDown');
            movedown(droneObj, 'Distance', 0.2)
        elseif moveCol < -100
            disp('좌표 일치화 진행중, MoveLeft');
            moveleft(droneObj, 'Distance', 0.2)
        elseif 100 < moveCol
            disp('좌표 일치화 진행중, MoveRight');
            moveright(droneObj, 'Distance', 0.2)
        end

        disp('원 검출 완료');
        clear center_col;
        clear center_row;
        clear bw2;
   catch exception
        disp('예외발생. 드론 후진');
        moveback(droneObj, 'distance', 0.2);
        subplot(2, 2, 1), imshow(frame);
        subplot(2, 2, 2), imshow(frame);
        subplot(2, 2, 3), imshow(bw1);
    end
    
    disp('while문 도는중');
end

disp('코드 종료');