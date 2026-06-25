% Function to get vertices for common internal walls

% Copyright 2024 - 2025 The MathWorks, Inc.

function vertices = getInternalCommonWallSectionVertices(actualShape,dummyShape,tol)
    intersectShape = actualShape.floorPlan.intersect(dummyShape.floorPlan);
    % disp(intersectShape.Vertices)
    if size(intersectShape.Vertices,1) > 0
        diffVal = zeros(1,3);
        for i = 2:4
            diffVal(1,i-1) = sum((intersectShape.Vertices(1,:)-intersectShape.Vertices(i,:)).^2);
        end
        [~,idx] = max(diffVal);
        % 1st element and idx+1 are close enough values
        idx1 = [1,idx+1];
        idx2 = setdiff(1:4,idx1);

        vert1=intersectShape.Vertices(idx1,:);
        vert2=intersectShape.Vertices(idx2,:);

        if abs(vert1(1,1)-vert2(1,1))<=1.5*tol
            vertices = (vert1+vert2)/2;
        else
            vertices = [(vert1(1,:)+vert2(2,:) )/2; (vert1(2,:)+vert2(1,:) )/2];
        end
    else
        vertices = zeros(2,2);
    end
end