library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pwm_cnt is
    Port (
        i_clk        : in  STD_LOGIC;
        i_reset      : in  STD_LOGIC;
        o_pwm        : out STD_LOGIC;
        -- 修改後的監控輸出名稱
        o_state      : out STD_LOGIC; -- '0': brightening, '1': dimming
        o_cnt_up     : out STD_LOGIC_VECTOR(3 downto 0);
        o_cnt_down   : out STD_LOGIC_VECTOR(3 downto 0)
    );
end pwm_cnt;

architecture Behavioral of pwm_cnt is

    constant max         : STD_LOGIC_VECTOR(3 downto 0) := "1010"; -- 10
    constant min         : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    
    type state_type is (brightening, dimming);
    signal state         : state_type := brightening;
    
    signal cnt_up        : STD_LOGIC_VECTOR(3 downto 0) := min;
    signal cnt_down      : STD_LOGIC_VECTOR(3 downto 0) := max;
    signal pwm_cnt       : STD_LOGIC_VECTOR(3 downto 0) := min;

begin

    -- 訊號映射
    o_cnt_up   <= cnt_up;
    o_cnt_down <= cnt_down;
    o_state    <= '0' when state = brightening else '1';

    FSM: process(i_clk, i_reset)
    begin
        if i_reset = '1' then
            state <= brightening;
        elsif rising_edge(i_clk) then
            if pwm_cnt = max then
                case state is
                    when brightening =>
                        if cnt_up = max then state <= dimming; end if;
                    when dimming =>
                        if cnt_down = min then state <= brightening; end if;
                end case;
            end if;
        end if;
    end process FSM;

    up_counter: process(i_clk, i_reset)
    begin
        if i_reset = '1' then
            cnt_up <= min;
        elsif rising_edge(i_clk) then
            if pwm_cnt = max then
                if state = brightening then
                    if cnt_up < max then cnt_up <= cnt_up + 1; end if;
                else
                    cnt_up <= min;
                end if;
            end if;
        end if;
    end process up_counter;

    down_counter: process(i_clk, i_reset)
    begin
        if i_reset = '1' then
            cnt_down <= max;
        elsif rising_edge(i_clk) then
            if pwm_cnt = max then
                if state = dimming then
                    if cnt_down > min then cnt_down <= cnt_down - 1; end if;
                else
                    cnt_down <= max;
                end if;
            end if;
        end if;
    end process down_counter;

    pwm: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if pwm_cnt < max then
                pwm_cnt <= pwm_cnt + 1;
            else
                pwm_cnt <= min;
            end if;
            
            if state = brightening then
                if pwm_cnt < cnt_up then o_pwm <= '1'; else o_pwm <= '0'; end if;
            else
                if pwm_cnt < cnt_down then o_pwm <= '1'; else o_pwm <= '0'; end if;
            end if;
        end if;
    end process pwm;

end Behavioral;
