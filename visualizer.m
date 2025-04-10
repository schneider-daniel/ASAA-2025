function visualize_vehicle_camera_transform()
    figure;
    hold on;
    axis equal;
    grid on;
    view(3);
    xlabel('X (forward)');
    ylabel('Y (left)');
    zlabel('Z (up)');
    title('Vehicle → Camera Frame (ISO 8855 Convention)');

    % Draw the Vehicle frame (ISO 8855) at origin
    T_vehicle = eye(4);
    draw_frame(T_vehicle, 'Vehicle (ISO 8855)', 0.3);

    % Original extrinsic calibration: from vehicle to camera (camera's view)
R = [ 0.30389705, -0.95224289, -0.02966584;
     -0.02329885,  0.02370089, -0.99944757;
      0.95241995,  0.30442035, -0.01498354];
t = [-0.167; 1.685; -1.587];

% This is T_cam_to_vehicle; invert to get camera pose in vehicle coords
T_cam_to_vehicle = eye(4);
T_cam_to_vehicle(1:3,1:3) = R;
T_cam_to_vehicle(1:3,4) = t;

T_vehicle_to_cam = inv(T_cam_to_vehicle);  % camera pose in vehicle frame

    % Draw Camera frame
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

    % Optional: image plane
    % draw_image_plane(T_vehicle_to_cam, 0.3);

    legend('Vehicle Frame', 'Camera Frame');
end

function draw_frame(T, label_text, scale)
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

function draw_image_plane(T_cam, scale_z)
    % Camera intrinsics (from OpenCV newCameraMatrix)
    fx = 307.4315301;
    fy = 304.42845041;
    cx = 387.17404027;
    cy = 157.74584542;
    img_w = 800;
    img_h = 600;

    % Z distance from camera center to image plane in meters
    Z = scale_z;

    % Compute image plane width and height in meters (from intrinsics)
    W = Z * img_w / fx;
    H = Z * img_h / fy;

    % Coordinates in camera frame (centered at optical axis)
    x_c = [-cx, img_w - cx] / fx * Z;
    y_c = [-cy, img_h - cy] / fy * Z;
    
    % 4 corners of image plane in camera frame (Z forward)
    corners_cam = [
        x_c(1), y_c(1), Z;
        x_c(2), y_c(1), Z;
        x_c(2), y_c(2), Z;
        x_c(1), y_c(2), Z
    ]';

    corners_cam = [corners_cam; ones(1, 4)];
    corners_world = T_cam * corners_cam;

    % Draw translucent image plane
    fill3(corners_world(1,:), corners_world(2,:), corners_world(3,:), ...
          [0.7 0.7 1], 'FaceAlpha', 0.3, 'EdgeColor', 'k');

    % Optional: label it
    center = mean(corners_world(1:3,:), 2);
    text(center(1), center(2), center(3), 'Image Plane', 'FontSize', 10);
end

