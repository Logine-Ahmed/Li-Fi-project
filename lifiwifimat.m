%% Hybrid LiFi vs WiFi Model in MATLAB
% Save this script as HybridLiFiWiFiModel.m and run it in MATLAB.

%% PART 1: Mobility Model (3D Trajectory)
% Define 10 waypoints
waypoints = [0 0 0;
             1 1 0.5;
             2 0 1;
             3 -1 1.5;
             -1 -2 2;
             -2 -3 1;
             -3 -2 0.5;
             -4 -1 0;
             -5 0 0.5;
             -3 2 1];
         
% Extract coordinates
x_positions = waypoints(:,1);
y_positions = waypoints(:,2);
z_positions = waypoints(:,3);

figure;
% Use RGB triplet for navy: [0 0 0.5]
plot3(x_positions, y_positions, z_positions, 'Color', [0 0 0.5]);
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
title('3D Trajectory of User Mobility');
grid on;
legend('User Mobility');

%% PART 2: Markovian Load Dynamics
% Initialize parameters
lambda_rate = 0.05;
mu_rate = 0.03;
users_lifi = 50;
users_wifi = 50;
T = 60; % simulation time in seconds
timeVals = linspace(0, T, 60);
lifi_users = zeros(1, length(timeVals));
wifi_users = zeros(1, length(timeVals));

for i = 1:length(timeVals)
    dU_LiFi = lambda_rate * users_wifi - mu_rate * users_lifi;
    dU_WiFi = mu_rate * users_lifi - lambda_rate * users_wifi;
    users_lifi = users_lifi + dU_LiFi;
    users_wifi = users_wifi + dU_WiFi;
    lifi_users(i) = users_lifi;
    wifi_users(i) = users_wifi;
end

figure;
plot(timeVals, lifi_users, 'Color', [0 0 1]); % blue as [0,0,1]
hold on;
plot(timeVals, wifi_users, 'Color', [1 0 0]); % red as [1,0,0]
xlabel('Time (s)', 'FontSize', 12);
ylabel('Number of Users', 'FontSize', 12);
title('Load Dynamics: Li-Fi vs Wi-Fi Users', 'FontSize', 14);
legend('Li-Fi Users','Wi-Fi Users', 'FontSize', 11);
grid on;
hold off;

%% PART 3: Throughput Models & Adaptive Hybrid Throughput
% --- Wi-Fi Throughput Model (Realistic) ---
function throughput = wifi_throughput_model(t_vals, Pt, d0, n, shadow_std, noise_floor)
    % d(t)
    d = 3 + 2*sin(2*pi*t_vals/30);
    % Path loss in dB
    path_loss_db = 10 * n * log10(d/d0);
    % Shadowing (Gaussian)
    shadowing_db = shadow_std * randn(size(t_vals));
    total_loss_db = path_loss_db + shadowing_db;
    % Convert to linear scale
    total_loss_lin = 10.^(-total_loss_db/10);
    % Rayleigh fading (if no Statistics Toolbox, use abs(randn))
    fading = raylrnd(1, size(t_vals));
    SINR = (Pt * total_loss_lin .* fading) ./ (noise_floor + 1e-9);
    bandwidth = 20; % MHz
    throughput = bandwidth * log2(1 + SINR) + randn(size(t_vals));
end

% --- Li-Fi Throughput Model (Realistic) ---
function throughput = lifi_throughput_model(t_vals, K, ambient_noise)
    d = 3 + 2*sin(2*pi*t_vals/30);
    H = K ./ (d.^2);
    baseline = 30;   % Mbps
    amplitude = 20;  % scaling factor
    throughput = baseline + amplitude * H - ambient_noise + 2*randn(size(t_vals));
end

% --- Adaptive Hybrid Throughput Model with Hysteresis ---
function hybrid = adaptive_hybrid_throughput_model(lifi_vals, wifi_vals, margin)
    hybrid = zeros(size(lifi_vals));
    current_state = 'WiFi';
    for i = 1:length(lifi_vals)
        if strcmp(current_state, 'WiFi') && (lifi_vals(i) > wifi_vals(i) + margin)
            current_state = 'LiFi';
        elseif strcmp(current_state, 'LiFi') && (wifi_vals(i) > lifi_vals(i) + margin)
            current_state = 'WiFi';
        end
        if strcmp(current_state, 'LiFi')
            hybrid(i) = lifi_vals(i);
        else
            hybrid(i) = wifi_vals(i);
        end
    end
end

% Generate throughput data for t = 0 to 60 s
t_sim = linspace(0, 60, 60);
Pt = 50; d0 = 1.0; n = 3.0; shadow_std = 2.0; noise_floor = 1;
K = 0.7; ambient_noise = 1;
liFi_throughput_vals = lifi_throughput_model(t_sim, K, ambient_noise);
wifi_throughput_vals = wifi_throughput_model(t_sim, Pt, d0, n, shadow_std, noise_floor);
hybrid_throughput_vals = adaptive_hybrid_throughput_model(liFi_throughput_vals, wifi_throughput_vals, 2);

