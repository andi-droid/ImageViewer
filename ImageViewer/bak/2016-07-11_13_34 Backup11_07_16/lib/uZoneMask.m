%[BW] = uMaskBrillouinZone(whichZone, size_Y, size_X, center_Y, center_X, LatticeVectorLength, Adjustment)
%
%This function creates an empty mask (2D array of size_X and size_Y)
%with ones within the area of the specified Brillouin zone and zeroes
%everywhere else.
%
%Multiply this black & white image 'BW' elementwise with your data image.
%
%'Adjustment refers to a slight deforming of the the zone, so that no
%empty spaces emerge after folding higher zones back into the 1st zone.
%Usually Adjustment = 1 should be sufficient.

function [ BW ] = uZoneMask(whichZone, size_Y, size_X, center_Y, center_X, LatticeVectorLength, Adjustment)

lvl = LatticeVectorLength;
adj_zones = Adjustment;

emptyMask(1:size_Y,1:size_X) = NaN;


if whichZone == 1
    
    A1x = zeros(1,7);
    A1y = zeros(1,7);
    R1 = lvl/2/sind(60);
    for j = 1:6
        A1x(1,j) = R1*cosd(j*60)+center_X;
        A1y(1,j) = R1*sind(j*60)+center_Y;
    end
    A1x(1,7) = A1x(1,1);
    A1y(1,7) = A1y(1,1);
    A1x1 = A1x(1,:);
    A1y1 = A1y(1,:);
    BW = roipoly(emptyMask, A1x1, A1y1);
    
end


if whichZone == 2
    
    A2x = zeros(6,4);
    A2y = zeros(6,4);
    for l = 1:6
        for j = 0:2
            if j == 1
                R2 = lvl;
            else R2 = lvl/2/sind(60);
            end
            A2x(l,j+1) = R2*cosd(l*60+j*30)+center_X;
            A2y(l,j+1) = R2*sind(l*60+j*30)+center_Y;
        end
        A2x(l,4) = A2x(l,1);
        A2y(l,4) = A2y(l,1);
    end
    A2x1 = A2x(1,:);
    A2y1 = A2y(1,:);
    A2x2 = A2x(2,:);
    A2y2 = A2y(2,:);
    A2x3 = A2x(3,:);
    A2y3 = A2y(3,:);
    A2x4 = A2x(4,:);
    A2y4 = A2y(4,:);
    A2x5 = A2x(5,:);
    A2y5 = A2y(5,:);
    A2x6 = A2x(6,:);
    A2y6 = A2y(6,:);
    BW1 = roipoly(emptyMask, A2x1, A2y1);
    BW2 = roipoly(emptyMask, A2x2, A2y2);
    BW3 = roipoly(emptyMask, A2x3, A2y3);
    BW4 = roipoly(emptyMask, A2x4, A2y4);
    BW5 = roipoly(emptyMask, A2x5, A2y5);
    BW6 = roipoly(emptyMask, A2x6, A2y6);
    BW = BW1+BW2+BW3+BW4+BW5+BW6;
    
end


