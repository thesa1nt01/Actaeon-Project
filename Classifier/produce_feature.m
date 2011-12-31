function ftrs = produce_feature(pts)
%%% Output format is
%%% [p1_x1,p1_y1,p1_x2,p1_y2;p2_x1,p2_y1,p2_x2,p2_y2;...;pn_x1,pn_y1,pn_x2,
%%% pn_y2]

VAR_THRESH = 5;
tmp_pts = zeros(length(pts),2);
%%% If the vector was the wrap around points, rearrange it %%%
if (pts(1,1) ~= 0) && (pts(length(pts),1) ~= 0)
    offset = round(length(pts)/2);
    for ndx = 1:length(pts)
        tmp_pts(ndx,:) = pts(ndx+offset,:);
        if ndx == (offset - 1)
            offset = 1 - offset;
        end
    end
end

%%% Trim Zeros %%%
pts(all(pts==0,2),:) = [];
 
[var_orth_single, Line_single] = isline(pts);
    
%%% Is multiple lines %%%
clusters = k_lines(2,pts);
%%% Cluster structure is
%%% [c1x1,c1y1,c2x1,c2y1,...,cnx1,cny1;c1x2,c1y2,...,cnx2,cny2;...;c1xm,c1
%%% ym,...,cnxm,cnym]
var_orth_mult = zeros(size(clusters,2),1);
Line_mult = zeros(size(clusters,2),4);
%clusters
for ndx = 1:2:size(clusters,2)
    %ndx
    x_vect = clusters(:,ndx);
    y_vect = clusters(:,ndx+1);
    %%% Trim Zeros %%%
    x_vect(all(x_vect==0,2),:) = [];
    y_vect(all(y_vect==0,2),:) = [];
    if (~isempty(x_vect))
        [var_orth_mult((ndx+1)/2),Line_mult(((ndx+1)/2),:)] = isline([x_vect,y_vect]);
    end
end
sum_var_orth_mult = sum(var_orth_mult);
%%% %%%
Line_single
var_orth_single
Line_mult
sum_var_orth_mult
if (var_orth_single < sum_var_orth_mult) && (var_orth_single < VAR_THRESH)
    %%% Plot Single Line
    line([Line_single(1),Line_single(3)],[Line_single(2),Line_single(4)], 'Color', 'r')
    %clusters
elseif (var_orth_mult < VAR_THRESH)
    %%% Plot Multiple Lines %%%
    for l_ndx = 1:size(Line_mult,1)
        line([Line_mult(l_ndx,1),Line_mult(l_ndx,3)],[Line_mult(l_ndx,2),Line_mult(l_ndx,4)], 'Color', 'b')
    end
end
%input('pause: produce_feature 55')
ftrs = 0;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    