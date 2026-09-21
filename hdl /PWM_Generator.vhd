----------------------------------------------------------------------------------
-- PWM_Generator.vhd
-- 20 kHz PWM generator for TB6612FNG motor driver.
--
-- Input:
--   duty_u8 = 0..255
--
-- Output:
--   pwm_out to TB6612FNG PWMA pin
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PWM_Generator is
    generic (
        CLK_HZ : positive := 100000000;
        PWM_HZ : positive := 20000
    );
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        duty_u8  : in  std_logic_vector(7 downto 0);
        pwm_out  : out std_logic
    );
end PWM_Generator;

architecture rtl of PWM_Generator is

    constant PWM_PERIOD : positive := CLK_HZ / PWM_HZ; -- 100 MHz / 20 kHz = 5000

    signal cnt        : integer range 0 to PWM_PERIOD - 1 := 0;
    signal duty_count : integer range 0 to PWM_PERIOD := 0;
    signal pwm_reg    : std_logic := '0';

begin

    process(duty_u8)
        variable d : integer;
    begin
        d := to_integer(unsigned(duty_u8));
        duty_count <= (d * PWM_PERIOD) / 255;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                cnt     <= 0;
                pwm_reg <= '0';
            else
                if cnt = PWM_PERIOD - 1 then
                    cnt <= 0;
                else
                    cnt <= cnt + 1;
                end if;

                if cnt < duty_count then
                    pwm_reg <= '1';
                else
                    pwm_reg <= '0';
                end if;
            end if;
        end if;
    end process;

    pwm_out <= pwm_reg;

end rtl;
