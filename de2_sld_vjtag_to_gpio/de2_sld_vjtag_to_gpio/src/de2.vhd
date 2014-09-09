-- ----------------------------------------------------------------
-- de2/cyclone2/sld_vjtag_to_gpio/src/de2.vhd
--
-- 11/2/2010 D. W. Hawkins (dwh@ovro.caltech.edu)
--
-- Altera Virtual JTAG (sld_virtual_jtag) component DE2 board test.
--
-- Design functionality:
--
--  * An sld_virtual_jtag component, which includes the
--    JTAG signal TCK/TMS/TDI/TDO and one-hot states for
--    the JTAG TAP and Virtual JTAG states.
--
--  * The JTAG and Virtual JTAG signals are connected to
--    GPIO-B for probing with an external logic analyzer.
--
--    These same signals can be probed using a SignalTap II
--    logic analyzer instance (by enabling this project's
--    SignalTap II instance in Quartus II). Since SignalTap II
--    also uses the JTAG interface, the JTAG traces will
--    be different relative to the external logic analyzer.
--
--  * The Virtual Instruction register output port connects to
--    the 9-bits of green LEDs, 18-bits of red LEDs, and the
--    LSB 16-bits are displayed on the four right hex displays
--    on the 4-wide hex display (right-most display).
--
--  * The Virtual Instruction register input port connects to
--    the 18-bits of switches. The LSB 8-bits of the switches
--    are also connected to the middle 4-wide hex display.
--
--  * The four push buttons control the value visible on the
--    left 2-wide hex display.
--
-- ----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Altera components
library altera_mf;
use altera_mf.altera_mf_components.all;

-------------------------------------------------------------------

