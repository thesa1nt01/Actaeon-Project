function map_p = slam(laser_rp,r_pose,map)
scaler = 4;
map_dim = length(map);
window_dim = 3;
angle_increment = 10*(pi/180);
laser_xy = zeros(length(laser_rp),2);
%map_p = zeros(map_dim);
map_p = map;

%%% Calculate occlusion coordinates %%%
for index = 1:length(laser_rp)
    angle = index*angle_increment + r_pose(3);
    x = round( (laser_rp(index)*cos(angle) + r_pose(1))/scaler );
    y = round( (laser_rp(index)*sin(angle) + r_pose(2))/scaler );
    x = x + 15;
    y = y + 15;
    laser_xy(index,:) = [x,y];
end

%%% Update occlusions probabilistically %%%
for occ_ndx = 1:length(laser_xy)
    %%% Check window bounds %%%    
    offset = floor(window_dim/2);
    if (laser_xy(occ_ndx,1) - offset) < 1
         row_min = 1;
    else
         row_min = laser_xy(occ_ndx,1) - offset;
    end
    if (laser_xy(occ_ndx,1) + offset) >= map_dim
         row_max = map_dim;
    else
         row_max = laser_xy(occ_ndx,1) + offset;
    end
    if (laser_xy(occ_ndx,2) - offset) < 1
         col_min = 1;
    else
         col_min = laser_xy(occ_ndx,2) - offset;
    end
    if (laser_xy(occ_ndx,2) + offset) >= map_dim
         col_max = map_dim;
    else
         col_max = laser_xy(occ_ndx,2) + offset;
    end
    %%% Update elements %%%
    for r_ndx = row_min:row_max
         for c_ndx = col_min:col_max        
              sigma = 0.0625;
              mu = sqrt(laser_xy(occ_ndx,1)^2 + laser_xy(occ_ndx,2)^2);
              x = sqrt(r_ndx^2 + c_ndx^2);
              prb = normpdf(x,mu,sigma);
              map(r_ndx, c_ndx) = map(r_ndx, c_ndx) + prb;
         end
    end
        
end

map_p = map;



%%% Normalize Map %%%
% 
% for occ_ndx = 1:length(laser_xy)
%     %%% Check window bounds %%%    
%     offset = floor(window_dim/2);
%     if (laser_xy(occ_ndx,1) - offset) < 1
%          row_min = 1;
%     else
%          row_min = laser_xy(occ_ndx,1) - offset;
%     end
%     if (laser_xy(occ_ndx,1) + offset) >= map_dim
%          row_max = map_dim;
%     else
%          row_max = laser_xy(occ_ndx,1) + offset;
%     end
%     if (laser_xy(occ_ndx,2) - offset) < 1
%          col_min = 1;
%     else
%          col_min = laser_xy(occ_ndx,2) - offset;
%     end
%     if (laser_xy(occ_ndx,2) + offset) >= map_dim
%          col_max = map_dim;
%     else
%          col_max = laser_xy(occ_ndx,2) + offset;
%     end
%     %%% Update element pseudo probability %%%
%     for r_ndx = row_min:row_max
%          for c_ndx = col_min:col_max                        
% %             window = map(row_min:row_max,col_min:col_max);
% %             n = norm(window);
%             map_p(r_ndx, c_ndx) = map(r_ndx, c_ndx) + map_p(r_ndx, c_ndx);
%          end
%     end
%     window = map_p(row_min:row_max,col_min:col_max);
%     n = sum(sum(window));    
%     for r_ndx = row_min:row_max
%          for c_ndx = col_min:col_max                        
%             map_p(r_ndx, c_ndx) = (1/n)*map_p(r_ndx, c_ndx);
%          end
%     end
%     
% end


