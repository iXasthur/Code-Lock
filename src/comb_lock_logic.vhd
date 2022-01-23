library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity comb_lock_logic is
	port (
		CLK : in std_logic;
		RST : in std_logic;
		SWK1_LEFT : in std_logic;
		SWK2_RIGHT : in std_logic;
		SWK3_NEXT : in std_logic;
		SWK4_PREV : in std_logic;
		DOT : out std_logic_vector(5 downto 0);
		REG0 : out std_logic_vector(4 downto 0);
		REG1 : out std_logic_vector(4 downto 0);
		REG2 : out std_logic_vector(4 downto 0);
		REG3 : out std_logic_vector(4 downto 0);
		REG4 : out std_logic_vector(4 downto 0);
		REG5 : out std_logic_vector(4 downto 0);
		LED0_MODE : out std_logic_vector(1 downto 0);
		LED1_MODE : out std_logic_vector(1 downto 0);
		LED2_MODE : out std_logic_vector(1 downto 0);
		LED3_MODE : out std_logic_vector(1 downto 0);
		BEEP_MODE : out std_logic_vector(1 downto 0);
		BEEP_RUN : out std_logic
	);
end comb_lock_logic;

architecture Behavioral of comb_lock_logic is
--	constant reg_sig_key_0 : unsigned(4 downto 0) := "00001";
--	constant reg_sig_key_1 : unsigned(4 downto 0) := "00000";
--	constant reg_sig_key_2 : unsigned(4 downto 0) := "00000";
--	constant reg_sig_key_3 : unsigned(4 downto 0) := "00000";
--	constant reg_sig_key_4 : unsigned(4 downto 0) := "00000";
--	constant reg_sig_key_5 : unsigned(4 downto 0) := "00000";
	
	type lock_state_type is (idle, key_check, inc_pointer, dec_pointer, inc_reg, dec_reg);
	type reg_data_type is array (0 to 5) of unsigned(4 downto 0);
	
	signal lock_state : lock_state_type := idle;
	signal reg_sig : reg_data_type := (others => (others => '0'));
	signal reg_sig_key : reg_data_type := (others => (others => '1'));
	signal pointer_sig : natural range 0 to 5 := 0;
	signal beep_mode_sig : std_logic_vector(1 downto 0) := "00";
	signal beep_run_sig : std_logic := '0';
	signal key_hit_sig : std_logic := '0';
begin
    reg_sig_key(0) <= "00001";
    reg_sig_key(1) <= "00000";
    reg_sig_key(2) <= "00000";
    reg_sig_key(3) <= "00000";
    reg_sig_key(4) <= "00000";
    reg_sig_key(5) <= "00000";
	
	lock_logic: process(CLK, RST) 
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				lock_state <= idle; 
				pointer_sig <= 0;
				reg_sig <= (others => (others => '0'));
				beep_mode_sig <= "00";
				beep_run_sig <= '0';
			else 
				case lock_state is 
					when idle =>
						beep_run_sig <= '0';
						-- beep_mode_sig <= "00";
						if SWK1_LEFT = '1' then
							lock_state <= inc_pointer;
						elsif SWK2_RIGHT = '1' then
							lock_state <= dec_pointer;
						elsif SWK3_NEXT = '1' then
							lock_state <= inc_reg;
						elsif SWK4_PREV = '1' then
							lock_state <= dec_reg;
						end if;
                    when key_check =>
--						if (reg_sig(0) = reg_sig_key_0 and reg_sig(1) = reg_sig_key_1 and reg_sig(2) = reg_sig_key_2 and reg_sig(3) = reg_sig_key_3 and reg_sig(4) = reg_sig_key_4 and reg_sig(5) = reg_sig_key_5) then
--                            beep_mode_sig <= "11";
--                            beep_run_sig <= '1';
--                            key_hit_sig <= '1';
--                        else
--                            key_hit_sig <= '0';
--                        end if;
                        
                        if (reg_sig = reg_sig_key) then
                            beep_mode_sig <= "11";
                            beep_run_sig <= '1';
                            key_hit_sig <= '1';
                        else
                            key_hit_sig <= '0';
                        end if;
                        
						lock_state <= idle;
					when inc_pointer =>
						if pointer_sig = 5 then
							pointer_sig <= 0;
						else
							pointer_sig <= pointer_sig + 1;
						end if;
						
						lock_state <= idle;
					when dec_pointer =>
						if pointer_sig = 0 then
							pointer_sig <= 5;
						else
							pointer_sig <= pointer_sig - 1;
						end if;
						
						lock_state <= idle;
					when inc_reg =>
						if reg_sig(pointer_sig) = "01111" then
							reg_sig(pointer_sig) <= "00000";
						else
							reg_sig(pointer_sig) <= reg_sig(pointer_sig) + 1;
						end if;
						
						lock_state <= key_check;
					when dec_reg =>
						if reg_sig(pointer_sig) = "00000" then
							reg_sig(pointer_sig) <= "01111";
						else
							reg_sig(pointer_sig) <= reg_sig(pointer_sig) - 1;
						end if;
						
						lock_state <= key_check;
				end case; 
			end if; 
		end if; 
	end process;

	DOT <= "000001" when pointer_sig = 0 else
	       "000010" when pointer_sig = 1 else
	       "000100" when pointer_sig = 2 else
	       "001000" when pointer_sig = 3 else
	       "010000" when pointer_sig = 4 else
	       "100000"; -- pointer_sig = 5
	
	REG0 <= std_logic_vector(reg_sig(0));
	REG1 <= std_logic_vector(reg_sig(1));
	REG2 <= std_logic_vector(reg_sig(2));
	REG3 <= std_logic_vector(reg_sig(3));
	REG4 <= std_logic_vector(reg_sig(4));
	REG5 <= std_logic_vector(reg_sig(5));

	LED0_MODE <= '0' & key_hit_sig;
	LED1_MODE <= '0' & key_hit_sig;
	LED2_MODE <= '0' & key_hit_sig;
	LED3_MODE <= '0' & key_hit_sig;

	BEEP_MODE <= beep_mode_sig;
	BEEP_RUN <= beep_run_sig;
	
end architecture Behavioral;