entity de2 is
	generic (
		-- Virtual JTAG IR width
		SLD_IR_WIDTH  : integer := 18
	);
    port (
        -- Input clocks
        clk_50MHz    : in    std_logic;
        clk_27MHz    : in    std_logic;
        clk_sma      : in    std_logic;

        -- SDRAM
        sdram_clk    : out   std_logic;
        sdram_cke    : out   std_logic;
        sdram_csN    : out   std_logic;
        sdram_rasN   : out   std_logic;
        sdram_casN   : out   std_logic;
        sdram_weN    : out   std_logic;
        sdram_ba     : out   std_logic_vector( 1 downto 0);
        sdram_addr   : out   std_logic_vector(11 downto 0);
        sdram_dqm    : out   std_logic_vector( 1 downto 0);
        sdram_dq     : inout std_logic_vector(15 downto 0);

        -- Switches
        sw           : in    std_logic_vector(17 downto 0);

        -- Push-buttons
        key          : in    std_logic_vector(3 downto 0);

        -- Hex displays
        hex_a        : out   std_logic_vector(6 downto 0);
        hex_b        : out   std_logic_vector(6 downto 0);
        hex_c        : out   std_logic_vector(6 downto 0);
        hex_d        : out   std_logic_vector(6 downto 0);
        hex_e        : out   std_logic_vector(6 downto 0);
        hex_f        : out   std_logic_vector(6 downto 0);
        hex_g        : out   std_logic_vector(6 downto 0);
        hex_h        : out   std_logic_vector(6 downto 0);

        -- LCD
        lcd_on       : out   std_logic;
        lcd_blon     : out   std_logic;
        lcd_rs       : out   std_logic;
        lcd_en       : out   std_logic;
        lcd_rw       : out   std_logic;
        lcd_d        : out   std_logic_vector(7 downto 0);

        -- USB OTG Controller
        otg_resetN   : out   std_logic;
        otg_csN      : out   std_logic;
        otg_rdN      : out   std_logic;
        otg_wrN      : out   std_logic;
        otg_fspeed   : out   std_logic;
        otg_lspeed   : out   std_logic;
        otg_irq      : in    std_logic_vector( 1 downto 0);
        otg_dreq     : in    std_logic_vector( 1 downto 0);
        otg_dackN    : out   std_logic_vector( 1 downto 0);
        otg_addr     : out   std_logic_vector( 1 downto 0);
        otg_dq       : inout std_logic_vector(15 downto 0);

        -- Audio interface
        aud_adclrck  : out   std_logic;
        aud_daclrck  : out   std_logic;
        aud_dacdat   : out   std_logic;
        aud_bclk     : out   std_logic;
        aud_xck      : out   std_logic;
        aud_adcdat   : in    std_logic;

        -- I2C bus (audio interface and TV decoder control)
        i2c_sclk     : out   std_logic;
        i2c_sdat     : inout std_logic;

        -- TV Decoder
        td_resetN    : out   std_logic;
        td_hs        : in    std_logic;
        td_vs        : in    std_logic;
        td_d         : in    std_logic_vector(7 downto 0);

        -- VGA
        vga_blankN   : out   std_logic;
        vga_syncN    : out   std_logic;
        vga_hs       : out   std_logic;
        vga_vs       : out   std_logic;
        vga_clock    : out   std_logic;
        vga_r        : out   std_logic_vector(9 downto 0);
        vga_g        : out   std_logic_vector(9 downto 0);
        vga_b        : out   std_logic_vector(9 downto 0);

        -- USB Blaster interface
        link_in      : in    std_logic_vector(2 downto 0);
        link_out     : out   std_logic;

        -- Ethernet controller
        enet_clk     : out   std_logic;
        enet_resetN  : out   std_logic;
        enet_csN     : out   std_logic;
        enet_cmd     : out   std_logic;
        enet_iowN    : out   std_logic;
        enet_iorN    : out   std_logic;
        enet_irqN    : in    std_logic;
        enet_dq      : inout std_logic_vector(15 downto 0);

        -- RS232
        uart_txd     : out   std_logic;
        uart_rxd     : in    std_logic;

        -- PS/2
        ps2_clk      : out   std_logic;
        ps2_dat      : inout std_logic;

        -- GPIO (expansion headers)
        gpio_a       : inout std_logic_vector(35 downto 0);
        gpio_b       : inout std_logic_vector(35 downto 0);

        -- SD Card interface
        sd_cmd       : out   std_logic;
        sd_clk       : out   std_logic;
        sd_dat3      : out   std_logic;
        sd_dat       : inout std_logic;

        -- IrDA interface
        irda_txd     : out   std_logic;
        irda_rxd     : in    std_logic;

        -- Red and Green LEDs
        led_r        : out   std_logic_vector(17 downto 0);
        led_g        : out   std_logic_vector( 8 downto 0);

        -- Flash
        flash_resetN : out   std_logic;
        flash_ceN    : out   std_logic;
        flash_weN    : out   std_logic;
        flash_oeN    : out   std_logic;
        flash_addr   : out   std_logic_vector(21 downto 0);
        flash_dq     : inout std_logic_vector( 7 downto 0);

        -- SRAM
        sram_ceN     : out   std_logic;
        sram_weN     : out   std_logic;
        sram_oeN     : out   std_logic;
        sram_beN     : out   std_logic_vector( 1 downto 0);
        sram_addr    : out   std_logic_vector(17 downto 0);
        sram_dq      : inout std_logic_vector(15 downto 0)
    );
end entity;

-------------------------------------------------------------------

-- Disable Quartus warnings:
-- * 10296 null range warning for sld_sim_action
--
-- altera message_off 10296

