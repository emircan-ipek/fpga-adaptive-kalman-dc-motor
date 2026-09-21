# FPGA Implementation of Adaptive Kalman Filtered-Based Speed Accuracy Enhancement For a DC Motor

This repository contains the VHDL source code and MATLAB/Simulink models for an FPGA-based DC motor control and speed estimation system. The project focuses on enhancing speed accuracy using an Adaptive Kalman Filter implemented on hardware. 

> **Note:** This project was successfully funded and supported by the **TÜBİTAK 2209-A** University Students Research Projects Support Program.

## 🛠️ System Architecture

The hardware architecture is designed using a modular approach in VHDL, consisting of the following core modules:
* **PWM Generator:** Generates high-frequency PWM signals to drive the DC motor.
* **Encoder Reader:** Interfaces with the rotary encoder via Pmod ports to read A/B channel quadrature signals in real-time.
* **Kalman Filter Module:** A hardware-accelerated Adaptive Kalman Filter algorithm for robust speed and position estimation, mitigating sensor noise.
* **Top Module:** Integrates all sub-modules and maps them to the physical pins of the FPGA board using XDC constraints.

## 🧰 Hardware & Software Used

* **Development Board:** Digilent Basys 3 (Artix-7 FPGA)
* **Hardware Description Language:** VHDL
* **IDE & Synthesis:** Xilinx Vivado
* **Modeling & Simulation:** MATLAB & Simulink
* **Actuators & Sensors:** DC Motor, Rotary Quadrature Encoder

## 🚀 Project Workflow

1. **Algorithm Design:** The Adaptive Kalman Filter was initially modeled and tested in MATLAB/Simulink.
2. **Hardware Implementation:** The validated mathematical model was translated into synthesized VHDL code.
3. **Synthesis & Implementation:** Resource utilization (LUTs, Flip-Flops) and timing analysis were optimized via Xilinx Vivado.
4. **Physical Testing:** The bitstream was loaded onto the Basys 3 board, successfully demonstrating real-time noise filtering and accurate speed estimation on the physical DC motor setup.

## 📂 Repository Structure
* `/src` : VHDL source files (`.vhd`) for PWM, Encoder, Kalman, and Top modules.
* `/constraints` : Xilinx Design Constraints (`.xdc`) file for Basys 3 pin mappings.
* `/sim` : MATLAB/Simulink models and testbench files used for preliminary algorithm validation.
* `/docs` : Hardware schematics, TÜBİTAK proposal summaries, and project reports.

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
