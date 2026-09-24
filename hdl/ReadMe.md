How to Run and Synthesize VHDL (.vhd) Files

The `.vhd` files in this directory are Hardware Description Language (VHDL) source codes. 
They are designed to describe digital logic structures and must be synthesized for FPGA hardware rather than executed like standard software scripts.

To simulate the hardware logic, run testbenches, or generate a bitstream (`.bit`) to program an actual FPGA, you must use an EDA (Electronic Design Automation) environment. 

These modules were developed, simulated, and hardware-verified using:
* **Development Environment:** Xilinx Vivado Design Suite
* **Target Hardware:** Digilent Basys 3 FPGA Board (Xilinx Artix-7)

**Steps to implement in Vivado:**
1. Create a new RTL Project in Xilinx Vivado.
2. Add the `.vhd` files from this `hdl` folder as **Design Sources**.
3. Add the corresponding `.xdc` constraint file (if applicable) to map the I/O ports to the physical board.
4. Run Synthesis, Implementation, and Generate Bitstream.
