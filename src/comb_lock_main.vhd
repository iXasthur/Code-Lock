library IEEE;
use IEEE.std_logic_1164.all;

entity comb_lock_main is
	generic (
		BOARD_CLK_FREQ : natural := 50000000; -- CLK frequency in Hz
		SND_MODE: std_logic := '0' -- output generation mode: '0' = constant, '1' = waveform
	);
	port (
		CLK : in std_logic;
		RST : in std_logic;
		SWI : in std_logic_vector(3 downto 0);
		SEG : out std_logic_vector(7 downto 0);
		DIG : out std_logic_vector(5 downto 0);
		LDO : out std_logic_vector(3 downto 0);
		BPO : out std_logic
	);
end comb_lock_main;

architecture Behavioral of comb_lock_main is
    -- Constants
	constant interval_1sec : natural := BOARD_CLK_FREQ; -- 1 sec :: 50 MHz (T=20 ns)
	constant interval_100ms : natural := BOARD_CLK_FREQ/10; -- 100 ms
	constant interval_2ms : natural := BOARD_CLK_FREQ/500; -- 2 ms
	constant interval_5ms : natural := BOARD_CLK_FREQ/200; -- 5 ms
	constant interval_1ms : natural := BOARD_CLK_FREQ/1000; -- 1 ms
	constant long_beep_period : natural := BOARD_CLK_FREQ; -- 1 sec
	constant short_beep_period : natural := BOARD_CLK_FREQ/5; -- 200 ms
	constant sound_freq_period : natural := BOARD_CLK_FREQ/2000; -- 0.5 ms (Fsnd = 2 kHz)
	
	-- Buffer signals
	signal RST_sig : std_logic;
	signal SWI_sig : std_logic_vector(3 downto 0);
	signal LED_sig : std_logic_vector(3 downto 0);
	signal SEG_sig : std_logic_vector(7 downto 0);
	signal DIG_sig : std_logic_vector(5 downto 0);
	signal BPO_sig : std_logic;

	-- Device signals
	signal sw1_left_sig : std_logic;
	signal sw2_right_sig : std_logic;
	signal sw3_next_sig : std_logic;
	signal sw4_prev_sig : std_logic;
	signal led0_mode_sig : std_logic_vector(1 downto 0) := "00";
	signal led1_mode_sig : std_logic_vector(1 downto 0) := "00";
	signal led2_mode_sig : std_logic_vector(1 downto 0) := "00";
	signal led3_mode_sig : std_logic_vector(1 downto 0) := "00";
	signal dot_sig : std_logic_vector(5 downto 0) := (others => '0');
	signal digit0_sig : std_logic_vector(4 downto 0) := (others => '0');
	signal digit1_sig : std_logic_vector(4 downto 0) := (others => '0');
	signal digit2_sig : std_logic_vector(4 downto 0) := (others => '0');
	signal digit3_sig : std_logic_vector(4 downto 0) := (others => '0');
	signal digit4_sig : std_logic_vector(4 downto 0) := (others => '0');
	signal digit5_sig : std_logic_vector(4 downto 0) := (others => '0');
	signal beep_mode_sig : std_logic_vector(1 downto 0) := "00";
	signal beep_run_sig : std_logic := '0';