if whichZone == 3
    
    A3_1x = zeros(6,4);
    A3_1y = zeros(6,4);
    for l = 1:6
        % j is index for the points defining triangles
        for j = 1:3
            if j == 1
                R3 = lvl;
                % jf is the angle factor corresponding to the point defined
                % by j
                jf = 1;
            elseif j == 2
                % -adj_zones for compensation of inaccuracy due to finite pixel
                % resolution
                R3 = lvl/2/sind(60)-adj_zones;
                jf = 0;
            elseif j == 3
                % +adj_zones for compensation of inaccuracy due to finite pixel
                % resolution
                R3 = lvl*sqrt(1/4*(cosd(30))^2+1/4*(sind(30))^2+1-sind(30))+adj_zones;
                jf = 0;
            end
            A3_1x(l,j) = R3*cosd(l*60+jf*30)+center_X;
            A3_1y(l,j) = R3*sind(l*60+jf*30)+center_Y;
        end
        A3_1x(l,4) = A3_1x(l,1);
        A3_1y(l,4) = A3_1y(l,1);
    end
    
    A3_2x = zeros(6,4);
    A3_2y = zeros(6,4);
    for l = 1:6
        % j is index for the points defining triangles
        for j = 1:3
            if j == 1
                R3 = lvl;
                % jf is the angle factor corresponding to the point defined
                % by j
                jf = -1;
            elseif j == 2
                R3 = lvl/2/sind(60)-adj_zones;
                jf = 0;
            elseif j == 3
                R3 = lvl*sqrt(1/4*(cosd(30))^2+1/4*(sind(30))^2+1-sind(30))+adj_zones;
                jf = 0;
            end
            A3_2x(l,j) = R3*cosd(l*60+jf*30)+center_X;
            A3_2y(l,j) = R3*sind(l*60+jf*30)+center_Y;
        end
        A3_2x(l,4) = A3_2x(l,1);
        A3_2y(l,4) = A3_2y(l,1);
    end
    A3_1x1 = A3_1x(1,:);
    A3_1y1 = A3_1y(1,:);
    A3_1x2 = A3_1x(2,:);
    A3_1y2 = A3_1y(2,:);
    A3_1x3 = A3_1x(3,:);
    A3_1y3 = A3_1y(3,:);
    A3_1x4 = A3_1x(4,:);
    A3_1y4 = A3_1y(4,:);
    A3_1x5 = A3_1x(5,:);
    A3_1y5 = A3_1y(5,:);
    A3_1x6 = A3_1x(6,:);
    A3_1y6 = A3_1y(6,:);
    A3_2x1 = A3_2x(1,:);
    A3_2y1 = A3_2y(1,:);
    A3_2x2 = A3_2x(2,:);
    A3_2y2 = A3_2y(2,:);
    A3_2x3 = A3_2x(3,:);
    A3_2y3 = A3_2y(3,:);
    A3_2x4 = A3_2x(4,:);
    A3_2y4 = A3_2y(4,:);
    A3_2x5 = A3_2x(5,:);
    A3_2y5 = A3_2y(5,:);
    A3_2x6 = A3_2x(6,:);
    A3_2y6 = A3_2y(6,:);
    BW1 = roipoly(emptyMask, A3_1x1, A3_1y1);
    BW2 = roipoly(emptyMask, A3_1x2, A3_1y2);
    BW3 = roipoly(emptyMask, A3_1x3, A3_1y3);
    BW4 = roipoly(emptyMask, A3_1x4, A3_1y4);
    BW5 = roipoly(emptyMask, A3_1x5, A3_1y5);
    BW6 = roipoly(emptyMask, A3_1x6, A3_1y6);
    BW7 = roipoly(emptyMask, A3_2x1, A3_2y1);
    BW8 = roipoly(emptyMask, A3_2x2, A3_2y2);
    BW9 = roipoly(emptyMask, A3_2x3, A3_2y3);
    BW10 = roipoly(emptyMask, A3_2x4, A3_2y4);
    BW11 = roipoly(emptyMask, A3_2x5, A3_2y5);
    BW12 = roipoly(emptyMask, A3_2x6, A3_2y6);
    BW = BW1+BW2+BW3+BW4+BW5+BW6+BW7+BW8+BW9+BW10+BW11+BW12;
    
end


