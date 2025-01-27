cla, clc, clear
hold all

%%% Field Walls are set up here as a list of line segments %%%
max_dim = 248; % Maximum field dimensions in centimeters
axis([-20,max_dim+20,-20,max_dim+20])
axis square

% Wall structure [x1,y1;x2,y2] end points of line segment
outer_wall1 = [0,0;0,max_dim];
outer_wall2 = [0,0;max_dim,0];
outer_wall3 = [0,max_dim;max_dim,max_dim];
outer_wall4 = [max_dim,0;max_dim,max_dim];
outer_walls = [outer_wall1;outer_wall2;outer_wall3;outer_wall4];

island_wall1 = [202,137;202,202];
island_wall2 = [118,137;118,202];
island_wall3 = [118,202;202,202];
island_wall4 = [164,137;202,137];
island_walls = [island_wall1;island_wall2;island_wall3;island_wall4];

lr_wall1 = [118,91;max_dim,91];
lr_wall2 = [118,45;118,0];
lr_walls = [lr_wall1;lr_wall2];

ll_wall1 = [0,103;72,103];
ll_wall2 = [72,103;72,46];
ll_walls = [ll_wall1;ll_wall2];

ur_wall1 = [72,157;72,max_dim];
ur_wall2 = [46,157;72,157];
ur_walls = [ur_wall1;ur_wall2];

field_walls = [outer_walls;island_walls;lr_walls;ll_walls;ur_walls];

%%% Initialization parameters for robot and sensor %%%
r_pose_start = [100,225,(pi/180)*(-90)]; % Starting pose of the robot
r_pose = r_pose_start;
num_readings = 36; % Number of sensor readings
angle_increment = 10*(pi/180); % Angular displacement between readings in radians
v = 0;  % Linear Velocity, cm/sec
om = 0; % Angular Velocity, rad/sec
dt = 0.25; % Time step
pause(1)

% *** ITERATE THROUGH POSITIONS *** %
for t = 0:dt:5000
    cla
    laser_r = ones(length(field_walls)/2,num_readings);
    laser_r = laser_r.*1e3;

    for index = 1:num_readings
        angle = index*angle_increment + r_pose(3);
        for iter = 1:2:length(field_walls) % USING ASSUMPTION OF PARALLEL AND PERPENDICULAR WALLS
             if field_walls(iter,1) == field_walls(iter+1,1) % x components are the same
                 x_wall = field_walls(iter,1);
                 y_wall_proj = tan(angle)*(x_wall - r_pose(1)) + r_pose(2);
                 y_wall_max = max([field_walls(iter,2),field_walls(iter+1,2)]);
                 y_wall_min = min([field_walls(iter,2),field_walls(iter+1,2)]);
                 if (sign(cos(angle)) == sign(x_wall - r_pose(1))) || (tan(angle) > 1e10)
                     if (y_wall_proj <= y_wall_max) && (y_wall_proj >= y_wall_min) % if the projection lands on the wall
                        laser_r((iter+1)/2,index) = sqrt((x_wall - r_pose(1)).^2 + (y_wall_proj - r_pose(2)).^2);
                        %line(field_walls(iter:iter+1,1),field_walls(iter:iter+1,2),'Color','g')
                        %plot(x_wall, y_wall_proj,'r+')
                     end
                 end
             else % y components are the same
                 y_wall = field_walls(iter,2);
                 x_wall_proj = (y_wall - r_pose(2))/tan(angle) + r_pose(1);
                 x_wall_max = max([field_walls(iter,1),field_walls(iter+1,1)]);
                 x_wall_min = min([field_walls(iter,1),field_walls(iter+1,1)]);
                 if (sign(sin(angle)) == sign(y_wall - r_pose(2))) || (tan(angle) > 1e10)
                     if (x_wall_proj <= x_wall_max) && (x_wall_proj >= x_wall_min) % if the projection lands on the wall
                         if (angle == 90*(pi/180)) && (y_wall < r_pose(2))
                             continue 
                         end
                         if (angle == 270*(pi/180)) && (y_wall > r_pose(2))
                             continue 
                         end
                         laser_r((iter+1)/2,index) = sqrt((y_wall - r_pose(2)).^2 + (x_wall_proj - r_pose(1)).^2);
                         %line(field_walls(iter:iter+1,1),field_walls(iter:iter+1,2),'Color','r')
                         %plot(x_wall_proj, y_wall,'g+')
                     end
                 end
             end
        end
    end

    laser_rp = zeros(1,num_readings);
    for index = 1:num_readings
        laser_rp(index) = min(laser_r(:,index));
            laser_rp(index) = laser_rp(index) + 2*rand(1);
    end

    laser_xy = zeros(num_readings,2);
    for index = 1:num_readings
        angle = index*angle_increment + r_pose(3);
        laser_xy(index,:) = [laser_rp(index)*cos(angle) + r_pose(1),laser_rp(index)*sin(angle) + r_pose(2)];
    end

    %%% PLOT LASER LINES %%%
    for index = 1:num_readings
        % Show all laser lines
        %line([r_pose(1),laser_xy(index,1)],[r_pose(2),laser_xy(index,2)],'Color','r')
        % Show laser dots
        plot(laser_xy(:,1),laser_xy(:,2), 'b.')
    end
    %%% Show special laser lines in different colors %%%
    line([r_pose(1),laser_xy(36,1)],[r_pose(2),laser_xy(36,2)], 'Color','g') % Heading beam
    for index = [31] % To add laser lines to display enter their index in the square bracket
        line([r_pose(1),laser_xy(index,1)],[r_pose(2),laser_xy(index,2)], 'Color','r')
    end
    
    %%% DRAW WALLS %%%
    for iter = 1:2:length(field_walls)
        line(field_walls(iter:iter+1,1),field_walls(iter:iter+1,2))
    end
    %%% PLOT ROBOT %%%
    plot(r_pose(1),r_pose(2),'ko')


    
    % *** Potential Field Navigation *** %
	vp = v;
    omp = om;
    [v, om] = PocLoc1(laser_rp);
    
    %%% MOTION NOISE %%%
    v = v + .2*rand(1);
    om = om + .01*rand(1);
    
    %%% MOTION DAMPENING %%%
    v = 0.1*v + 0.9*vp;
    om = 0.1*om + 0.9*omp;
    
    %%% MOTION MODEL %%%
    r_pose(3) = r_pose(3) + om*dt;
    r_pose(1) = r_pose(1) + v*cos(r_pose(3));
    r_pose(2) = r_pose(2) + v*sin(r_pose(3));
    
    pause(1/256)
end










