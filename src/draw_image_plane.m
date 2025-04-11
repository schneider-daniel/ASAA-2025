% DRAW_IMAGE_PLANE Draws a scaled image plane at the camera origin using raw calibration.
%
%   DRAW_IMAGE_PLANE(T_CAM, SCALE_Z) uses the intrinsic parameters from the
%   original, undistorted, and high-resolution camera to draw the image plane.
%   The image plane remains centered at the optical center and is scaled to show
%   field-of-view accurately.
%
%   Parameters:
%   - T_CAM: 4x4 camera pose matrix in world coordinates.
%   - SCALE_Z: Scalar for image plane visualization size (keeps it at Z = 0).
%
% AUTHOR:
%   Daniel Schneider
%   University of Applied Sciences Kempten
%   daniel.schneider@hs-kempten.de
%
% CREATED:
%   10/04/2025
%
function draw_image_plane(T_cam, scale_z)

% --- Raw camera calibration parameters (from calibration toolbox)
fx = 1659.6;
fy = 1659.3;
cx = 1314.5;
cy = 998.0983;
img_w = 2592;
img_h = 2048;

% Compute normalized image plane at Z=1 and scale it later
Z_virtual = 1.0;
x_c = [-cx, img_w - cx] / fx * Z_virtual;
y_c = [-cy, img_h - cy] / fy * Z_virtual;

% Create 4 corners of the image plane (Z = 1)
corners_cam = [
    x_c(1), y_c(1), Z_virtual;
    x_c(2), y_c(1), Z_virtual;
    x_c(2), y_c(2), Z_virtual;
    x_c(1), y_c(2), Z_virtual
]';

% Scale to control size and visibility in world view
corners_cam = corners_cam * scale_z;
corners_cam = [corners_cam; ones(1, 4)];

% Transform into world coordinates
corners_world = T_cam * corners_cam;

% Draw the image plane as a translucent quad
fill3(corners_world(1,:), corners_world(2,:), corners_world(3,:), ...
    [0.7 0.7 1], 'FaceAlpha', 0.3, 'EdgeColor', 'k');

% Label
center = mean(corners_world(1:3,:), 2);
text(center(1), center(2), center(3), 'Image Plane (raw calib)', ...
    'FontSize', 10);

end
