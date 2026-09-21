----------------------------------------------------------------------------------
-- Top_Module.vhd
--
-- Basys 3 top module for:
--   Encoder_Reader  -> Kalman_28_yeni
--   PWM_Generator   -> TB6612FNG motor driver
--
-- SW14 = 0 -> LED11..0 Kalman tahmini
-- SW14 = 1 -> LED11..0 Encoder ham ölçümü
--
-- Vivado ILA için debug sinyalleri eklendi.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Top_Module is
    port (
        clk       : in  std_logic; -- Basys 3 100 MHz clock
        reset_btn : in  std_logic; -- BTNC, active-high reset

        sw        : in  std_logic_vector(15 downto 0);

        enc_a     : in  std_logic;
        enc_b     : in  std_logic;

        tb_pwma   : out std_logic;
        tb_ain1   : out std_logic;
        tb_ain2   : out std_logic;
        tb_stby   : out std_logic;

        led       : out std_logic_vector(15 downto 0)
    );
end Top_Module;

architecture rtl of Top_Module is

    --------------------------------------------------------------------------
    -- Voltage command scaling
    --
    -- 12 V Q16 = 12 * 65536 = 786432
    -- 786432 / 255 = 3084
    --------------------------------------------------------------------------
    constant VOLT_PER_DUTY_Q16 : integer := 3084;

    --------------------------------------------------------------------------
    -- Encoder speed scaling
    --
    -- CPR = 11
    -- Gear ratio = 10
    -- x4 quadrature decoding
    -- COUNTS_PER_REV = 11 * 10 * 4 = 440
    --
    -- Ts = 0.01 s
    -- SPEED_GAIN_Q16 = 93585
    --------------------------------------------------------------------------
    constant ENC_SPEED_GAIN_Q16 : integer := 93585;

    signal reset             : std_logic;
    signal duty_cmd          : std_logic_vector(7 downto 0);
    signal direction_cmd     : std_logic;

    signal pwm_sig           : std_logic;

    signal u_q16_signed      : signed(31 downto 0);
    signal data_q16          : std_logic_vector(31 downto 0);
    signal w_est_q16         : std_logic_vector(31 downto 0);

    signal enc_direction     : std_logic;
    signal enc_sample_tick   : std_logic;

    signal kalman_ce_out     : std_logic;

    --------------------------------------------------------------------------
    -- ILA debug signals
    --
    -- Bunlar motor kontrolünü veya LED davranışını değiştirmez.
    -- Sadece Vivado ILA üzerinden iç sinyalleri izlemek içindir.
    --------------------------------------------------------------------------
    signal enc_rad_s_dbg       : std_logic_vector(11 downto 0);
    signal kalman_rad_s_dbg    : std_logic_vector(11 downto 0);
    signal selected_rad_s_dbg  : std_logic_vector(11 downto 0);

    signal duty_dbg            : std_logic_vector(7 downto 0);
    signal sw14_dbg            : std_logic;
    signal sw15_dbg            : std_logic;
    signal sample_tick_dbg     : std_logic;
    signal pwm_dbg             : std_logic;
    signal enc_direction_dbg   : std_logic;

    attribute mark_debug : string;
    attribute mark_debug of enc_rad_s_dbg      : signal is "true";
    attribute mark_debug of kalman_rad_s_dbg   : signal is "true";
    attribute mark_debug of selected_rad_s_dbg : signal is "true";
    attribute mark_debug of duty_dbg           : signal is "true";
    attribute mark_debug of sw14_dbg           : signal is "true";
    attribute mark_debug of sw15_dbg           : signal is "true";
    attribute mark_debug of sample_tick_dbg    : signal is "true";
    attribute mark_debug of pwm_dbg            : signal is "true";
    attribute mark_debug of enc_direction_dbg  : signal is "true";

