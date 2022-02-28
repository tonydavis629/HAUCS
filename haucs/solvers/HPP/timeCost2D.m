


function [cost] = timeCost2D(Path, transl_spd, rot_spd, q_current)
% transl_spd in meter per second
% rot_spd in radians per second
    cost = 0;
    q_t = q_current;
    [n, d] = size(Path);
    
    for i=1:n
        q_goal = Path(i,:);
        
        if q_t(1:d) ~= q_goal
            % rotate
            theta_g = atan2( q_goal(2)-q_t(2), q_goal(1)-q_t(1));
            % find the shortest rotation
            theta_delta = minRotation(q_t(3),theta_g); 
            if(abs(theta_delta)>pi)
              pause;
            end
            time = abs(theta_delta)/rot_spd;
            cost = cost + time;
            
            %translate
            dist = norm(q_goal-q_t(1:d));
            time = dist / transl_spd;
            cost = cost + time;
            
            %update
            q_t = [q_goal theta_g];
        end    
    end
    
    %finally rotate to the initial orientation
    theta_g = q_current(3);
    theta_delta = minRotation(q_t(3),theta_g);            
    time = abs(theta_delta)/rot_spd;
    cost = cost + time;
end

function theta_dif = minRotation(theta, theta_goal)
    if theta_goal > 0
        if theta > 0
            theta_dif = theta_goal-theta;
        else
            theta_dif = minR(theta_goal-theta, theta_goal-(2*pi+theta));
        end
    else
        if theta > 0
            theta_dif = minR(theta_goal-theta, (2*pi+theta_goal)-theta);
        else
            theta_dif = theta_goal - theta;
        end
    end
end

function c = minR(a,b)
    if abs(a) < abs(b)
        c = a;
    else
        c = b;
    end
end