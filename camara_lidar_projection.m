clear; 
close all
clc;

%% Data reading
% Paths to the image and point cloud files
img_path = './img/018282150.png';
pcd_path = './img/018282150.pcd';

% Read the image
img = imread(img_path);

% Read the point cloud
ptCloud = pcread(pcd_path);
points = ptCloud.Location;
intensity_raw = ptCloud.Intensity;

%% Load the intrinsics and extrinsics   
% Camera intrinsic matrix
camera_matrix = [307.4315301, 0, 387.17404027;
                 0, 304.42845041, 157.74584542;
                 0, 0, 1];

% Rotation matrix
rotation = [ 0.30389705, -0.95224289, -0.02966584;
            -0.02329885,  0.02370089, -0.99944757;
             0.95241995,  0.30442035, -0.01498354];


% Translation vector
translation = [-0.167; 1.685; -1.587];

%% Decompose the rotation back to degress for visualization purposes
% Extract Euler angles in ZYX order (yaw-pitch-roll)
pitch = asin(-rotation(3,1));
roll  = atan2(rotation(3,2), rotation(3,3));
yaw   = atan2(rotation(2,1), rotation(1,1));

% Convert to degrees
pitch_deg = rad2deg(pitch);
roll_deg  = rad2deg(roll);
yaw_deg   = rad2deg(yaw);

% Display results
fprintf('Rotation around X-axis (roll):  %.2f deg\n', roll_deg);
fprintf('Rotation around Y-axis (pitch): %.2f deg\n', pitch_deg);
fprintf('Rotation around Z-axis (yaw):   %.2f deg\n', yaw_deg);

%% Set up transformation and applying it
% Build transformation matrix
transformation_lidar_to_cam = eye(4);
transformation_lidar_to_cam(1:3,1:3) = rotation;
transformation_lidar_to_cam(1:3,4) = translation;

disp('Transformation matrix (Camera → LiDAR):');
disp(transformation_lidar_to_cam);

% Convert points to homogeneous coordinates
num_points = size(points, 1);
lidar_points_hom = [points, ones(num_points, 1)]';

% Transform to camera frame
cam_points_hom = transformation_lidar_to_cam * lidar_points_hom;
cam_points = cam_points_hom(1:3, :);

% Project onto image plane
image_points_hom = camera_matrix * cam_points;
image_points = image_points_hom(1:2, :) ./ image_points_hom(3, :);

% Round and convert to pixel coordinates
pixel_x = round(image_points(1, :));
pixel_y = round(image_points(2, :));

% Normalize intensity
intensity_min = min(intensity_raw);
intensity_max = max(intensity_raw);
intensity_normalized = uint8(255 * (intensity_raw - intensity_min) / (intensity_max - intensity_min));

% Apply colormap
cmap = jet(256);
colors = cmap(double(intensity_normalized) + 1, :); % MATLAB indices start at 1
colors = uint8(colors * 255);

% Overlay on the image
img_combined = img;
for i = 1:length(pixel_x)
    x = pixel_x(i);
    y = pixel_y(i);
    if x > 0 && x <= size(img, 2) && y > 0 && y <= size(img, 1)
        img_combined(y, x, :) = reshape(colors(i, :), [1,1,3]);
    end
end

% Show image
imshow(img_combined);