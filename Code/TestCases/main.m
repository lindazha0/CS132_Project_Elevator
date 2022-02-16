close all;
clear all;

f = 3; % floorHeight f:[-f, 0, f, 2f] -> [-1, 1, 2, 3]
t = 0.5;%Timer Period
openTime = 3;%time pperiod openning the door
ele_1=Elevator(1);% 1: 0 1 2
ele_2=Elevator(2);% 2: -1 0 1 2
control=ElevatorController(f, openTime);
inUI_1=ElevatorInsideUI(control, ele_1, 1);
inUI_2=ElevatorInsideUI(control, ele_2, 2);
outUI_0=ElevatorOutsideUI_B1;
outUI_1=ElevatorOutsideUI_F1_F2("1");
outUI_2=ElevatorOutsideUI_F1_F2("2");
outUI_3=ElevatorOutsideUI_F3;

control.elevator_1 = ele_1;
control.elevator_2 = ele_2;
control.elevatorInUI_1 = inUI_1;
control.elevatorInUI_2 = inUI_2;
control.elevatorOutUI_0 = outUI_0;
control.elevatorOutUI_1 = outUI_1;
control.elevatorOutUI_2 = outUI_2;
control.elevatorOutUI_3 = outUI_3;

outUI_0.Process=control;
outUI_1.Process=control;
outUI_2.Process=control;
outUI_3.Process=control;


control.Timer = timer('ExecutionMode', 'fixedRate', ...    % Run timer repeatedly
    'Period', t, ...                     % Period is 1 second
    'TimerFcn', @control.timerFcn);       % Specify callback function