figure;
plot(t_sim, liFi_throughput_vals, '--o', 'DisplayName', 'Li-Fi Throughput');
hold on;
plot(t_sim, wifi_throughput_vals, '-.s', 'DisplayName', 'Wi-Fi Throughput');
plot(t_sim, hybrid_throughput_vals, '-x', 'DisplayName', 'Hybrid Throughput');
yline(30, 'k:', 'DisplayName', 'Nominal Baseline (30 Mbps)');
xlabel('Time (s)');
ylabel('Throughput (Mbps)');
title('Instantaneous Throughput: Li-Fi vs Wi-Fi vs Hybrid');
legend('show');
grid on;
hold off;

%% PART 6: LED Energy Efficiency Model (ODE Simulation)
T_sim_LED = 60; dt_LED = 0.1; 
N_steps_LED = T_sim_LED / dt_LED;  
eta = 0.8; I0 = 0.5; M0 = 0.2; dI_dt = 0.005; dM_dt = 0.002;
B = 20; N0_val = 1e-9; G = 10;
P_circuit = 5; P_receiver = 2;
C_th = 10; T_a = 300; R_th = 5;
I_val = I0; M_val = M0;
P_LED_val = eta * I_val + M_val * I_val^2;
SNR_val = G * P_LED_val / (N0_val * B);
R_led_val = B * log2(1 + SNR_val);
P_total_val = P_LED_val + P_circuit + P_receiver;
EE_val = R_led_val / P_total_val;
T_j = 310;

time_arr_LED = linspace(0, T_sim_LED, N_steps_LED);
I_arr = zeros(1, N_steps_LED);
M_arr = zeros(1, N_steps_LED);
P_LED_arr = zeros(1, N_steps_LED);
R_arr = zeros(1, N_steps_LED);
EE_arr = zeros(1, N_steps_LED);
Tj_arr = zeros(1, N_steps_LED);
P_total_arr = zeros(1, N_steps_LED);
dP_LED_dt_arr = zeros(1, N_steps_LED);
dR_dt_arr = zeros(1, N_steps_LED);
dEE_dt_arr = zeros(1, N_steps_LED);
dTj_dt_arr = zeros(1, N_steps_LED);

for i = 1:N_steps_LED
    I_arr(i) = I_val;
    M_arr(i) = M_val;
    P_LED_arr(i) = P_LED_val;
    R_arr(i) = R_led_val;
    EE_arr(i) = EE_val;
    Tj_arr(i) = T_j;
    P_total_arr(i) = P_total_val;
    
    dP_LED_dt = eta*dI_dt + 2*M_val*I_val*dI_dt + I_val^2*dM_dt;
    dR_dt = (G/(N0_val*log(2)))*(1/(1+SNR_val))*dP_LED_dt;
    dP_total_dt = dP_LED_dt;
    dEE_dt = (dR_dt * P_total_val - R_led_val * dP_total_dt) / (P_total_val^2);
    dTj_dt = (1/C_th)*(P_LED_val - (T_j - T_a)/R_th);
    
    dP_LED_dt_arr(i) = dP_LED_dt;
    dR_dt_arr(i) = dR_dt;
    dEE_dt_arr(i) = dEE_dt;
    dTj_dt_arr(i) = dTj_dt;
    
    I_val = I_val + dI_dt * dt_LED;
    M_val = M_val + dM_dt * dt_LED;
    P_LED_val = P_LED_val + dP_LED_dt * dt_LED;
    R_led_val = R_led_val + dR_dt * dt_LED;
    P_total_val = P_LED_val + P_circuit + P_receiver;
    EE_val = EE_val + dEE_dt * dt_LED;
    T_j = T_j + dTj_dt * dt_LED;
    SNR_val = G * P_LED_val / (N0_val * B);
end

figure;
subplot(2,2,1);
plot(time_arr_LED, P_LED_arr, 'Color', [0 0 1]); % blue
xlabel('Time (s)', 'FontSize', 12); ylabel('LED Power (W)', 'FontSize', 12);
title('LED Power Dynamics', 'FontSize', 14);
grid on;

subplot(2,2,2);
plot(time_arr_LED, R_arr, 'Color', [0 0.5 0]); % greenish
xlabel('Time (s)', 'FontSize', 12); ylabel('Li-Fi Throughput (Mbps)', 'FontSize', 12);
title('Li-Fi Throughput from LED Dynamics', 'FontSize', 14);
grid on;

subplot(2,2,3);
plot(time_arr_LED, EE_arr, 'Color', [1 0 1]); % magenta
xlabel('Time (s)', 'FontSize', 12); ylabel('Energy Efficiency (Mbps/W)', 'FontSize', 12);
title('Energy Efficiency Over Time (Li-Fi)', 'FontSize', 14);
grid on;

