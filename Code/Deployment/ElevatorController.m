classdef ElevatorController < handle
    properties
        elevator_1
        elevator_2
        elevatorInUI_1
        elevatorInUI_2
        elevatorOutUI_0
        elevatorOutUI_1
        elevatorOutUI_2
        elevatorOutUI_3
        floor % height of a floor
        Timer
        openTime
        task = [0, 0, 0, 0];    % floor[-1 0 1 2] +2 = [1 2 3 4]index. either can finish
     end
    
    methods
        function obj=ElevatorController(floor, openTime)
            obj.floor = floor;
            obj.openTime = openTime;
        end
        
        % start timer
        function startTimer(control)
            % timer
            if ~strcmp(control.Timer.Running,'on')
                fprintf("begin timer!\n");
                start(control.Timer);
            end
        end
        
        % callback when any button pushed: go to certain floor or set task
        function ret = goto(control, id, floor)
            % id = 0 for either elevator to finish the task
            if (floor<-1 || floor >2)
                return;
            end
            
            % begin to go
            switch id
                case 0 % either elevator to finish the task
                    if(control.elevator_1.position==floor)% current floor                        
                        control.openDoorAtFloor(1, floor);
                        ret = 1;
                    elseif(control.elevator_2.position==floor)
                        control.openDoorAtFloor(2, floor);
                        ret = 1;
                    elseif(floor==-1)
                        if strcmp(control.elevator_2.direction, 'idle')
                            control.elevator_2.setDestination(-1);
                        else
                            control.elevator_2.task(1)=1;
                        end
                        ret = 0;
                    else                        
                        if strcmp(control.elevator_1.direction, 'idle')
                            control.elevator_1.setDestination(floor);
                        elseif strcmp(control.elevator_2.direction, 'idle')
                            control.elevator_2.setDestination(floor);
                        else
                            control.task(floor+2)=1;% either can finish
                        end
                        ret = 0;
                    end
                case 1
                    if(control.elevator_1.position==floor)
                        control.openDoorAtFloor(1, floor);
                        ret = 1;
                    else
                        if strcmp(control.elevator_1.direction, 'idle')
                            control.elevator_1.setDestination(floor);
                        else
                            control.elevator_1.task(floor+2)=1;
                        end
                        ret = 0;
                    end
                case 2
                    if(control.elevator_2.position==floor)
                        control.openDoorAtFloor(2, floor);
                        ret = 1;
                    else
                        if strcmp(control.elevator_2.direction, 'idle')
                            control.elevator_2.setDestination(floor);
                        else
                            control.elevator_2.task(floor+2)=1;
                        end
                        ret = 0;
                    end
            end
            control.startTimer();
            
        end