if whichZone == 4
    
    A4_1x = zeros(6,4);
    A4_1y = zeros(6,4);
    for l = 1:6
        % j is index for the points defining triangles
        for j = 1:3
            if j == 1
                R4 = lvl;
                % jf is the angle factor corresponding to the point defined
                % by j
                jf = 1;
            elseif j == 2
                R4 = lvl*(2*sind(60)- 1/2/sind(60))+2*adj_zones;
                jf = 0;
            elseif j == 3
                R4 = lvl*sqrt(1/4*(cosd(30))^2+1/4*(sind(30))^2+1-sind(30))-2*adj_zones;
                jf = 0;
            end
            A4_1x(l,j) = R4*cosd(l*60+jf*30)+center_X;
            A4_1y(l,j) = R4*sind(l*60+jf*30)+center_Y;
        end
        A4_1x(l,4) = A4_1x(l,1);
        A4_1y(l,4) = A4_1y(l,1);
    end
    
    A4_2x = zeros(6,4);
    A4_2y = zeros(6,4);
    for l = 1:6
        % j is index for the points defining triangles
        for j = 1:3
            if j == 1
                R4 = lvl;
                % jf is the angle factor corresponding to the point defined
                % by j
                jf = -1;
            elseif j == 2
                R4 = lvl*(2*sind(60)- 1/2/sind(60))+2*adj_zones;
                jf = 0;
            elseif j == 3
                R4 = lvl*sqrt(1/4*(cosd(30))^2+1/4*(sind(30))^2+1-sind(30))-2*adj_zones;
                jf = 0;
            end
            A4_2x(l,j) = R4*cosd(l*60+jf*30)+center_X;
            A4_2y(l,j) = R4*sind(l*60+jf*30)+center_Y;
        end
        A4_2x(l,4) = A4_2x(l,1);
        A4_2y(l,4) = A4_2y(l,1);
    end
    A4_1x1 = A4_1x(1,:);
    A4_1y1 = A4_1y(1,:);
    A4_1x2 = A4_1x(2,:);
    A4_1y2 = A4_1y(2,:);
    A4_1x3 = A4_1x(3,:);
    A4_1y3 = A4_1y(3,:);
    A4_1x4 = A4_1x(4,:);
    A4_1y4 = A4_1y(4,:);
    A4_1x5 = A4_1x(5,:);
    A4_1y5 = A4_1y(5,:);
    A4_1x6 = A4_1x(6,:);
    A4_1y6 = A4_1y(6,:);
    A4_2x1 = A4_2x(1,:);
    A4_2y1 = A4_2y(1,:);
    A4_2x2 = A4_2x(2,:);
    A4_2y2 = A4_2y(2,:);
    A4_2x3 = A4_2x(3,:);
    A4_2y3 = A4_2y(3,:);
    A4_2x4 = A4_2x(4,:);
    A4_2y4 = A4_2y(4,:);
    A4_2x5 = A4_2x(5,:);
    A4_2y5 = A4_2y(5,:);
    A4_2x6 = A4_2x(6,:);
    A4_2y6 = A4_2y(6,:);
    BW1 = roipoly(emptyMask, A4_1x1, A4_1y1);
    BW2 = roipoly(emptyMask, A4_1x2, A4_1y2);
    BW3 = roipoly(emptyMask, A4_1x3, A4_1y3);
    BW4 = roipoly(emptyMask, A4_1x4, A4_1y4);
    BW5 = roipoly(emptyMask, A4_1x5, A4_1y5);
    BW6 = roipoly(emptyMask, A4_1x6, A4_1y6);
    BW7 = roipoly(emptyMask, A4_2x1, A4_2y1);
    BW8 = roipoly(emptyMask, A4_2x2, A4_2y2);
    BW9 = roipoly(emptyMask, A4_2x3, A4_2y3);
    BW10 = roipoly(emptyMask, A4_2x4, A4_2y4);
    BW11 = roipoly(emptyMask, A4_2x5, A4_2y5);
    BW12 = roipoly(emptyMask, A4_2x6, A4_2y6);
    BW = BW1+BW2+BW3+BW4+BW5+BW6+BW7+BW8+BW9+BW10+BW11+BW12;
    
end


