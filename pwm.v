library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pwmcnt is
    Port (
        i_clk   : in  STD_LOGIC;
        i_reset : in  STD_LOGIC;
        o_cnt   : out STD_LOGIC_VECTOR(3 downto 0);
        o_pwm   : out STD_LOGIC
    );
end pwmcnt;

architecture Behavioral of pwmcnt is

    constant max         : unsigned(3 downto 0) := "1111";
    constant min         : unsigned(3 downto 0) := "0000";
    signal state         : STD_LOGIC := '0';
    signal cnt           : unsigned(3 downto 0) := min;
    signal bin_cnt       : STD_LOGIC_VECTOR(24 downto 0) := (others => '0');
    signal f_clk         : std_logic := '0';
    signal pwm_cnt       : unsigned(3 downto 0) := min;
begin

    frequency_divider: process(i_clk, i_reset)
    begin
        if i_reset = '1' then
            bin_cnt <= (others => '0');
        elsif rising_edge(i_clk) then
            bin_cnt <= bin_cnt + 1;
        end if;
    end process frequency_divider;

    f_clk <= bin_cnt(24);

    FSM: process(f_clk, i_reset)
    begin
        if i_reset = '1' then
            state <= '0';
        elsif rising_edge(f_clk) then
            case state is
                when '0' =>
                    if cnt = max then
                        state <= '1';
                    end if;
                when '1' =>
                    if cnt = min then
                        state <= '0';
                    end if;
                when others =>
                    state <= '0';
            end case;
        end if;
    end process FSM;

    updown_counter: process(f_clk, i_reset)
    begin
        if i_reset = '1' then
            cnt <= min;
        elsif rising_edge(f_clk) then
            if state = '0' then
                if cnt < max then
                    cnt <= cnt + 1;
                end if;
            else
                if cnt > min then
                    cnt <= cnt - 1;
                end if;
            end if;
        end if;
    end process updown_counter;

    pwm: process(i_clk)
    begin
        if rising_edge(i_clk) then
            pwm_cnt <= pwm_cnt + 1;
            
            if pwm_cnt < cnt then
                o_pwm <= '1';
            else
                o_pwm <= '0';
            end if;
        end if;
    end process pwm;

    o_cnt <= std_logic_vector(cnt);

end Behavioral;

