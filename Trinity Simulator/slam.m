function map_p = slam(laser_rp,r_pose,map)
scaler = 8;
map_dim = length(map);
window_dim = 3;
angle_increment = 10*(pi/180);
laser_xy = zeros(length(laser_rp),2);
%map_p = zeros(length(map));
map_p = map;

% 
% %%% Smooth map (motion uncertainty) %%%
% for map_ndx_row = 1:length(map)
%     for map_ndx_col = 1:length(map)
%         offset = floor(window_dim/2);
%         if (map_ndx_row - offset) < 1
%             row_min = 1;
%         else
%             row_min = map_ndx_row - offset;
%         end
%         if (map_ndx_row + offset) >= length(map)
%             row_max = length(map);
%         else
%             row_max = map_ndx_row + offset;
%         end
%         if (map_ndx_col - offset) < 1
%             col_min = 1;
%         else
%             col_min = map_ndx_col - offset;
%         end
%         if (map_ndx_col + offset) >= length(map)
%             col_max = length(map);
%         else
%             col_max = map_ndx_col + offset;
%         end
%         window = map(row_min:row_max,col_min:col_max);
%         map_p(map_ndx_row, map_ndx_col) = mean(mean(window));
%     end
% end
%

%%% Calculate occlusion coordinates %%%
for index = 1:length(laser_rp)
    angle = index*angle_increment + r_pose(3);
    x = ceil( (laser_rp(index)*cos(angle) + r_pose(1))/scaler );
    y = ceil( (laser_rp(index)*sin(angle) + r_pose(2))/scaler );
    x = x + 15;
    y = y + 15;
    laser_xy(index,:) = [x,y];
end

%%% Increase occlusion probability %%%
for index = 1:length(laser_rp)
    x = laser_xy(index,1);
    y = laser_xy(index,2);
    if ((x >= 1)&&(x <= map_dim)) && ((y >= 1)&&(y <= map_dim))
        map_p(laser_xy(index,1), laser_xy(index,2)) = map_p(laser_xy(index,1), laser_xy(index,2)) + 1;
    end
end

map_p = map_p/norm(map_p);

x_r = ceil(r_pose(1)/scaler) + 15;
y_r = ceil(r_pose(2)/scaler) + 15;
%map_p(x_r,y_r) = -1;