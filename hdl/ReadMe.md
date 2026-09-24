 How to View and Run VHDL (.vhd) Files

The `.vhd` files in this directory are Hardware Description Language (VHDL) source codes. 
Unlike standard software scripts (e.g., Python or C++), they cannot be executed directly on a standard PC operating system. 
They are designed to describe digital logic structures and must be synthesized for FPGA hardware.

Viewing the Source Code
You do not need specialized engineering software just to read or review the code. You can open and inspect any `.vhd` file using standard text editors such as:
* Visual Studio Code (VS Code)
* Notepad++
* Sublime Text
* GitHub's native file viewer

Simulating and Synthesizing
To simulate the hardware logic, run testbenches, or generate a bitstream (`.bit`) to program an actual FPGA, you must use an EDA (Electronic Design Automation) environment. 

These modules were developed, simulated, and hardware-verified using:
* **Development Environment:** Xilinx Vivado Design Suite
* **Target Hardware:** Digilent Basys 3 FPGA Board (Xilinx Artix-7)

**Steps to implement in Vivado:**
1. Create a new RTL Project in Xilinx Vivado.
2. Add the `.vhd` files from this `hdl` folder as **Design Sources**.
3. Add the corresponding `.xdc` constraint file (if applicable) to map the I/O ports to the physical board.
4. Run Synthesis, Implementation, and Generate Bitstream.