architecture structural of de2 is

    -- ------------------------------------------------------------
    -- Components
    -- ------------------------------------------------------------
	--
	component hex_display is
		port (
			hex     : in  std_logic_vector(3 downto 0);
			display : out std_logic_vector(6 downto 0)
		);
	end component;

    -- ------------------------------------------------------------
    -- Internal signals
    -- ------------------------------------------------------------
	--
    signal hex : std_logic_vector(3 downto 0);

	-- JTAG signals
	signal tck : std_logic;
	signal tms : std_logic;
	signal tdo : std_logic := '0';
	signal tdi : std_logic;

	-- Virtual instruction register
	signal vir_in  : std_logic_vector(SLD_IR_WIDTH-1 downto 0);
	signal vir_out : std_logic_vector(SLD_IR_WIDTH-1 downto 0);

	-- Virtual instruction register (padded to 36-bits)
	signal vir_in36 : std_logic_vector(35 downto 0);

	-- JTAG TAP controller one-hot states
	signal jtag_state_tlr     : std_logic;
	signal jtag_state_rti     : std_logic;
	signal jtag_state_sdrs    : std_logic;
	signal jtag_state_cdr     : std_logic;
	signal jtag_state_sdr     : std_logic;
	signal jtag_state_e1dr    : std_logic;
	signal jtag_state_pdr     : std_logic;
	signal jtag_state_e2dr    : std_logic;
	signal jtag_state_udr     : std_logic;
	signal jtag_state_sirs    : std_logic;
	signal jtag_state_cir     : std_logic;
	signal jtag_state_sir     : std_logic;
	signal jtag_state_e1ir    : std_logic;
	signal jtag_state_pir     : std_logic;
	signal jtag_state_e2ir    : std_logic;
	signal jtag_state_uir     : std_logic;

	-- Virtual JTAG controller one-hot states
	signal virtual_state_cdr  : std_logic;
	signal virtual_state_sdr  : std_logic;
	signal virtual_state_e1dr : std_logic;
	signal virtual_state_pdr  : std_logic;
	signal virtual_state_e2dr : std_logic;
	signal virtual_state_udr  : std_logic;
	signal virtual_state_cir  : std_logic;
	signal virtual_state_uir  : std_logic;

