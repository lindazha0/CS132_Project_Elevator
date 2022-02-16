classdef Elevator < handle
    properties(Access = public)
        id                      % 1, 2
        position = 0            % Floor: -1£¬0,1,2
        state = 0               % 0 for close
        direction = 'idle'      % 'up', 'down', 'idle'
        
        % for timer: accelarate the speed
        height = 0              % h: m
        speed = 0               % m/ s
        acceleration = 3        % m/ s^2 
        maxSpeed = 3;           % m/ s
        destin                  % -1 0 1 2: the next goal to achieve with priority
        task = [0, 0, 0, 0];    % floor[-1 0 1 2] +2 = [1 2 3 4]index
    end
    
    methods
        function obj = Elevator(id)
            obj.id = id;
        end
        
        % move per second
        function move(elevator, t)
            if strcmp(elevator.direction, 'idle')
                return
            end
            pos = elevator.position;
            h = elevator.height;
            switch(elevator.direction)
                case 'up'
                    if(h < 6)% stop when at F3
                        if(elevator.task(pos+3) == 1 && h-pos*3 >= 1.49 && (elevator.speed)^2/elevator.acceleration <= 2*(3*pos+3-h))%3->0
                            newSpeed = elevator.speed - elevator.acceleration*t;
                            elevator.height = h + (elevator.speed + newSpeed)*t /2;
                            elevator.speed = newSpeed;
                            if abs(elevator.height - (pos+1)*3) < 0.001
                                elevator.position = pos +1;
                                elevator.height = elevator.position*3;
                            end
                        elseif( elevator.maxSpeed - elevator.speed > 0.01  ) % 0->3
                            newSpeed = elevator.speed + elevator.acceleration*t;                            
                            elevator.height = h + (elevator.speed + newSpeed)*t /2;
                            elevator.speed = newSpeed;
                        else   % still 3
                            elevator.speed = elevator.maxSpeed;
                            elevator.height = h + elevator.speed*t;
                            if(elevator.height>=0)
                                elevator.position = floor(elevator.height/3);
                            else
                                elevator.position = -floor((-elevator.height)/3);
                            end
                        end
                    end
                    
                case 'down'
                    if(h > -3)
                        if(elevator.task(pos+1)==1 && pos*3-h >= 1.49 && (elevator.speed)^2/elevator.acceleration <= 2*(h-3*pos+3))%-3->0       
                            newSpeed = elevator.speed + elevator.acceleration*t;
                            elevator.height = h + (elevator.speed + newSpeed)*t /2;
                            elevator.speed = newSpeed;
                            if abs(elevator.height - (elevator.position-1)*3) < 0.001
                                elevator.position = pos -1;
                                elevator.height = elevator.position*3;
                            end
                        elseif(elevator.maxSpeed + elevator.speed > 0.01 )% 0->-3
                            newSpeed = elevator.speed - elevator.acceleration*t;                            
                            elevator.height = h + (elevator.speed + newSpeed)*t /2;
                            elevator.speed = newSpeed;
                        else   % -3
                            elevator.speed = -elevator.maxSpeed;
                            elevator.height = elevator.height + elevator.speed*t;
                            if(elevator.height>=0)
                                elevator.position = floor(elevator.height/3);
                            else
                                elevator.position = -floor((-elevator.height)/3);
                            end
                        end
                    end
            end
            fprintf("ele_%d reach h=%d ,floor %d! direction: %s, speed=%d, destin: %d \n", ...
                elevator.id, elevator.height, elevator.position, elevator.direction, elevator.speed, elevator.destin);
             %elevator.task
        end
        
        % go to certain floor, change the direction
        function setDestination(elevator, floor)
            fprintf("set destination for ele_%d to floor %d, floor in [-1 0 1 2]\n", elevator.id, floor);
            elevator.task(floor+2)=1;
            elevator.destin = floor;
            if(elevator.position > floor)                
                elevator.direction = 'down';
            end
            if(elevator.position < floor)
                elevator.direction = 'up';            
            end         
        end
    end
    
end