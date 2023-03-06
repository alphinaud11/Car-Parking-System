library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
port (
			clk: in std_logic;
			count_out: out integer  
		);
end counter;		




architecture behavior of counter is
begin

process(clk)
variable count : integer := 0;
begin

if (clk'event) AND (clk = '1') then

if (count = 1000000) then
count := 0;

else
count := count + 1;

end if;
end if;

count_out <= count;

end process;
end behavior;


-----------------------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparator is
port (
			switch: in std_logic;
			count: in integer;
			PWM: out std_logic
		);
end comparator;		




architecture behavior of comparator is
begin

process(count,switch)
begin

if (switch = '0') then
if (count < 55000) then
PWM <= '1';

else
PWM <= '0';
end if;

else
if (count < 100000) then
PWM <= '1';

else
PWM <= '0';
end if;

end if;
end process;
end behavior;


-----------------------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity servo_motor is
port (
			clk1: in std_logic;
			switch1: in std_logic;
			PWM1: out std_logic
		);
end servo_motor;		




architecture behavior of servo_motor is
signal count_out1: integer;

component counter
port (
			clk: in std_logic;
			count_out: out integer  
		);
end component;

component comparator
port (
			switch: in std_logic;
			count: in integer;
			PWM: out std_logic
		);
end component;

begin

counter1 : counter port map (clk1,count_out1);
comparator1 : comparator port map (switch1,count_out1,PWM1);

end behavior;


-----------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clk_generator_1Hz is 
port (
			clk: in std_logic;
			clk_out: out std_logic
		);	
end clk_generator_1Hz;		




architecture behavior of clk_generator_1Hz is
signal clk_signal : std_logic;
begin

process(clk)
variable count : integer;
begin

if (clk'event) AND (clk = '1') then

if (count = 24999999) then
clk_signal <= NOT (clk_signal);
count := 0;

else
count := count + 1;

end if;
end if;
end process;

clk_out <= clk_signal;

end behavior;

-----------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clk_generator_2Hz is 
port (
			clk: in std_logic;
			clk_out: out std_logic
		);	
end clk_generator_2Hz;		




architecture behavior of clk_generator_2Hz is
signal clk_signal : std_logic;
begin

process(clk)
variable count : integer;
begin

if (clk'event) AND (clk = '1') then

if (count = 12499999) then
clk_signal <= NOT (clk_signal);
count := 0;

else
count := count + 1;

end if;
end if;
end process;

clk_out <= clk_signal;

end behavior;

-----------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Car_Parking_System is
port (
			clock: in std_logic;
			frontSensor,backSensor,flameSensor: in std_logic; 
			password: in std_logic_vector(9 downto 0); 
			greenLED,redLED: out std_logic;
			buzzer: out std_logic;
			servo: out std_logic;
			countdownLeft,countdownRight,leftDisplay,rightDisplay: out std_logic_vector(6 downto 0)
		);
end Car_Parking_System;		




architecture behavior of Car_Parking_System is
type MyStates is (IDLE,WAIT_PASSWORD,WRONG_PASS,RIGHT_PASS,STOP,EMERGENCY);
signal currentState: MyStates := IDLE;
signal nextState: MyStates;
signal countdownSig: unsigned(4 downto 0) := "10100";
signal greenSig, redSig: std_logic;
signal servoSwitch: std_logic;
signal clk1Hz: std_logic;
signal clk2Hz: std_logic;

component clk_generator_1Hz is 
port (
			clk: in std_logic;
			clk_out: out std_logic
		);	
end component;	

component clk_generator_2Hz is 
port (
			clk: in std_logic;
			clk_out: out std_logic
		);	
end component;	

component servo_motor is
port (
			clk1: in std_logic;
			switch1: in std_logic;
			PWM1: out std_logic
		);
end component;		

begin

clk_generator_1Hz0 : clk_generator_1Hz port map (clock,clk1Hz);
clk_generator_2Hz0 : clk_generator_2Hz port map (clock,clk2Hz);
servo_motor1 : servo_motor port map (clock,servoSwitch,servo);

process(clock)  -- Here current state is updated
begin
if (clock'event) AND (clock = '1') then
currentState <= nextState;
end if;
end process;

process(currentState,frontSensor,backSensor,flameSensor,countdownSig)  -- Here next state is decided 
begin
case currentState is
 
when IDLE =>
if (flameSensor = '1') then
nextState <= EMERGENCY;
elsif (frontSensor = '0') then  --ON
nextState <= WAIT_PASSWORD;
else
nextState <= IDLE;
end if;

when WAIT_PASSWORD =>
if (flameSensor = '1') then
nextState <= EMERGENCY;
else
if (countdownSig > "0000") then
nextState <= WAIT_PASSWORD;
else
if (password = "0101010101")  then
nextState <= RIGHT_PASS;
else
nextState <= WRONG_PASS;
end if;
end if;
end if;

when WRONG_PASS =>
if (flameSensor = '1') then
nextState <= EMERGENCY;
elsif (password = "0101010101") then
nextState <= RIGHT_PASS;
else
nextState <= WRONG_PASS;
end if;

when RIGHT_PASS =>
if (flameSensor = '1') then
nextState <= EMERGENCY;
elsif (frontSensor='0') AND (backSensor = '0') then  --ON
nextState <= STOP; 
elsif (backSensor= '0') then  --ON
nextState <= IDLE;
else
nextState <= RIGHT_PASS;
end if;

when STOP =>
if (flameSensor = '1') then
nextState <= EMERGENCY;
elsif (password = "0101010101")  then
nextState <= RIGHT_PASS;
else
nextState <= STOP;
end if;

when EMERGENCY =>
if (flameSensor = '0') then
nextState <= IDLE;
else
nextState <= EMERGENCY;
end if;

when others => nextState <= IDLE;

end case;
end process;

process(clk1Hz)
begin
if (clk1Hz'event) AND (clk1Hz = '1') then
if (currentState = WAIT_PASSWORD) then
countdownSig <= countdownSig - 1;
else
countdownSig <= "10100";
end if;
end if;
end process;

process(countdownSig)
begin
case countdownSig is    when "10100"=>
								countdownLeft <= "0010010";
								countdownRight <= "0000001";
								when "10011"=>
								countdownLeft <= "1001111";
								countdownRight <= "0000100";
								when "10010"=>
								countdownLeft <= "1001111";
								countdownRight <= "0000000";
								when "10001"=>
								countdownLeft <= "1001111";
								countdownRight <= "0001111";
								when "10000"=>
								countdownLeft <= "1001111";
								countdownRight <= "0100000";
								when "01111"=>
								countdownLeft <= "1001111";
								countdownRight <= "0100100";
								when "01110"=>
								countdownLeft <= "1001111";
								countdownRight <= "1001100";
								when "01101"=>
								countdownLeft <= "1001111";
								countdownRight <= "0000110";
								when "01100"=>
								countdownLeft <= "1001111";
								countdownRight <= "0010010";
								when "01011"=>
								countdownLeft <= "1001111";
								countdownRight <= "1001111";
								when "01010"=>
								countdownLeft <= "1001111";
								countdownRight <= "0000001";
								when "01001"=>
								countdownLeft <= "0000001";
								countdownRight <= "0000100";
								when "01000"=>
								countdownLeft <= "0000001";
								countdownRight <= "0000000";
								when "00111"=>
								countdownLeft <= "0000001";
								countdownRight <= "0001111";
								when "00110"=>
								countdownLeft <= "0000001";
								countdownRight <= "0100000";
								when "00101"=>
								countdownLeft <= "0000001";
								countdownRight <= "0100100";
								when "00100"=>
								countdownLeft <= "0000001";
								countdownRight <= "1001100";
								when "00011"=>
								countdownLeft <= "0000001";
								countdownRight <= "0000110";
								when "00010"=>
								countdownLeft <= "0000001";
								countdownRight <= "0010010";
								when "00001"=>
								countdownLeft <= "0000001";
								countdownRight <= "1001111";
								when others=>
								countdownLeft <= "1111111";
								countdownRight <= "1111111";
 
end case;
end process;


process(clk2Hz) -- change this clock to change the LED blinking period
begin
if (clk2Hz'event) AND (clk2Hz = '1') then
case(currentState) is

when IDLE => 
servoSwitch <= '0';
buzzer <= '0';
greenSig <= '0';
redSig <= '0';
leftDisplay <= "1111111"; -- off
rightDisplay <= "1111111"; -- off

when WAIT_PASSWORD =>
servoSwitch <= '0';
buzzer <= '0';
greenSig <= '0';
redSig <= '1'; 
-- RED LED turn on and Display 7-segment LED as EN to let the car know they need to input password
leftDisplay <= "0110000"; -- E 
rightDisplay <= "0001001"; -- n
 
when WRONG_PASS =>
servoSwitch <= '0';
buzzer <= '0';
greenSig <= '0'; -- if password is wrong, RED LED blinking 
redSig <= not redSig;
leftDisplay <= "0110000"; -- E
rightDisplay <= "0110000"; -- E
 
when RIGHT_PASS =>
servoSwitch <= '1';
buzzer <= '0';
greenSig <= not greenSig;
redSig <= '0'; -- if password is correct, GREEN LED blinking
leftDisplay <= "0100000"; -- 6
rightDisplay <= "0000001"; -- 0
 
when STOP =>
servoSwitch <= '0';
buzzer <= '0';
greenSig <= '0';
redSig <= not redSig; -- Stop the next car and RED LED blinking
leftDisplay <= "0100100"; -- 5
rightDisplay <= "0011000"; -- P

when EMERGENCY =>
servoSwitch <= '1';
buzzer <= '1';
greenSig <= '0';
redSig <= '1';
leftDisplay <= "0100000"; -- 6
rightDisplay <= "0000001"; -- 0
 
when others => 
servoSwitch <= '0';
buzzer <= '0';
greenSig <= '0';
redSig <= '0';
leftDisplay <= "1111111"; -- off
rightDisplay <= "1111111"; -- off
end case;
end if;
end process;

redLED <= redSig;
greenLED <= greenSig;
 
end behavior; 
-----------------------------------------------------------------------------------------------------------------







