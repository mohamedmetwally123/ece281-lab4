----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/30/2025 09:45:41 AM
-- Design Name: 
-- Module Name: top_basy3_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_basy3_tb is
end top_basy3_tb;

architecture Behavioral of top_basy3_tb is

    Signal w_btnU: std_logic;
    
    --not there but helpful here
    signal w_btnc: std_logic;
    signal w_sw: std_logic_vector(7 downto 0);
    signal w_flags: std_logic_vector(3 downto 0);
    signal w_an, w_an_real: std_logic_vector(3 downto 0);
    signal w_seg: std_logic_vector(6 downto 0);
    constant k_clk_period : time := 1 ns;
    signal w_sign_bit: std_logic;

	--registers
    signal w_A, w_B, w_A_next, w_B_next: std_logic_vector(7 downto 0):=x"00";
    --ALU
    signal w_result, w_bin: std_logic_vector(7 downto 0);
    --controller output
    signal w_cycle: std_logic_vector(3 downto 0);
    
    --twoscomplement
    signal w_hund, w_tens, w_ones, w_sign: std_logic_vector(3 downto 0):= x"0";
    signal w_hex: std_logic_vector(3 downto 0);
    
    --the clock
    signal w_clk: std_logic;
    component controller_fsm is 
    port(
           i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0)
    );
    end component controller_fsm;
    
    component ALU is 
    port(
           i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0)
    );
    end component ALU;
    
    component twos_comp is
    port (
        i_bin: in std_logic_vector(7 downto 0);
        o_sign: out std_logic;
        o_hund: out std_logic_vector(3 downto 0);
        o_tens: out std_logic_vector(3 downto 0);
        o_ones: out std_logic_vector(3 downto 0)
    );
    end component twos_comp;
    
    component clock_divider is
        generic ( constant k_DIV : natural := 2	);
        port ( 	i_clk    : in std_logic;		   -- basys3 clk
                i_reset  : in std_logic;		   -- asynchronous
                o_clk    : out std_logic		   -- divided (slow) clock
        );
   end component clock_divider;
    
    component TDM4 is
    generic ( constant k_WIDTH : natural  := 4); -- bits in input and output
    Port ( i_clk		: in  STD_LOGIC;
           i_reset		: in  STD_LOGIC; -- asynchronous
           i_D3 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D2 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D1 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D0 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_data		: out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_sel		: out STD_LOGIC_VECTOR (3 downto 0)	-- selected data line (one-cold)
	);
	end component TDM4;
    
    component sevenseg_decoder is 
     Port ( 
     i_Hex : in STD_LOGIC_VECTOR (3 downto 0);
     o_seg_n : out STD_LOGIC_VECTOR (6 downto 0)
     );
     end component sevenseg_decoder;

begin

	controller_inst: controller_fsm
	port map(
	   i_reset => w_btnU,
	   i_adv => w_btnC,
	   o_cycle => w_cycle	
	);
	
	w_A_next <= w_sw;
	w_B_next <= w_sw;
    register_proc: process(w_cycle)
    begin
    --one change
        if w_cycle <= "0010" then
            w_A <= w_A_next;
        elsif w_cycle <= "0100" then 
            w_B <= w_B_next;
        end if;
    end process register_proc;
    
    ALU_inst: ALU
    port map(
        i_A => w_A,
        i_B => w_B,
        i_op => w_sw(2 downto 0),
        o_result => w_result,
        o_flags => w_flags
    );
    
    --mux for selecting A, B, or the result to go through
    with w_cycle select
        w_bin <= w_A when "0010",
                 w_B when "0100",
                 w_result when "1000",
                 --need to change it but I still don't know what to change it to
                 -------
                 -------
                 "00000000" when others;
                 
    --This blanks the displayer in the first state
    with w_cycle select
        w_an_real <= "1111" when "0001",
              w_an when others;
	twoscomplement: twos_comp
	port map(
	       i_bin => w_bin,
	       --just for now but I'll change it
	       o_sign => w_sign_bit,
	       o_hund => w_hund,
	       o_tens => w_tens,
	       o_ones => w_ones
	);



	clk_process : process
	begin
		w_clk <= '0';
		wait for k_clk_period/2;
		
		w_clk <= '1';
		wait for k_clk_period/2;
	end process clk_process;
	
	 --extend tbhe sign bit
	 w_sign <= (others => w_sign_bit);
	 TDM4_inst: TDM4
	 port map(
	      i_clk => w_clk,
	      --just for now
	      i_reset => w_btnU,
	      --just for now
	      i_D3 => w_sign,
	      i_D2 => w_hund,
	      i_D1 => w_tens,
	      i_D0 => w_ones, 
	      o_data => w_Hex,
	      o_sel => w_an
	 );
	
	sevenseg: sevenseg_decoder
	port map(
	       i_hex => w_hex,
	       o_seg_n => w_seg
	);
	--just for now
	
	sim: process
	begin
	w_btnc <= '0';
	w_btnu <= '0';
	wait for 10 ns;
	w_sw <= x"80";
	w_btnc <= '1';
	wait for 20 ns;
	w_btnc <= '0';
	wait for 10 ns;
	
    w_sw <= "00000111";
	w_btnc <= '1';
	wait for 20 ns;
	
	w_btnc <= '0';
	wait for 10 ns;
	w_sw(2 downto 0) <= "001";
	w_btnc <= '1';
	wait for 20 ns;

	
	wait;
	end process;

end Behavioral;
