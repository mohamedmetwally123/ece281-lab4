----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/29/2025 10:10:17 AM
-- Design Name: 
-- Module Name: top_tb - Behavioral
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

entity top_tb is
end top_tb;

architecture Behavioral of top_tb is
    component controller_fsm is 
    port(
           i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0)
    );
    end component;
    signal w_reset, w_adv: std_logic;
    signal w_cycle: std_logic_vector(3 downto 0);
begin
    controller_inst: controller_fsm
	port map(
	   i_reset => w_reset,
	   i_adv => w_adv,
	   o_cycle => w_cycle	
	);
	
	sim: process
	begin
	w_reset <= '0';
	w_adv <= '0';
	wait for 10 ns;
	w_adv <= '0';
	wait for 10 ns;
	w_adv <= '1';
	wait for 10 ns;
	assert w_cycle = "0010"; wait for 10 ns;
            report "ADD carry: wrong result" severity error;
    w_adv <= '0';wait for 10 ns;
	w_adv <= '1';wait for 10 ns;
	assert w_cycle = "0100";wait for 10 ns;
            report "ADD carry: wrong result" severity error;
	w_adv <= '0';wait for 10 ns;
	w_adv <= '1';wait for 10 ns;
	assert w_cycle = "1000"; wait for 10 ns;
            report "ADD carry: wrong result" severity error;
    w_adv <= '0';wait for 10 ns;
	w_adv <= '1';wait for 10 ns;
	assert w_cycle = "0001"; wait for 10 ns;
            report "ADD carry: wrong result" severity error;
	wait;
	end process;

end Behavioral;
