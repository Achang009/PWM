library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pwm_cnt is
    Port (
        i_clk   : in  STD_LOGIC;
        i_reset : in  STD_LOGIC;
        o_pwm   : out STD_LOGIC
    );
end pwm_cnt;

architecture Behavioral of pwm_cnt is

    constant max         : STD_LOGIC_VECTOR(3 downto 0) := "1111";
    constant min         : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal state         : STD_LOGIC := '0';
    signal cnt_up        : STD_LOGIC_VECTOR(3 downto 0) := min;
    signal cnt_down      : STD_LOGIC_VECTOR(3 downto 0) := max;
    signal bin_cnt       : STD_LOGIC_VECTOR(24 downto 0) := (others => '0');
    signal f_clk         : std_logic := '0';
    signal pwm_cnt       : STD_LOGIC_VECTOR(3 downto 0) := min;

begin

    frequency_divider: process(i_clk, i_reset)
    begin
        if i_reset = '1' then
            bin_cnt <= (others => '0');
        elsif rising_edge(i_clk) then
            bin_cnt <= bin_cnt + 1;
        end if;
    end process frequency_divider;

    f_clk <= bin_cnt(16);

    FSM: process(i_clk, i_reset)
    begin
        if i_reset = '1' then
            state <= '0';
        elsif rising_edge(i_clk) then
            if pwm_cnt = max then
                case state is
                    when '0' =>
                        if cnt_up = max then
                            state <= '1';
                        end if;
                    when '1' =>
                        if cnt_down = min then
                            state <= '0';
                        end if;
                    when others =>
                        state <= '0';
                end case;
            end if;
        end if;
    end process FSM;

    up_counter: process(f_clk, i_reset)
    begin
        if i_reset = '1' then
            cnt_up <= min;
        elsif rising_edge(f_clk) then
            if pwm_cnt = max then
                if state = '0' then
                    if cnt_up < max then
                        cnt_up <= cnt_up + 1;
                    else
                        cnt_up <= max;
                    end if;
                else
                    cnt_up <= min;
                end if;
            end if;
        end if;
    end process up_counter;

    down_counter: process(f_clk, i_reset)
    begin
        if i_reset = '1' then
            cnt_down <= max;
        elsif rising_edge(f_clk) then
            if pwm_cnt = max then
                if state = '1' then
                    if cnt_down > min then
                        cnt_down <= cnt_down - 1;
                    else
                        cnt_down <= min;
                    end if;
                else
                    cnt_down <= max;
                end if;
            end if;
        end if;
    end process down_counter;

    pwm: process(f_clk)
    begin
        if rising_edge(f_clk) then
            pwm_cnt <= pwm_cnt + 1;
            
            if state = '0' then
                if pwm_cnt < cnt_up then
                    o_pwm <= '1';
                else
                    o_pwm <= '0';
                end if;
            else
                if pwm_cnt < cnt_down then
                    o_pwm <= '1';
                else
                    o_pwm <= '0';
                end if;
            end if;
        end if;
    end process pwm;

end Behavioral;
