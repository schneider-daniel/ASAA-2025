
function draw_frame(T, label_text, scale)
% DRAW_FRAME Draws a 3D coordinate frame using a homogeneous transformation matrix.
%
%   DRAW_FRAME(T, LABEL_TEXT, SCALE) visualizes a coordinate system in 3D space
%   using quiver3 arrows for the X, Y, and Z axes based on the transformation 
%   matrix T (4x4). The axis directions are color-coded as follows:
%     - X-axis: red
%     - Y-axis: green
%     - Z-axis: blue
%
%   The function also adds a text label at the origin of the coordinate frame.
%
%   Parameters:
%   - T:          4x4 homogeneous transformation matrix representing the pose of
%                 the coordinate frame in world coordinates.
%   - LABEL_TEXT: String specifying the label to display at the frame origin.
%   - SCALE:      Scalar value defining the length of the axis vectors.
%
%   Example:
%       T = eye(4);
%       draw_frame(T, 'World', 0.5);
%
%   See also: QUIVER3, TEXT


% Draw coordinate axes from transformation matrix T (4x4)
origin = T(1:3,4);
x_axis = T(1:3,1) * scale;
y_axis = T(1:3,2) * scale;
z_axis = T(1:3,3) * scale;

quiver3(origin(1), origin(2), origin(3), x_axis(1), x_axis(2), x_axis(3), ...
    'r', 'LineWidth', 2, 'MaxHeadSize', 0.5);
quiver3(origin(1), origin(2), origin(3), y_axis(1), y_axis(2), y_axis(3), ...
    'g', 'LineWidth', 2, 'MaxHeadSize', 0.5);
quiver3(origin(1), origin(2), origin(3), z_axis(1), z_axis(2), z_axis(3), ...
    'b', 'LineWidth', 2, 'MaxHeadSize', 0.5);

text(origin(1), origin(2), origin(3), ['\leftarrow ', label_text], ...
    'FontSize', 12, 'Color', 'k');
end