subplot(2,2,4);
plot(time_arr_LED, Tj_arr, 'Color', [1 0 0]); % red
xlabel('Time (s)', 'FontSize', 12); ylabel('Junction Temperature (K)', 'FontSize', 12);
title('LED Junction Temperature', 'FontSize', 14);
grid on;
sgtitle('LED ODE Dynamics', 'FontSize', 16);

%% PART 8: Analysis of ODE Effects on Throughput
wifi_throughput_ode = wifi_throughput_model(time_arr_LED, Pt, d0, n, shadow_std, noise_floor);
hybrid_throughput_ode = adaptive_hybrid_throughput_model(R_arr, wifi_throughput_ode, 2);

figure;
subplot(2,2,1);
plot(time_arr_LED, dP_LED_dt_arr, 'Color', [0.5 0 0.5]);  % purple
ylabel('dP_{LED}/dt (W/s)', 'FontSize', 12); xlabel('Time (s)', 'FontSize', 12);
yyaxis right;
plot(time_arr_LED, R_arr, '--', 'Color', [0 0.5 0]); % dark green
ylabel('Li-Fi Throughput (Mbps)', 'FontSize', 12);
title('Effect of LED Power Change on Li-Fi Throughput', 'FontSize', 14);
legend('dP_{LED}/dt', 'Li-Fi Throughput', 'FontSize', 10);
grid on;

subplot(2,2,2);
plot(time_arr_LED, dR_dt_arr, 'Color', [0.6 0.3 0]);  % brown
ylabel('dR/dt (Mbps/s)', 'FontSize', 12); xlabel('Time (s)', 'FontSize', 12);
yyaxis right;
plot(time_arr_LED, R_arr, '--', 'Color', [0 0.5 0]);
ylabel('Li-Fi Throughput (Mbps)', 'FontSize', 12);
title('Impact of Data Rate Change on Li-Fi Throughput', 'FontSize', 14);
legend('dR/dt', 'Li-Fi Throughput', 'FontSize', 10);
grid on;

subplot(2,2,3);
plot(time_arr_LED, dEE_dt_arr, 'Color', [1 0.5 0], 'Marker', 'o');  % orange
xlabel('Time (s)', 'FontSize', 12); ylabel('dEE/dt (bits/J/s)', 'FontSize', 12);
title('Dynamics of Energy Efficiency (Li-Fi)', 'FontSize', 14);
legend('dEE/dt', 'FontSize', 10);
grid on;

subplot(2,2,4);
plot(time_arr_LED, dTj_dt_arr, 'Color', [0 1 1], 'Marker', 'o'); % cyan: [0 1 1]
ylabel('dT_{j}/dt (K/s)', 'FontSize', 12); xlabel('Time (s)', 'FontSize', 12);
yyaxis right;
plot(time_arr_LED, Tj_arr, '--', 'Color', [1 0 0], 'Marker', 'x'); % red
ylabel('T_{j} (K)', 'FontSize', 12);
title('Thermal Dynamics: Temperature Change and Level', 'FontSize', 14);
legend('dT_{j}/dt', 'T_{j}', 'FontSize', 10);
grid on;
sgtitle('Analysis of ODE Effects on Li-Fi Throughput', 'FontSize', 16);

%% PART 9: Effect of User Mobility on Li-Fi Throughput
% Define a random-walk mobility function (local function at end)
num_steps = 100;
step_size = 0.5;
initial_position = [5, 5, 1];  % Starting position of the user
mobility_positions = random_walk_mobility(initial_position, num_steps, step_size);

% Assume the AP is at the origin [0, 0, 0]
AP = [0, 0, 0];
distances = vecnorm(mobility_positions - AP, 2, 2);

% Compute Li-Fi throughput based on mobility using a Lambertian model:
baseline = 30;      % Mbps baseline
amplitude = 20;     % scaling factor
K = 0.7;            % channel gain constant
ambient_noise = 1;  % ambient noise level
noise_mobility = 2 * randn(num_steps,1);
liFi_throughput_mobility = baseline + amplitude*(K./(distances.^2)) - ambient_noise + noise_mobility;

figure;
plot(1:num_steps, liFi_throughput_mobility, 'o-', 'Color', [0 0 1]);
xlabel('Time Step', 'FontSize', 12);
ylabel('Li-Fi Throughput (Mbps)', 'FontSize', 12);
title('Effect of User Mobility on Li-Fi Throughput', 'FontSize', 14);
legend('Li-Fi Throughput', 'FontSize', 11);
grid on;

%% Local function: Random Walk Mobility
function pos = random_walk_mobility(initial_position, num_steps, step_size)
    pos = zeros(num_steps, 3);
    pos(1,:) = initial_position;
    for i = 2:num_steps
        pos(i,:) = pos(i-1,:) + (rand(1,3) - 0.5) * step_size;
    end
end