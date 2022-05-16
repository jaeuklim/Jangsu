%mini-drone 2차과제 코드.

droneobj = ryze();

takeoff(droneobj);

moveleft(droneobj, 'Distance', 1.5);

turn(droneobj, deg2rad(45));

moveforward(droneobj, 'Distance', 2.1);

turn(droneobj, deg2rad(135));

moveforward(droneobj, 'Distance', 1.5);

land(droneobj);