begin

	SWITCH_0: entity work.switch_driver(Behavioral)
		generic map (
			LPR_CP => interval_1sec,
			SWS_CP => interval_2ms,
			SW_ACT_ST => '1'
		)
		port map (
			CLK => CLK,
			RST => RST_sig,
			SWI => SWI_sig(0),
			FAE => sw1_left_sig,
			RIE => open,
			LVL => open,
			TGL => open,
			LPR => open
		);
	
	SWITCH_1: entity work.switch_driver(Behavioral)
		generic map (
			LPR_CP => interval_1sec,
			SWS_CP => interval_2ms,
			SW_ACT_ST => '1'
		)
		port map (
			CLK => CLK,
			RST => RST_sig,
			SWI => SWI_sig(1),
			FAE => sw2_right_sig,
			RIE => open,
			LVL => open,
			TGL => open,
			LPR => open
		);

	SWITCH_2: entity work.switch_driver(Behavioral)
		generic map (
			LPR_CP => interval_1sec,
			SWS_CP => interval_2ms,
			SW_ACT_ST => '1'
		)
		port map (
			CLK => CLK,
			RST => RST_sig,
			SWI => SWI_sig(2),
			FAE => sw3_next_sig,
			RIE => open,
			LVL => open,
			TGL => open,
			LPR => open
		);

	SWITCH_3: entity work.switch_driver(Behavioral)
		generic map (
			LPR_CP => interval_1sec,
			SWS_CP => interval_2ms,
			SW_ACT_ST => '1'
		)
		port map (
			CLK => CLK,
			RST => RST_sig,
			SWI => SWI_sig(3),
			FAE => sw4_prev_sig,
			RIE => open,
			LVL => open,
			TGL => open,
			LPR => open
		);
		
    LED_0: entity work.led_driver(Behavioral)
		generic map (
			TP_1S => interval_1sec,
			TP_100MS => interval_100ms
		)
		port map (
			CLK => CLK,
			RST => RST_sig,
			MODE => led0_mode_sig,
			LED => LED_sig(0)
		);
	
	LED_1: entity work.led_driver(Behavioral)
		generic map (
			TP_1S => interval_1sec,
			TP_100MS => interval_100ms
		)
		port map (
			CLK => CLK,
			RST => RST_sig,
			MODE => led1_mode_sig,
			LED => LED_sig(1)
		);
	
	LED_2: entity work.led_driver(Behavioral)
		generic map (
			TP_1S => interval_1sec,
			TP_100MS => interval_100ms
		)
		port map (
			CLK => CLK,
			RST => RST_sig,
			MODE => led2_mode_sig,
			LED => LED_sig(2)
		);
	
	LED_3: entity work.led_driver(Behavioral)
		generic map (
			TP_1S => interval_1sec,
			TP_100MS => interval_100ms
		)
		port map (
			CLK => CLK,
			RST => RST_sig,
			MODE => led3_mode_sig,
			LED => LED_sig(3)
		);
		
	HEX_DISPLAY: entity work.hexled_driver(Behavioral)
		generic map (
			CNT_LIMIT => interval_1ms
		)
		port map (
			CLK => CLK,
			RST => RST_sig,
			DT0 => dot_sig(0),
			DT1 => dot_sig(1),
			DT2 => dot_sig(2),
			DT3 => dot_sig(3),
			DT4 => dot_sig(4),
			DT5 => dot_sig(5),
			DDI0 => digit0_sig,
			DDI1 => digit1_sig,
			DDI2 => digit2_sig,
			DDI3 => digit3_sig,
			DDI4 => digit4_sig,
			DDI5 => digit5_sig,
			SEG_DAT => SEG_sig,
			DIG_SEL => DIG_sig
		);

	BUZZER: entity work.beep_driver(Behavioral)
		generic map (
			SND_MODE => SND_MODE,
			SHB_PERIOD => short_beep_period,
			LOB_PERIOD => long_beep_period,
			SND_PERIOD => sound_freq_period
		)
		port map (
			CLK => CLK,
			RST => RST_sig,
			START => beep_run_sig,
			MODE => beep_mode_sig,
			BEEP => BPO_sig
		);

	COMB_LOCK_LOGIC: entity work.comb_lock_logic(Behavioral)
		port map (
			CLK => CLK,
			RST	=> RST_sig,
			SWK1_LEFT => sw1_left_sig,
			SWK2_RIGHT => sw2_right_sig,
			SWK3_NEXT => sw3_next_sig,
			SWK4_PREV => sw4_prev_sig,
			DOT => dot_sig,
			REG0 => digit0_sig,
			REG1 => digit1_sig,
			REG2 => digit2_sig,
			REG3 => digit3_sig,
			REG4 => digit4_sig,
			REG5 => digit5_sig,
			LED0_MODE => led0_mode_sig,
			LED1_MODE => led1_mode_sig,
			LED2_MODE => led2_mode_sig,
			LED3_MODE => led3_mode_sig,
			BEEP_MODE => beep_mode_sig,
			BEEP_RUN => beep_run_sig
		);

	RST_sig <= not RST;
	SWI_sig <= not SWI;
	LDO <= LED_sig;
	BPO <= not BPO_sig;
	SEG <= not SEG_sig;
	DIG <= not DIG_sig;

end architecture Behavioral;