begin

    reset         <= reset_btn;
    duty_cmd      <= sw(7 downto 0);
    direction_cmd <= sw(15);

    --------------------------------------------------------------------------
    -- ILA debug assignments
    --
    -- enc_rad_s_dbg      = encoder rad/s integer
    -- kalman_rad_s_dbg   = Kalman rad/s integer
    -- selected_rad_s_dbg = LED11..0 üzerinde gösterilen değer
    --------------------------------------------------------------------------
    enc_rad_s_dbg      <= data_q16(27 downto 16);
    kalman_rad_s_dbg   <= w_est_q16(27 downto 16);

    selected_rad_s_dbg <= data_q16(27 downto 16) when sw(14) = '1'
                          else w_est_q16(27 downto 16);

    duty_dbg           <= duty_cmd;
    sw14_dbg           <= sw(14);
    sw15_dbg           <= sw(15);
    sample_tick_dbg    <= enc_sample_tick;
    pwm_dbg            <= pwm_sig;
    enc_direction_dbg  <= enc_direction;

    --------------------------------------------------------------------------
    -- PWM generator
    --------------------------------------------------------------------------
    u_pwm : entity work.PWM_Generator(rtl)
        generic map (
            CLK_HZ => 100000000,
            PWM_HZ => 20000
        )
        port map (
            clk     => clk,
            reset   => reset,
            duty_u8 => duty_cmd,
            pwm_out => pwm_sig
        );

    tb_pwma <= pwm_sig;

    --------------------------------------------------------------------------
    -- TB6612FNG direction and standby control
    --
    -- direction_cmd = 0:
    --   AIN1 = 1, AIN2 = 0
    --
    -- direction_cmd = 1:
    --   AIN1 = 0, AIN2 = 1
    --------------------------------------------------------------------------
    tb_ain1 <= '1' when (reset = '0' and direction_cmd = '0') else '0';
    tb_ain2 <= '1' when (reset = '0' and direction_cmd = '1') else '0';

    -- STBY high olursa motor sürücü aktif olur
    tb_stby <= '1' when reset = '0' else '0';

    --------------------------------------------------------------------------
    -- Encoder reader
    --------------------------------------------------------------------------
    u_encoder : entity work.Encoder_Reader(rtl)
        generic map (
            SAMPLE_TICKS   => 1000000,
            SPEED_GAIN_Q16 => ENC_SPEED_GAIN_Q16
        )
        port map (
            clk         => clk,
            reset       => reset,
            enc_a       => enc_a,
            enc_b       => enc_b,
            speed_q16   => data_q16,
            direction   => enc_direction,
            sample_tick => enc_sample_tick
        );

    --------------------------------------------------------------------------
    -- Convert PWM duty to Kalman input voltage u in Q16.
    --
    -- Bu kısım senin çalışan versiyonundaki gibi bırakıldı.
    --------------------------------------------------------------------------
  process(duty_cmd, direction_cmd)
    variable mag_int : integer;
    variable mag_s   : signed(31 downto 0);
begin
    mag_int := to_integer(unsigned(duty_cmd)) * VOLT_PER_DUTY_Q16;
    mag_s   := to_signed(mag_int, 32);

    -- Encoder pozitif okuduğu yönde Kalman'a da pozitif u veriyoruz.
    if direction_cmd = '1' then
        u_q16_signed <= mag_s;
    else
        u_q16_signed <= -mag_s;
    end if;
end process;
    --------------------------------------------------------------------------
    -- HDL Coder Kalman core
    --
    -- Kalman input:
    --   u    = PWM duty'den hesaplanan voltage command
    --   data = ham encoder hız ölçümü
    --------------------------------------------------------------------------
    u_kalman : entity work.Kalman_28_yeni(rtl)
        port map (
            clk        => clk,
            reset      => reset,
            clk_enable => '1',
            u          => std_logic_vector(u_q16_signed),
            data       => data_q16,
            ce_out     => kalman_ce_out,
            w_est      => w_est_q16
        );

    --------------------------------------------------------------------------
    -- LED debug
    --
    -- SW14 = 0 -> Kalman tahmini
    -- SW14 = 1 -> Encoder ham hızı
    --
    -- LED11..0 rad/s integer kısmını gösterir.
    -- RPM = LED_value * 9.549
    --------------------------------------------------------------------------
    led(11 downto 0) <= data_q16(27 downto 16) when sw(14) = '1'
                        else w_est_q16(27 downto 16);

    led(12)          <= enc_sample_tick;
    led(13)          <= pwm_sig;
    led(14)          <= sw(14);          -- SW14 göstergesi
    led(15)          <= direction_cmd;   -- SW15 yön göstergesi

end rtl;