begin

	-- ============================================================
	-- Virtual JTAG interface
	-- ============================================================
	--
	u1: sld_virtual_jtag
		generic map (
			sld_auto_instance_index => "YES",
			sld_instance_index      => 0,
			sld_ir_width            => SLD_IR_WIDTH,
			sld_sim_action          => "",
			sld_sim_n_scan          => 0,
			sld_sim_total_length    => 0,
			lpm_type                => "sld_virtual_jtag"
		)
		port map (
			-- JTAG signals
			tck                => tck,
			tms                => tms,
			tdo                => tdo,
			tdi                => tdi,

			-- Virtual instruction register
			ir_in              => vir_in,
			ir_out             => vir_out,

			-- JTAG TAP controller one-hot states
			jtag_state_tlr     => jtag_state_tlr,
			jtag_state_rti     => jtag_state_rti,
			jtag_state_sdrs    => jtag_state_sdrs,
			jtag_state_cdr     => jtag_state_cdr,
			jtag_state_sdr     => jtag_state_sdr,
			jtag_state_e1dr    => jtag_state_e1dr,
			jtag_state_pdr     => jtag_state_pdr,
			jtag_state_e2dr    => jtag_state_e2dr,
			jtag_state_udr     => jtag_state_udr,
			jtag_state_sirs    => jtag_state_sirs,
			jtag_state_cir     => jtag_state_cir,
			jtag_state_sir     => jtag_state_sir,
			jtag_state_e1ir    => jtag_state_e1ir,
			jtag_state_pir     => jtag_state_pir,
			jtag_state_e2ir    => jtag_state_e2ir,
			jtag_state_uir     => jtag_state_uir,

			-- Virtual JTAG controller one-hot states
			virtual_state_cdr  => virtual_state_cdr,
			virtual_state_sdr  => virtual_state_sdr,
			virtual_state_e1dr => virtual_state_e1dr,
			virtual_state_pdr  => virtual_state_pdr,
			virtual_state_e2dr => virtual_state_e2dr,
			virtual_state_udr  => virtual_state_udr,
			virtual_state_cir  => virtual_state_cir,
			virtual_state_uir  => virtual_state_uir
		);

	-- ============================================================
	-- Board I/O
	-- ============================================================
	--
    -- ------------------------------------------------------------
	-- Toggle the TDO output
    -- ------------------------------------------------------------
	--
	-- The toggling TDO makes is easier to see where TCK clock
	-- edges are in the logic analyzer traces since each TDO edge
	-- corresponds to a TCK rising edge.
	--
	process(tck)
	begin
		if rising_edge(tck) then
			tdo <= not tdo;
		end if;
	end process;

    -- ------------------------------------------------------------
	-- Pad the virtual instruction input to 36-bits
    -- ------------------------------------------------------------
	--
	-- This simplifies the connection to the GPIO, LEDs and
	-- hex displays
	--
	vir_in36 <= std_logic_vector(resize(unsigned(vir_in), 36));

    -- ------------------------------------------------------------
	-- Logic analyzer connections
    -- ------------------------------------------------------------
	--
	-- On the DE2 board:
	--  * GPIO-A is nearer the FPGA
	--  * GPIO-B is nearer the PCB edge
	--  * Even GPIO bits are closer to the FPGA
	--  * Odd GPIO bits are nearer the PCB edge
	--
	-- JTAG signals
	gpio_b(0) <= tck;
	gpio_b(1) <= tms;
	gpio_b(2) <= tdi;
	gpio_b(3) <= tdo;

	-- JTAG TAP controller one-hot states
	gpio_b(4)  <= jtag_state_tlr;
	gpio_b(5)  <= jtag_state_rti;
	gpio_b(6)  <= jtag_state_sdrs;
	gpio_b(7)  <= jtag_state_cdr;
	gpio_b(8)  <= jtag_state_sdr;
	gpio_b(9)  <= jtag_state_e1dr;
	gpio_b(10) <= jtag_state_pdr;
	gpio_b(11) <= jtag_state_e2dr;
	gpio_b(12) <= jtag_state_udr;
	gpio_b(13) <= jtag_state_sirs;
	gpio_b(14) <= jtag_state_cir;
	gpio_b(15) <= jtag_state_sir;
	gpio_b(16) <= jtag_state_e1ir;
	gpio_b(17) <= jtag_state_pir;
	gpio_b(18) <= jtag_state_e2ir;
	gpio_b(19) <= jtag_state_uir;

	-- Virtual JTAG controller one-hot states
	gpio_b(20) <= virtual_state_cdr;
	gpio_b(21) <= virtual_state_sdr;
	gpio_b(22) <= virtual_state_e1dr;
	gpio_b(23) <= virtual_state_pdr;
	gpio_b(24) <= virtual_state_e2dr;
	gpio_b(25) <= virtual_state_udr;
	gpio_b(26) <= virtual_state_cir;
	gpio_b(27) <= virtual_state_uir;

	-- Unused GPIO-B
	gpio_b(35 downto 28) <= (others => '0');

	-- Virtual instruction register (from JTAG)
	gpio_a <= vir_in36;

	-- Output the Virtual instruction on the LEDs
	--
	-- Green LEDs (9-bits)
	led_g <= vir_in36(8 downto 0);

	-- Red LEDs (18-bits)
	led_r <= vir_in36(17 downto 0);

	-- Drive the VIR response using some of the switches (18-bits)
	g14: if (SLD_IR_WIDTH <= 18) generate
		vir_out <= sw(SLD_IR_WIDTH-1 downto 0);
	end generate;
	g15: if (SLD_IR_WIDTH > 18) generate
		vir_out(17 downto 0) <= sw;
		vir_out(SLD_IR_WIDTH-1 downto 18) <= (others => '0');
	end generate;

    -- ------------------------------------------------------------
	-- Right 4-wide hex displays
    -- ------------------------------------------------------------
	--
	-- Connect to 16-bits of the VIR input
    u10: hex_display
        port map(
            hex     => vir_in36(3 downto 0),
            display => hex_a
        );

    u11: hex_display
        port map(
            hex     => vir_in36(7 downto 4),
            display => hex_b
        );

    u12: hex_display
        port map(
            hex     => vir_in36(11 downto 8),
            display => hex_c
        );

    u13: hex_display
        port map(
            hex     => vir_in36(15 downto 12),
            display => hex_d
        );

    -- ------------------------------------------------------------
	-- Middle 2-wide hex displays
    -- ------------------------------------------------------------
	--
	-- Connect to the VIR output (the switches)
    u14: hex_display
        port map(
            hex     => sw(3 downto 0),
            display => hex_e
        );

    u15: hex_display
        port map(
            hex     => sw(7 downto 4),
            display => hex_f
        );

    -- ------------------------------------------------------------
	-- Left 2-wide hex displays
    -- ------------------------------------------------------------
	--
	-- Controlled by the push buttons
	--
    -- The push-button inputs are high when not pressed
    hex <= not key;

    u16: hex_display
        port map(
            hex     => hex,
            display => hex_g
        );

    u17: hex_display
        port map(
            hex     => hex,
            display => hex_h
        );

    -- ------------------------------------------------------------
    -- Unused outputs and bidirectional signals
    -- ------------------------------------------------------------

    -- SDRAM
    sdram_clk  <= '0';
    sdram_cke  <= '0';
    sdram_csN  <= '1';
    sdram_rasN <= '1';
    sdram_casN <= '1';
    sdram_weN  <= '1';
    sdram_ba   <= (others => '0');
    sdram_addr <= (others => '0');
    sdram_dqm  <= (others => '0');
    sdram_dq   <= (others => 'Z');

    -- LCD
    lcd_on   <= '0'; -- Power supply off
    lcd_blon <= '0'; -- Backlight off
    lcd_rs   <= '0';
    lcd_en   <= '0';
    lcd_rw   <= '0';
    lcd_d    <= (others => '0');

    -- USB OTG Controller
    otg_resetN <= '0'; -- Reset
    otg_csN    <= '1';
    otg_rdN    <= '1';
    otg_wrN    <= '1';
    otg_fspeed <= 'Z';
    otg_lspeed <= 'Z';
    otg_dackN  <= (others => '1');
    otg_addr   <= (others => '0');
    otg_dq     <= (others => 'Z');

    -- Audio interface
    aud_adclrck <= '0';
    aud_daclrck <= '0';
    aud_dacdat  <= '0';
    aud_bclk    <= '0';
    aud_xck     <= '0';

    -- I2C bus (audio interface and TV decoder control)
    i2c_sclk <= 'Z'; -- I2C signals are open-drain
    i2c_sdat <= 'Z';

    -- TV Decoder
    td_resetN <= '0'; -- Reset

    -- VGA
    vga_blankN <= '1';
    vga_syncN  <= '1';
    vga_hs     <= '0';
    vga_vs     <= '0';
    vga_clock  <= '0';
    vga_r      <= (others => '0');
    vga_g      <= (others => '0');
    vga_b      <= (others => '0');

    -- USB Blaster interface
    link_out <= '0';

    -- Ethernet controller
    enet_clk    <= '0';
    enet_resetN <= '0';
    enet_csN    <= '1';
    enet_cmd    <= '0';
    enet_iowN   <= '1';
    enet_iorN   <= '1';
    enet_dq     <= (others => 'Z');

    -- RS232
    uart_txd <= '0';

    -- PS/2
    ps2_clk <= '0';
    ps2_dat <= 'Z';

    -- GPIO (expansion headers)
--	gpio_a <= (others => 'Z');
--	gpio_b <= (others => 'Z');

    -- SD Card interface
    sd_cmd  <= '0';
    sd_clk  <= '0';
    sd_dat3 <= '0';
    sd_dat  <= 'Z';

    -- IrDA interface
    irda_txd <= '0';

    -- Flash
    flash_resetN <= '0';
    flash_ceN    <= '1';
    flash_weN    <= '1';
    flash_oeN    <= '1';
    flash_addr   <= (others => '0');
    flash_dq     <= (others => 'Z');

    -- SRAM
    sram_ceN  <= '1';
    sram_weN  <= '1';
    sram_oeN  <= '1';
    sram_beN  <= (others => '1');
    sram_addr <= (others => '0');
    sram_dq   <= (others => 'Z');

end architecture;
