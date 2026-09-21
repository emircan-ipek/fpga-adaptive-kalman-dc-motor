## ================================================================
## Basys3_Kalman_Motor.xdc
## Top module: Top_Module
## Board: Digilent Basys 3 - XC7A35T-1CPG236
## Logic level: 3.3 V
## ================================================================


## ================================================================
## Clock: 100 MHz
## ================================================================

set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]


## ================================================================
## Reset Button: BTNC
## ================================================================

set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports reset_btn]


## ================================================================
## Switches
## sw[7:0]  = PWM duty
## sw[15]   = motor direction
## sw[8:14] = currently unused, but constrained safely
## ================================================================

set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports {sw[0]}]
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports {sw[1]}]
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33} [get_ports {sw[2]}]
set_property -dict {PACKAGE_PIN W17 IOSTANDARD LVCMOS33} [get_ports {sw[3]}]
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS33} [get_ports {sw[4]}]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports {sw[5]}]
set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports {sw[6]}]
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports {sw[7]}]
set_property -dict {PACKAGE_PIN V2 IOSTANDARD LVCMOS33} [get_ports {sw[8]}]
set_property -dict {PACKAGE_PIN T3 IOSTANDARD LVCMOS33} [get_ports {sw[9]}]
set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS33} [get_ports {sw[10]}]
set_property -dict {PACKAGE_PIN R3 IOSTANDARD LVCMOS33} [get_ports {sw[11]}]
set_property -dict {PACKAGE_PIN W2 IOSTANDARD LVCMOS33} [get_ports {sw[12]}]
set_property -dict {PACKAGE_PIN U1 IOSTANDARD LVCMOS33} [get_ports {sw[13]}]
set_property -dict {PACKAGE_PIN T1 IOSTANDARD LVCMOS33} [get_ports {sw[14]}]
set_property -dict {PACKAGE_PIN R2 IOSTANDARD LVCMOS33} [get_ports {sw[15]}]


## ================================================================
## LEDs
## led[11:0] = Kalman speed debug
## led[12]   = encoder sample tick
## led[13]   = PWM activity
## led[14]   = encoder direction
## led[15]   = commanded direction
## ================================================================

set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN V19 IOSTANDARD LVCMOS33} [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33} [get_ports {led[4]}]
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports {led[5]}]
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {led[6]}]
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports {led[7]}]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports {led[8]}]
set_property -dict {PACKAGE_PIN V3 IOSTANDARD LVCMOS33} [get_ports {led[9]}]
set_property -dict {PACKAGE_PIN W3 IOSTANDARD LVCMOS33} [get_ports {led[10]}]
set_property -dict {PACKAGE_PIN U3 IOSTANDARD LVCMOS33} [get_ports {led[11]}]
set_property -dict {PACKAGE_PIN P3 IOSTANDARD LVCMOS33} [get_ports {led[12]}]
set_property -dict {PACKAGE_PIN N3 IOSTANDARD LVCMOS33} [get_ports {led[13]}]
set_property -dict {PACKAGE_PIN P1 IOSTANDARD LVCMOS33} [get_ports {led[14]}]
set_property -dict {PACKAGE_PIN L1 IOSTANDARD LVCMOS33} [get_ports {led[15]}]


## ================================================================
## TB6612FNG Motor Driver Pins - Pmod JA
##
## JA1 -> PWMA
## JA2 -> AIN1
## JA3 -> AIN2
## JA4 -> STBY
## ================================================================

set_property -dict {PACKAGE_PIN J1 IOSTANDARD LVCMOS33} [get_ports tb_pwma]
set_property -dict {PACKAGE_PIN L2 IOSTANDARD LVCMOS33} [get_ports tb_ain1]
set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports tb_ain2]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports tb_stby]


## ================================================================
## Encoder Inputs - Pmod JB
##
## JB1 -> Encoder A
## JB2 -> Encoder B
##
## Encoder must be powered from 3.3 V, not 5 V.
## ================================================================

set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33} [get_ports enc_a]
set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports enc_b]

## Optional pullups.
## Enable only if encoder signals float or open-collector output is used.
# set_property PULLUP true [get_ports enc_a]
# set_property PULLUP true [get_ports enc_b]


## ================================================================
## Kalman Core Multicycle Path Constraint
##
## Kalman MATLAB_Function block is sample-based.
## Ts = 0.01 s
## FPGA clock = 100 MHz -> 10 ns
## 0.01 s / 10 ns = 1,000,000 clock cycles
##
## This prevents Vivado from forcing the generated Kalman arithmetic
## to close timing in a single 10 ns cycle.
## ================================================================

## ================================================================
## Kalman Core Multicycle Path Constraint - robust version
## Ts = 0.01 s, clk = 100 MHz
## 0.01 / 10 ns = 1,000,000 cycles
## ================================================================


puts "KALMAN_REGS count = [llength [get_cells -hierarchical -filter {IS_SEQUENTIAL == 1 && NAME =~ *u_kalman*}]]"

set _xlnx_shared_i0 [get_cells -hierarchical -filter {IS_SEQUENTIAL == 1 && NAME =~ *u_kalman*}]
set_multicycle_path -setup -from $_xlnx_shared_i0 -to $_xlnx_shared_i0 1000000
set_multicycle_path -hold -from $_xlnx_shared_i0 -to $_xlnx_shared_i0 999999


create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk_IBUF_BUFG]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 12 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {enc_rad_s_dbg[0]} {enc_rad_s_dbg[1]} {enc_rad_s_dbg[2]} {enc_rad_s_dbg[3]} {enc_rad_s_dbg[4]} {enc_rad_s_dbg[5]} {enc_rad_s_dbg[6]} {enc_rad_s_dbg[7]} {enc_rad_s_dbg[8]} {enc_rad_s_dbg[9]} {enc_rad_s_dbg[10]} {enc_rad_s_dbg[11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 12 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {kalman_rad_s_dbg[0]} {kalman_rad_s_dbg[1]} {kalman_rad_s_dbg[2]} {kalman_rad_s_dbg[3]} {kalman_rad_s_dbg[4]} {kalman_rad_s_dbg[5]} {kalman_rad_s_dbg[6]} {kalman_rad_s_dbg[7]} {kalman_rad_s_dbg[8]} {kalman_rad_s_dbg[9]} {kalman_rad_s_dbg[10]} {kalman_rad_s_dbg[11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 12 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {selected_rad_s_dbg[0]} {selected_rad_s_dbg[1]} {selected_rad_s_dbg[2]} {selected_rad_s_dbg[3]} {selected_rad_s_dbg[4]} {selected_rad_s_dbg[5]} {selected_rad_s_dbg[6]} {selected_rad_s_dbg[7]} {selected_rad_s_dbg[8]} {selected_rad_s_dbg[9]} {selected_rad_s_dbg[10]} {selected_rad_s_dbg[11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 8 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {duty_dbg[0]} {duty_dbg[1]} {duty_dbg[2]} {duty_dbg[3]} {duty_dbg[4]} {duty_dbg[5]} {duty_dbg[6]} {duty_dbg[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 1 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list enc_direction_dbg]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list pwm_dbg]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list sample_tick_dbg]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list sw15_dbg]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_IBUF_BUFG]
