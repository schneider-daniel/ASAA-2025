%% ------------------------------------------------------------------------
%
% DESCRIPTION:
%   This script visualizes the coordinate transformation between the vehicle
%   frame (according to ISO 8855) and an onboard camera. It is intended to
%   support the lecture content in "Automotive Sensors and Actuators (ASAA)"
%   in the summer term 2024, specifically related to sensor extrinsics and
%   3D visualization of spatial relations.
%
%   The camera extrinsics (rotation and translation) are applied to plot the
%   camera pose relative to the vehicle origin, defined as the projection of
%   the rear axle onto the road surface. The visualization includes:
%     - Coordinate frames for vehicle and camera
%     - A dashed gray line representing the translation vector
%     - Optional: image plane based on the camera matrix (newCameraMatrix from OpenCV)
%
%
% REQUIRED FILES:
%   src/draw_frame.m
%   src/draw_image_plane.m
%
% SEE ALSO:
%   draw_frame, draw_image_plane
%
% AUTHOR:
%   Daniel Schneider
%   University of Applied Sciences Kempten
%   daniel.schneider@hs-kempten.de
%
% CREATED:
%   09/04/2025
%
% LAST MODIFIED:
%   10/04/2025
%
% ------------------------------------------------------------------------
% Workspace preparation
close all;
clear;
clc;
addpath(genpath('./src'))

%% Setup figure
figure;
hold on;
axis equal;
grid on;
view(3);
xlabel('X (forward)');
ylabel('Y (left)');
zlabel('Z (up)');
title('Vehicle → Camera Frame');

%% Prepare all parameters
% Draw the Vehicle frame (ISO 8855) at origin
T_vehicle = eye(4);
draw_frame(T_vehicle, 'Vehicle (ISO 8855)', 0.3);

% Original extrinsic calibration: from vehicle to camera (camera's view)
R = [ 0.30389705, -0.95224289, -0.02966584;
    -0.02329885,  0.02370089, -0.99944757;
    0.95241995,  0.30442035, -0.01498354];
t = [-0.167; 1.685; -1.587];

% T_cam_to_vehicle; invert to get camera pose in vehicle coords
T_cam_to_vehicle = eye(4);
T_cam_to_vehicle(1:3,1:3) = R;
T_cam_to_vehicle(1:3,4) = t;

T_vehicle_to_cam = inv(T_cam_to_vehicle);  % camera pose in vehicle frame


%% Drawings
% Rear axle
axle_half_width = 0.8;  % in meters, adjust if needed

% Coordinates of left and right wheel positions on the axle (at z = 0)
rear_axle_pts = [
    0, -axle_half_width, 0;  % left wheel contact
    0,  axle_half_width, 0   % right wheel contact
    ];

% Draw the axle as a black line
plot3(rear_axle_pts(:,1), rear_axle_pts(:,2), rear_axle_pts(:,3), ...
    'k-', 'LineWidth', 2);

% Optional: mark wheels with small circles
plot3(rear_axle_pts(:,1), rear_axle_pts(:,2), rear_axle_pts(:,3), ...
    'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k');

% Label the axle
text(0, 0, 0.05, 'Rear Axle', 'FontSize', 10, 'Color', 'k');


% Camera frame
draw_frame(T_vehicle_to_cam, 'Camera', 0.3);

% Draw translation vector (gray dashed line)
origin_vehicle = T_vehicle(1:3,4);
origin_cam = T_vehicle_to_cam(1:3,4);
plot3([origin_vehicle(1), origin_cam(1)], ...
    [origin_vehicle(2), origin_cam(2)], ...
    [origin_vehicle(3), origin_cam(3)], ...
    '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.5);

% Label the translation vector
midpoint = (origin_vehicle + origin_cam) / 2;
text(midpoint(1), midpoint(2), midpoint(3), ...
    'Camera Translation', 'Color', [0.4 0.4 0.4], 'FontSize', 10);

% Image plane
draw_image_plane(T_vehicle_to_cam, 0.05);
