# Li-Fi-project
This project includes all our simulations as well as mathematical equations done on matlab and kaggle
# Hybrid LiFi-WiFi System  
## README

---

## Overview

This project provides a comprehensive simulation and analysis framework for a **Hybrid LiFi-WiFi communication system**. It models user mobility, dynamic load balancing, throughput, energy efficiency, and resource-dependent switching between LiFi and WiFi channels. The code is written in Python and leverages `numpy` and `matplotlib` for computation and visualization.

---

## Main Features

- **3D User Mobility Modeling:** Simulates user movement along a 3D trajectory to reflect real-world mobility patterns and their impact on connectivity.
- **Markovian Load Dynamics:** Models the stochastic flow of users between LiFi and WiFi using Markov processes, capturing dynamic network load balancing.
- **Throughput Simulation:** Implements realistic throughput models for WiFi, accounting for path loss, shadowing, and fading, and for LiFi, based on LED characteristics.
- **Energy Efficiency Analysis:** Simulates the energy efficiency of LiFi links, including LED power consumption, data rate, and thermal effects.
- **Resource-Dependent Switching:** Dynamically models how traffic is allocated between LiFi and WiFi based on real-time throughput and resource availability.
- **Proportional Congestion & Power Allocation:** Simulates adaptive power allocation in response to varying congestion levels.
- **Shannon-Hartley Capacity Analysis:** Visualizes the theoretical channel capacity for different SNR values and bandwidths.
- **Core Load Balancing:** Implements advanced load balancing equations considering mobility, channel usage, and system parameters.
- **Bandwidth-Dependent Load Dynamics:** Models the interaction between bandwidth usage and user load for both LiFi and WiFi.

---

## Project Structure

- **Mobility Model:**  
  - `LiFiWaypointMobilityModel` class simulates user movement through predefined waypoints in 3D space.
- **Load Dynamics:**  
  - `MarkovianLoadModel` class models user transitions between LiFi and WiFi.
- **Throughput Models:**  
  - `wifi_throughput_model` function simulates WiFi throughput considering environmental factors.
  - LiFi throughput is derived from LED power and SNR.
- **Energy Efficiency & LED Dynamics:**  
  - Simulates LED power, throughput, energy efficiency, and thermal dynamics over time.
- **Resource Allocation & Switching:**  
  - Functions for resource-dependent switching and proportional congestion-driven power allocation.
- **Load Balancing & Bandwidth Models:**  
  - Implements dynamic equations for balancing user load and bandwidth between LiFi and WiFi.

---

## Getting Started

### Prerequisites

- Python 3.x
- `numpy`
- `matplotlib`

Install dependencies with:
```bash
pip install numpy matplotlib
```

### Running the Simulation

1. Save the code to a `.py` file (e.g., `hybrid_lifi_wifi.py`).
2. Run the script:
   ```bash
   python hybrid_lifi_wifi.py
   ```
3. The script will generate a series of plots illustrating mobility, load dynamics, throughput, energy efficiency, resource allocation, and load balancing.

---

## Usage & Customization

- **Mobility:**  
  Modify the `waypoints` list to simulate different user movement patterns.
- **Load Dynamics:**  
  Adjust `lambda_rate`, `mu_rate`, and initial user counts to model different network scenarios.
- **Throughput Models:**  
  Tune parameters such as transmit power, path loss exponent, and shadowing for more realistic WiFi environments.
- **Energy Efficiency:**  
  Change LED and circuit parameters to explore different LiFi hardware configurations.
- **Resource Switching:**  
  Experiment with `alpha`, `beta`, and throughput profiles to study adaptive traffic allocation.
- **Load Balancing:**  
  Update system parameters in the core equations to reflect different network policies or user behaviors.

---

## Output

The code produces a series of figures, including:
- 3D user mobility trajectories
- Time evolution of LiFi and WiFi user loads
- Throughput curves for WiFi and LiFi channels
- LED power, energy efficiency, and thermal characteristics
- Resource switching and load balancing visualizations
- Shannon-Hartley capacity curves

---

## Applications

- **Research & Education:**  
  Analyze and visualize hybrid LiFi-WiFi system dynamics for academic or instructional purposes.
- **Network Planning:**  
  Evaluate the impact of user mobility, channel conditions, and dynamic switching on network performance.
- **Energy Optimization:**  
  Study energy efficiency trade-offs in LiFi networks.

---

## Acknowledgments

Special thanks to Dr. Samah for guidance and support throughout this project.

---

## License

This project is for educational and research purposes. Contact the author for commercial use.

---

**For questions or feedback, contact:**  
Logine Ahmed
logineelshazly@gmail.com

