# FPGA Implementation of an Adaptive Kalman Filter for DC Motor Speed Estimation

Hardware-accelerated adaptive Kalman filter for real-time speed and position estimation of a brushed DC motor, implemented in VHDL on a Xilinx Artix-7 FPGA and validated on physical hardware.


> **Context:** Undergraduate graduation thesis, Electrical & Electronics Engineering, Haliç University (2026).

---

## Why this project

Quadrature encoder readings on a low-cost DC motor are noisy, and naive differentiation of position to obtain speed amplifies that noise badly. This project moves the filtering into hardware: a 2-state discrete Kalman filter runs entirely on the FPGA fabric in fixed-point arithmetic, producing a stable speed estimate with deterministic latency and no processor in the loop.

The filter is **adaptive** — the measurement noise covariance `R` is scaled according to the residual magnitude, so the filter automatically trusts the encoder less during transients and more during steady-state operation.

---

## System architecture

The design follows a modular VHDL architecture:

| Module | Responsibility |
|---|---|
| `pwm_generator` | Generates a 20 kHz PWM drive signal for the H-bridge, with duty cycle control. |
| `encoder_reader` | Decodes A/B quadrature channels from the rotary encoder in real time, with direction detection. |
| `kalman_filter` | 2-state discrete Kalman filter in Q16 fixed-point, including the adaptive `R` mechanism. |
| `top_module` | Integrates all sub-modules, handles clock domains, and maps signals to physical pins via XDC constraints. |

```
                +------------------+
  Encoder A/B ->| encoder_reader   |--- position, raw speed ---+
                +------------------+                           |
                                                               v
  100 MHz clk ->+------------------+                  +------------------+
                | pwm_generator    |--- PWM --------> |  Kalman_28_yeni  |--> filtered speed
                +------------------+   (to H-bridge)  |  (Q16, adaptive) |
                                                      +------------------+
```

---

## Implementation parameters

| Parameter | Value |
|---|---|
| System clock | 100 MHz |
| PWM frequency | 20 kHz |
| Kalman sampling rate | 100 Hz |
| Arithmetic | Q16 fixed-point (`numerictype(1,32,16)`) |
| Filter order | 2-state discrete Kalman filter |
| Target device | Xilinx Artix-7 XC7A35T (Digilent Basys 3) |

---

## Hardware setup

| Component | Part |
|---|---|
| FPGA board | Digilent Basys 3 (Artix-7 XC7A35T) |
| Motor | Robotzade 12 V brushed DC motor with quadrature encoder |
| Motor driver | TB6612FNG dual H-bridge |
| Power supply | Mervesan 60 W regulated PSU |
| Interface | Pmod headers for encoder and driver signals |

Motor parameters (armature resistance, inductance, back-EMF constant, inertia) were derived analytically from datasheet specifications — stall current, back-EMF and no-load current — rather than measured on a test bench. This shaped the modeling approach and is discussed in the thesis.

---

## Design flow

1. **Mathematical modeling** — DC motor state-space model derived from datasheet parameters.
2. **Simulation** — Kalman filter designed and tuned in MATLAB/Simulink against the motor model.
3. **Fixed-point conversion** — floating-point design converted to Q16 fixed-point with numerical safeguards.
4. **HDL generation** — VHDL produced using MATLAB HDL Coder, then integrated with hand-written PWM and encoder modules.
5. **Synthesis & implementation** — Xilinx Vivado, with multicycle path constraints applied to the Kalman datapath.
6. **Hardware validation** — bitstream programmed to the Basys 3 and tested against the physical motor.

---

## Engineering challenges and solutions

**Fixed-point numerical stability.** Moving the Kalman filter from floating-point simulation to Q16 fixed-point introduced instability in the covariance update. Three safeguards were required:
- **P matrix symmetrization** after each update, to counter asymmetry introduced by rounding.
- **Diagonal floor clamping**, preventing covariance terms from collapsing toward zero and stalling the filter.
- **Residual-based zero-checks**, avoiding division by near-zero values in the gain computation.

**Timing closure.** The computational depth of the Kalman update (matrix multiply, inversion, covariance update) exceeded what a single 100 MHz clock cycle allows. **Multicycle path constraints** were applied so the synthesis tool could spread the datapath across multiple cycles without violating timing.

**Filter robustness.** A static `R` made the filter either sluggish during transients or noisy at steady state. The **adaptive `R` mechanism** — scaling measurement noise covariance with residual magnitude — resolved this trade-off and was the single most important factor in filter performance.

---

## Repository structure

```
.
├── hdl/                    # VHDL source files
│   ├── TOP_Module.vhd
│   ├── PWM_Generator.vhd
│   ├── Encoder_Reader.vhd
│   └── Kalman_28_yeni.vhd
│   └── Kalman_28_yeni_pkg.vhd
│   └── Kalman_28_yeni_tc.vhd
|   └── MATLAB_Function.vhd
├── constraints/
│   └── Basys3_Kalman_Motor.xdc         # Pin assignments and timing constraints
├── matlab/
│   ├── kalman_with_testbench_for_vivado.slx    # Simulink motor model
├── docs/
│   ├── results/
│   ├── Graduation Project II Word.docx     
│   
├── LICENSE
└── README.md
```

---

## Getting started

**Prerequisites:** Xilinx Vivado (2020.2 or later), MATLAB/Simulink with HDL Coder (only if regenerating the filter HDL).

```bash
git clone https://github.com/<username>/<repo-name>.git
cd <repo-name>
```

1. Create a new Vivado RTL project targeting **xc7a35tcpg236-1**.
2. Add all files from `hdl/` as design sources.
3. Add `constraints/Basys3_Kalman_Motor.xdc` as a constraints file.
4. Run synthesis, implementation, and generate the bitstream.
5. Connect the hardware per the wiring table in `docs/`, then program the Basys 3.

To regenerate the filter HDL from the model, open `kalman_with_testbench_for_vivado.slx` and run the HDL Coder workflow.

---

## Results

<!-- Replace this section with your actual measurements — this is what reviewers look for first. -->

| Metric | Result |
|---|---|
| Speed estimation error (steady state) | < %2 (±10 RPM)  Kalman Estimation (1012 RPM) - MOTOR(1000 RPM)|
| Resource utilization (LUT / FF / DSP) | 15486 LUT - 7933 FF - 42 DSP |
| Maximum achieved clock frequency | 100 MHz (WNS: +1.29ns) |



---

## Author

**Emircan İpek** — Electrical & Electronics Engineering, Haliç University
[LinkedIn](https://linkedin.com/in/emircan-ipek-b53159291)

## License

See [LICENSE](LICENSE).