%%%%%%%%%%%%%%%%%%% functions % for % UI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function openDoorAtFloor(control, id, pos)   % pos: -1 0 1 2
            control.startTimer();
            % open door at InUI
            switch id
                case 1
                    control.elevator_1.state = control.elevator_1.state + control.openTime;
                    control.elevatorInUI_1.openDoor();
                case 2
                    control.elevator_2.state = control.elevator_2.state + control.openTime;
                    control.elevatorInUI_2.openDoor();
            end
            % open door at outUI
            switch pos
                case -1
                    control.elevatorOutUI_0.openDoor(id);
                    control.elevatorOutUI_0.switchLamp(id, 'on');
                case 0
                    control.elevatorOutUI_1.openDoor(id);
                    control.elevatorOutUI_1.switchLamp(id, 'on');
                case 1
                    control.elevatorOutUI_2.openDoor(id);
                    control.elevatorOutUI_2.switchLamp(id, 'on');
                case 2
                    control.elevatorOutUI_3.openDoor(id);
                    control.elevatorOutUI_3.switchLamp(id, 'on');
            end 
        end
        
        function pushOpenDoorAtFloor(control, id, pos)
            switch id
                case 1
                    h = control.elevator_1.height;
                    if(h==pos*3)
                        control.openDoorAtFloor(id, pos);
                    elseif strcmp(control.elevator_1.direction, 'up') &&(h>pos*3 && h<pos*3+1.5)
                        control.goto(id, pos+1);
                    elseif strcmp(control.elevator_1.direction, 'up') &&(h>pos*3+1.5 && control.elevator_1.task(pos+3)==0)
                        control.goto(id, pos+2);
                    elseif strcmp(control.elevator_1.direction, 'down') &&(h>pos*3-1.5 && h<pos*3)
                        control.goto(id, pos-1);
                    elseif strcmp(control.elevator_1.direction, 'down') &&(h<pos*3-1.5 && control.elevator_1.task(pos+1)==0)
                        control.goto(id, pos-2);
                    end
                    
                case 2
                    h = control.elevator_2.height;
                    if(h==pos*3)
                        control.openDoorAtFloor(id, pos);
                    elseif strcmp(control.elevator_2.direction, 'up') &&(h>pos*3 && h<pos*3+1.5)
                        control.goto(id, pos+1);
                    elseif strcmp(control.elevator_2.direction, 'up') &&(h>pos*3+1.5 && control.elevator_2.task(pos+3)==0)
                        control.goto(id, pos+2);
                    elseif strcmp(control.elevator_2.direction, 'down') &&(h>pos*3-1.5 && h<pos*3)
                        control.goto(id, pos-1);
                    elseif strcmp(control.elevator_2.direction, 'down') &&(h<pos*3-1.5 && control.elevator_2.task(pos+1)==0)
                        control.goto(id, pos-2);
                    end
            end
            
        end
        
        function closeDoorAtFloor(control, id, pos)   
            % close door at InUI
            switch id
                case 1
                    control.elevator_1.state = 0;
                    control.elevatorInUI_1.closeDoor();
                case 2
                    control.elevator_2.state = 0;
                    control.elevatorInUI_2.closeDoor();
            end
            % close door at outUI and turn off light
            switch pos
                case -1
                    control.elevatorOutUI_0.closeDoor(id);
                    control.elevatorOutUI_0.switchLamp(id, 'off');
                case 0
                    control.elevatorOutUI_1.closeDoor(id);
                    control.elevatorOutUI_1.switchLamp(id, 'off');
                case 1
                    control.elevatorOutUI_2.closeDoor(id);
                    control.elevatorOutUI_2.switchLamp(id, 'off');
                case 2
                    control.elevatorOutUI_3.closeDoor(id);
                    control.elevatorOutUI_3.switchLamp(id, 'off');
            end
        end
       
        % get UI direction
        function ret=getUIDirect(~, dir)
            switch dir
                case 'up'
                    ret = '¡ü';
                case 'down'
                    ret = '¡ý';
                case 'idle'
                    ret = ' '; 
            end
            
        end
        
        % set UI direction
        function updateUIDirect(control)
            tmp = control.elevator_1.direction;
            dir1 = control.getUIDirect(tmp);
            %print(dir1);
            control.elevatorInUI_1.Direct.Value = dir1;
            control.elevatorOutUI_0.LeftDirect.Value = dir1;
            control.elevatorOutUI_1.LeftDirect.Value = dir1;
            control.elevatorOutUI_2.LeftDirect.Value = dir1;
            control.elevatorOutUI_3.LeftDirect.Value = dir1;
            
            tmp = control.elevator_2.direction;
            dir2 = control.getUIDirect(tmp);
            control.elevatorInUI_2.Direct.Value = dir2;
            control.elevatorOutUI_0.RightDirect.Value = dir2;
            control.elevatorOutUI_1.RightDirect.Value = dir2;
            control.elevatorOutUI_2.RightDirect.Value = dir2;
            control.elevatorOutUI_3.RightDirect.Value = dir2;    
        end
        
        % update Button Availability for OutUI
        function updateOutButton(control, pos)
            if (control.task(pos+2)==1)
                switch pos
                    case -1
                        print("finish -1!");
                        if strcmp(control.elevatorOutUI_0.UpButton.Enable, 'off')
                            control.elevatorOutUI_0.UpButton.Enable='on';
                        end
                    case 0
                        if strcmp(control.elevatorOutUI_1.UpButton.Enable, 'off')
                            control.elevatorOutUI_1.UpButton.Enable='on';
                        end
                        if strcmp(control.elevatorOutUI_1.DownButton.Enable, 'off')
                            control.elevatorOutUI_1.DownButton.Enable='on';
                        end
                    case 1
                        if strcmp(control.elevatorOutUI_2.UpButton.Enable, 'off')
                            control.elevatorOutUI_2.UpButton.Enable='on';
                        end
                        if strcmp(control.elevatorOutUI_2.DownButton.Enable, 'off')
                            control.elevatorOutUI_2.DownButton.Enable='on';
                        end
                    case 2
                        if strcmp(control.elevatorOutUI_3.DownButton.Enable, 'off')
                            control.elevatorOutUI_3.DownButton.Enable='on';
                        end
                end
            end
        end
            % update OutUI position with Elevator
        function updateOutUI(control, pos1, pos2)
            % position
            if pos1 > -1
                pos1 = pos1+1;
            end
            if pos2 > -1
                pos2 = pos2+1;
            end
            control.elevatorOutUI_0.LeftPosition.Value = pos1;
            control.elevatorOutUI_1.LeftPosition.Value = pos1;
            control.elevatorOutUI_2.LeftPosition.Value = pos1;
            control.elevatorOutUI_3.LeftPosition.Value = pos1;
            
            control.elevatorOutUI_0.RightPosition.Value = pos2;
            control.elevatorOutUI_1.RightPosition.Value = pos2;
            control.elevatorOutUI_2.RightPosition.Value = pos2;
            control.elevatorOutUI_3.RightPosition.Value = pos2;
        end
        
        % execution per second while working
        function timerFcn(control, ~, ~)
            t = control.Timer.Period;
            
            
            % update position & state only when the door closed
            if(control.elevator_1.state==0)
                control.closeDoorAtFloor(1, control.elevator_1.position);
                control.elevator_1.move(t);
                control.elevatorInUI_1.update();
            else
                control.elevator_1.state = control.elevator_1.state - t;
            end
            if(control.elevator_2.state==0)
                control.closeDoorAtFloor(2, control.elevator_2.position);
                control.elevator_2.move(t);
                control.elevatorInUI_2.update();
            else
                control.elevator_2.state = control.elevator_2.state - t;
            end            
            pos1 = control.elevator_1.position;
            h1 = control.elevator_1.height;
            pos2 = control.elevator_2.position;
            h2 = control.elevator_2.height;
            control.updateOutUI(pos1, pos2);
            control.updateUIDirect();
            
            % if reach a task: open door and flip the task
            if(h1==pos1*3 && control.elevator_1.task(pos1+2)==1 && control.elevator_1.state==0)
                control.openDoorAtFloor(1, pos1);
                control.elevator_1.task(pos1+2)=0;
                control.task(pos1+2)=0;
                control.elevatorInUI_1.enableButton(pos1);
                % Button availability
                control.updateOutButton(pos1);
            end  
            if(h2==pos2*3 && control.elevator_2.task(pos2+2)==1 && control.elevator_2.state==0)
                control.openDoorAtFloor(2, pos2);
                control.elevator_2.task(pos2+2)=0;
                %if(control.elevator_1.task(pos2+2)==0)
                control.task(pos2+2)=0;
                %end
                control.elevatorInUI_2.enableButton(pos2);
                control.updateOutButton(pos2);
            end  
            
            % finish destin: if task    
            if(pos1==control.elevator_1.destin)  
                pos = 2;
                while(pos>-1) % if upper task exist ,go up
                    if (control.elevator_1.task(pos+2)==1)
                        control.elevator_1.setDestination(pos);
                        break;
                    elseif (control.task(pos+2)==1)
                        control.elevator_1.setDestination(pos);
                        control.task(pos+2) = 0;
                        break; 
                    end
                    pos=pos-1;
                end
            end
            if(pos2==control.elevator_2.destin)
                pos=-1;
                while(pos<=2)
                    if (control.elevator_2.task(pos+2)==1)
                        control.elevator_2.setDestination(pos);
                        break;
                    elseif (control.task(pos+2)==1)
                        control.elevator_2.setDestination(pos);
                        control.task(pos+2) = 0;
                        break; 
                    end
                    pos=pos+1;
                end
            end

            % if no task
            if(sum(control.elevator_1.task)==0)
                control.elevator_1.direction='idle';
            end
            if(sum(control.elevator_2.task)==0)
                control.elevator_2.direction='idle';
                %if(strcmp(control.elevator_1.direction,'idle'))
                %    stop(control.Timer);
                %    fprintf("stop timer!\n");
                %end
            end
            control.updateUIDirect();
        end
        
    end
end