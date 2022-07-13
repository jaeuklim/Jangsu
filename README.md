### Team 장수말벌

***

### [✔ 대회 진행 전략]
- 팀 결성 이후 빠른 온라인 만남을 통해 각 팀원들의 프로젝트 경험 여부 및 대체적인 역량을 파악 후 전체적인 진행 방향 설정
- 매 워크샵 과제 부여 후 각자의 역할을 분담하고 필요에 따라서는 오프라인으로 만나 검증하는 등 팀 프로젝트 형식으로 수행
- 각자 맡은 기능 개발이 완료되면 각자의 Branch를 통해 코드 업로드 및 Pull Request를 요청하여 팀장으로부터 피드백 후 수정 및 Merge
- 작년 대회내용을 기반으로 핵심 알고리즘을 미리 조사해오는 방식으로 본선 준비
- 크로마키 검출 여부 및 크로마키 속 링 검출을 통해 드론을 링 중점에 맞추는 방식으로 진행
- 각 단계 진행시 cut-off time 체크 후 최단시간 통과를 위해 효율적인 드론 제어 및 코드 최적화 수행

***

### [✔ 알고리즘 설명]
1. 임계값 기반 크로마키 컬러 추출
* 크로마키 천, 표식에 대한 임계값 범위를 각각의 변수에 저장.
* 드론 캠을 통해 들어오는 실시간 영상을 frame 단위로 저장해 hsv로 변환후 처리.

2. 전처리한 크로마키의 분포가 상하좌우에 모두 분포하도록 드론 제어
* 크로마키 임계값 범위에 해당하는 이미지만 따로 저장하여 해당 임계값(blue)에 해당하는 픽셀들 검출
* frame의 4분면에 크로마키가 존재하도록 조금씩 드론 이동
  
3. 크로마키 속 링 추출
* 4분면에 크로마키가 존재하면 imfill 함수를 통해 링 검출 및 원 채우기
* 만약 원이 검출 되지 않으면 드론과 크로마키의 거리조절을 통해 최소 거리로 이동
  
4. 원의 센터 좌표 검출 후 드론의 센터값과 일치화
* 원이 검출되면 원에 해당하는 픽셀들의 좌표를 더하고 픽셀수를 나누는 방법으로 원의 센터좌표 검출
* 원의 센터좌표와 드론 센터좌표의 차를 이용하여 드론을 미세조정. 
  
5. 드론 전진 및 링 통과
* 드론과 원의 중앙 좌표 차가 오차 범위에 들어오면 조금씩 드론 전진
* 전진 후 4,5번 원 검출 및 센터일치화 작업을 반복하며 크로마키와 드론을 일정거리까지 전진
* 크로마키와 일정거리까지 드론이 접근하면 링 근처까지 드론 이동
* 표식을 검출할 때까지 전진 후 정지
* 드론이 원의 중앙점 오차허용 범위에 위치하지 않으면 드론 미세조정  

6. 링 통과 및 표식 접근
* 표식이 검출되면 조금씩 전진하며 링을 완전히 통과
* 표식이 일정 픽셀 이상 검출 되지 않으면 전진
* 표식이 아예 검출 되지 않으면 일정거리 후진하며 표식 탐색.
 
7. 표식에 따른 드론 행동 결정
* 검출된 표식의 픽셀값이 일정 개수 이상이면 정지.
* 검출된 표식의 컬러값에 따라 좌회전 or 각도변경 or 착륙 행동 수행
* 프로그램 종료.  

### [✔ 소스 코드 설명]
1. 임계값 기반 크로마키 컬러 추출
* 크로마키 천, 표식에 대한 임계값 범위를 각각의 변수에 저장.
주최측에서 올려준 rgb값을 그림판에서 hsv값으로 변경하여 값을 넣어주었다.
```matlab
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
thdown_purple = [0.725, 0.25, 0.25];
thup_purple = [0.85, 1, 1];
```
* 드론 캠을 통해 들어오는 실시간 영상을 frame 단위로 저장해 hsv로 변환후 처리.
위에서 변수에 받은 색깔을 hsv로 변경해주었으니 거기에 맞추서 드론이 찍은 사진을 rgb2hsv() 함수를 이용하여 바꾸어 주었다. 만약 사진이 찍히지 않았다면 다시 찍을 수 있도록하여 에러를 예방하였다.
```matlab
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
```
2. 전처리한 크로마키의 분포가 상하좌우에 모두 분포하도록 드론 제어
* 크로마키 임계값 범위에 해당하는 이미지만 따로 저장하여 해당 임계값(blue)에 해당하는 픽셀들 검출
드론으로 찍은 사진을 hsv로 변환을 하였으니 위에서 변수에 넣어준 천과 표식에 대한 임계값 안에 들어갈 수 있도록 if문을 이용하여 h,s,v값이 임계값 내부에 들어갈 수 있도록 하여주었다.
```matlab
bw1 = (thdown_blue(1) < src_h) & (src_h < thup_blue(1)) & (thdown_blue(2) < src_s) & (src_s < thup_blue(2)); % 파란색 검출
```
* frame의 4분면에 크로마키가 존재하도록 조금씩 드론 이동
여기서 4분면은 (상, 하, 좌, 우)를 뜻함
frame의 상, 하, 좌, 우에 임계값(blue)의 픽셀이 얼마나 있는지 파악한 후 그 합을 변수에 저장
if문을 사용하여 각 단계별, 상황별로 나눔
임계값이 발견된 곳이 존재한다면, 발견된 방향으로 드론을 움직임
(만약, 우측에 임계값 픽셀이 존재한다면 우측으로 이동)

```matlab
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

```



3.크로마키 속 링 추출
* 4분면에 크로마키가 존재하면 imfill 함수를 통해 링 검출 및 원 채우기

```matlab
bw2 = imfill(bw1,'holes');
```

* 만약 원이 검출 되지 않으면 드론과 크로마키의 거리조절을 통해 최소 거리로 이동
원이 검출 되지 않은 상황을 원과 드론의 거리가 너무 가깝다고 가정한 후 뒤로 이동 후, 드론 카메라의 렌즈 위치를 고려해 위로 이동

```matlab
circle_cnt = circle_cnt + 1;
            disp('원 미검출, 뒤로 드론 이동');
            moveback(droneObj, 'distance', 0.3);
            if(circle_cnt <= 2) %수정
                moveup(droneObj, 'Distance', 0.2);
            end
            continue;    

```