if whichZone == 5
    
  A5_1x = zeros(6,4);
    A5_1y = zeros(6,4);
    for l = 1:6
        for j = 1:2
            if j == 1
                R5 = lvl*(2*sind(60)- 1/2/sind(60));
            else R5 = lvl;
            end
            A5_1x(l,j) = R5*cosd(l*60+(j-1)*30)+center_X;
            A5_1y(l,j) = R5*sind(l*60+(j-1)*30)+center_Y;
        end
        % radius for farthest point
        R5 = sqrt((lvl/4)^2+(3/2*lvl*sind(60))^2)+2*adj_zones;
        % angle for furthest point
        j = atand(1/6/sind(60));
        A5_1x(l,3) = R5*cosd(l*60+j)+center_X;
        A5_1y(l,3) = R5*sind(l*60+j)+center_Y;
        R5 = lvl*(2*sind(60)- 1/2/sind(60));
        A5_1x(l,4) = A5_1x(l,1);
        A5_1y(l,4) = A5_1y(l,1);
    end
    
    A5_2x = zeros(6,4);
    A5_2y = zeros(6,4);
    for l = 1:6
        for j = 1:2
            if j == 1
                R5 = lvl*(2*sind(60)- 1/2/sind(60));
            else R5 = lvl;
            end
            A5_2x(l,j) = R5*cosd(l*60-(j-1)*30)+center_X;
            A5_2y(l,j) = R5*sind(l*60-(j-1)*30)+center_Y;
        end
        % radius for farthest point
        R5 = sqrt((lvl/4)^2+(3/2*lvl*sind(60))^2);
        % angle for furthest point
        j = -atand(1/6/sind(60));
        A5_2x(l,3) = R5*cosd(l*60+j)+center_X;
        A5_2y(l,3) = R5*sind(l*60+j)+center_Y;
        R5 = lvl*(2*sind(60)- 1/2/sind(60));
        A5_2x(l,4) = A5_2x(l,1);
        A5_2y(l,4) = A5_2y(l,1);
    end
    A5_1x1 = A5_1x(1,:);
    A5_1y1 = A5_1y(1,:);
    A5_2x1 = A5_2x(1,:);
    A5_2y1 = A5_2y(1,:);
    A5_1x2 = A5_1x(2,:);
    A5_1y2 = A5_1y(2,:);
    A5_2x2 = A5_2x(2,:);
    A5_2y2 = A5_2y(2,:);
    A5_1x3 = A5_1x(3,:);
    A5_1y3 = A5_1y(3,:);
    A5_2x3 = A5_2x(3,:);
    A5_2y3 = A5_2y(3,:);
    A5_1x4 = A5_1x(4,:);
    A5_1y4 = A5_1y(4,:);
    A5_2x4 = A5_2x(4,:);
    A5_2y4 = A5_2y(4,:);
    A5_1x5 = A5_1x(5,:);
    A5_1y5 = A5_1y(5,:);
    A5_2x5 = A5_2x(5,:);
    A5_2y5 = A5_2y(5,:);
    A5_1x6 = A5_1x(6,:);
    A5_1y6 = A5_1y(6,:);
    A5_2x6 = A5_2x(6,:);
    A5_2y6 = A5_2y(6,:);  
    BW1 = roipoly(emptyMask, A5_1x1, A5_1y1);
    BW2 = roipoly(emptyMask, A5_1x2, A5_1y2);
    BW3 = roipoly(emptyMask, A5_1x3, A5_1y3);
    BW4 = roipoly(emptyMask, A5_1x4, A5_1y4);
    BW5 = roipoly(emptyMask, A5_1x5, A5_1y5);
    BW6 = roipoly(emptyMask, A5_1x6, A5_1y6);
    BW7 = roipoly(emptyMask, A5_2x1, A5_2y1);
    BW8 = roipoly(emptyMask, A5_2x2, A5_2y2);
    BW9 = roipoly(emptyMask, A5_2x3, A5_2y3);
    BW10 = roipoly(emptyMask, A5_2x4, A5_2y4);
    BW11 = roipoly(emptyMask, A5_2x5, A5_2y5);
    BW12 = roipoly(emptyMask, A5_2x6, A5_2y6);
    BW = BW1+BW2+BW3+BW4+BW5+BW6+BW7+BW8+BW9+BW10+BW11+BW12;
    
end

end

