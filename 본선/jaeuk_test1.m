%크로마키 임계값
thdown_blue = [0.55, 0.43, 0.25];
thup_blue = [0.75, 1, 1];

drone = ryze();
cameraObj = camera(drone);
takeoff(drone);
%moveup(drone, 'distance', 0.4);


while(1)
    frame = snapshot(cameraObj);
    subplot(2,1,1), imshow(frame);

    frame_hsv = rgb2hsv(frame);
    subplot(2,1,2), imshow(frame_hsv);

end

%land(droneObj);