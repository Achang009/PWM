library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pwm_cnt_tb is
end pwm_cnt_tb;

architecture sim of pwm_cnt_tb is

    component pwm_cnt
        Port (
            i_clk      : in  STD_LOGIC;
            i_reset    : in  STD_LOGIC;
            o_pwm      : out STD_LOGIC;
            o_state    : out STD_LOGIC;
            o_cnt_up   : out STD_LOGIC_VECTOR(3 downto 0);
            o_cnt_down : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    signal i_clk      : STD_LOGIC := '0';
    signal i_reset    : STD_LOGIC := '0';
    signal o_pwm      : STD_LOGIC;
    signal o_state    : STD_LOGIC;
    signal o_cnt_up   : STD_LOGIC_VECTOR(3 downto 0);
    signal o_cnt_down : STD_LOGIC_VECTOR(3 downto 0);

    constant clk_period : time := 10 ns;

begin

    uut: pwm_cnt
        port map (
            i_clk      => i_clk,
            i_reset    => i_reset,
            o_pwm      => o_pwm,
            o_state    => o_state,
            o_cnt_up   => o_cnt_up,
            o_cnt_down => o_cnt_down
        );

    clk_process : process
    begin
        i_clk <= '0';
        wait for clk_period/2;
        i_clk <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
    begin		
        i_reset <= '1';
        wait for 50 ns;
        i_reset <= '0';
        
        -- 跑 5us 應該足以看到 state 從 0 變 1 再變 0 的循環
        wait for 5000 ns;
        wait;
    end process;

end sim;