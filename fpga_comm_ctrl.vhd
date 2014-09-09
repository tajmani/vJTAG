-- Greg Stitt
-- University of Florida

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.config_pkg.all;

entity fpga_comm_ctrl is
  port (
    clk : in std_logic;
    rst : in std_logic;
    idle : out std_logic;

    -- RS232 signals
    rs232_tx  : out std_logic;
    rs232_cts : out std_logic;
    rs232_rx  : in  std_logic;
    rs232_rts : in  std_logic;

    -- on-chip comm. signals
    wr_addr   : out std_logic_vector(C_FPGA_COMM_CTRL_ADDR_WIDTH-1 downto 0);
    wr_enable : out std_logic;
    wr_data   : out std_logic_vector(C_FPGA_COMM_CTRL_DATA_WIDTH-1 downto 0);
    rd_addr   : out std_logic_vector(C_FPGA_COMM_CTRL_ADDR_WIDTH-1 downto 0);
    rd_enable : out std_logic;
    rd_data   : in  std_logic_vector(C_FPGA_COMM_CTRL_DATA_WIDTH-1 downto 0));
end fpga_comm_ctrl;

architecture default of fpga_comm_ctrl is

  constant ADDR_ITERATIONS : positive := C_FPGA_COMM_CTRL_ADDR_WIDTH/8;
  constant SIZE_ITERATIONS : positive := C_FPGA_COMM_CTRL_SIZE_WIDTH/8;
  constant DATA_ITERATIONS : positive := C_FPGA_COMM_CTRL_DATA_WIDTH/8;

  function max_count return positive is
  begin
    if (ADDR_ITERATIONS > SIZE_ITERATIONS) then
      if (ADDR_ITERATIONS > DATA_ITERATIONS) then
        return ADDR_ITERATIONS;
      else
        return DATA_ITERATIONS;
      end if;
    else
      if (SIZE_ITERATIONS > DATA_ITERATIONS) then
        return SIZE_ITERATIONS;
      else
        return DATA_ITERATIONS;
      end if;
    end if;
  end max_count;

  type state_type is (S_INIT, S_GET_ADDR, S_GET_SIZE, S_GET_WR_DATA,
                      S_SEND_WR_DATA, S_SEND_RD_REQUEST, S_GET_RD_DATA,
                      S_SEND_RD_DATA, S_WAIT_SEND_DONE);
  signal state, next_state         : state_type;
  signal rd_wr, next_rd_wr         : std_logic;
  signal addr, next_addr           : unsigned(C_FPGA_COMM_CTRL_ADDR_WIDTH-1 downto 0);
  signal size, next_size           : unsigned(C_FPGA_COMM_CTRL_SIZE_WIDTH-1 downto 0);
  signal wr_data_s, next_wr_data_s : std_logic_vector(C_FPGA_COMM_CTRL_DATA_WIDTH-1 downto 0);
  signal rd_data_s, next_rd_data_s : std_logic_vector(C_FPGA_COMM_CTRL_DATA_WIDTH-1 downto 0);
  signal count, next_count         : natural range 0 to max_count;

  signal rx_data  : std_logic_vector(7 downto 0);
  signal rx_valid : std_logic;
  signal tx_data  : std_logic_vector(7 downto 0);
  signal tx_start : std_logic;
  signal tx_busy  : std_logic;
  
begin

  rs232_cts <= '0';
  
  -- RS232 transmitter (FPGA to uP)
  U_RS232_TX : entity work.rs232_tx
    generic map (
      clk_freq => 50000000)
    port map (
      clk   => clk,
      rst   => rst,
      data  => tx_data,
      start => tx_start,
      tx    => rs232_tx,
      busy  => tx_busy
      );

  -- RS232 receiver (uP to FPGA)
  U_RS232_RX : entity work.rs232_rx
    generic map (
      clk_freq => 50000000)
    port map (
      clk   => clk,
      rst   => rst,
      rx    => rs232_rx,
      data  => rx_data,
      ready => rx_valid
      );

  -- FSM for controller
  process(clk, rst)
  begin
    if (rst = '1') then
      state     <= S_INIT;
      rd_wr     <= '0';
      addr      <= (others => '0');
      size      <= (others => '0');
      wr_data_s <= (others => '0');
      rd_data_s <= (others => '0');
      count     <= 0;
    elsif (rising_edge(clk)) then
      state     <= next_state;
      rd_wr     <= next_rd_wr;
      addr      <= next_addr;
      size      <= next_size;
      wr_data_s <= next_wr_data_s;
      rd_data_s <= next_rd_data_s;
      count     <= next_count;
    end if;
  end process;

  process(state, rd_wr, addr, size, wr_data_s, rd_data_s, rx_valid, rx_data, rd_data, tx_busy, count)

    variable temp_count : natural range 0 to max_count;
    variable temp_size  : unsigned(size'length-1 downto 0);
  begin

    next_state     <= state;
    next_rd_wr     <= rd_wr;
    next_addr      <= addr;
    next_size      <= size;
    next_wr_data_s <= wr_data_s;
    next_rd_data_s <= rd_data_s;
    next_count     <= count;

    wr_addr   <= (others => '0');
    wr_enable <= '0';
    wr_data   <= (others => '0');
    rd_addr   <= (others => '0');
    rd_enable <= '0';
    tx_data   <= (others => '0');
    tx_start  <= '0';
    idle <= '0';

    case state is
      -- wait until first byte received, which specifies a read or write
      when S_INIT =>
        next_count <= 0;
        idle <= '1';
        
        if (rx_valid = '1') then
          next_rd_wr <= rx_data(0);
          next_state <= S_GET_ADDR;
        end if;

        -- wait until ADDR_ITERATIONS bytes received for the address
      when S_GET_ADDR =>
        if (rx_valid = '1') then
          next_addr <= shift_right(addr, rx_data'length);

          next_addr(next_addr'length-1 downto next_addr'length-rx_data'length) <= unsigned(rx_data);

          temp_count := count + 1;
          next_count <= temp_count;

          if (temp_count = ADDR_ITERATIONS) then
            next_count <= 0;
            next_state <= S_GET_SIZE;
          end if;
        end if;

        -- wait until SIZE_ITERATIONS bytes received for the size
      when S_GET_SIZE =>
        if (rx_valid = '1') then
          next_size <= shift_right(size, rx_data'length);

          next_size(next_size'length-1 downto next_size'length-rx_data'length) <= unsigned(rx_data);

          temp_count := count + 1;
          next_count <= temp_count;

          if (temp_count = SIZE_ITERATIONS) then
            next_count <= 0;

            if (rd_wr = '0') then
              next_state <= S_SEND_RD_REQUEST;
            else
              next_state <= S_GET_WR_DATA;
            end if;
          end if;
        end if;

        -- wait until WR_DATA_ITERATIONS bytes received for the address
      when S_GET_WR_DATA =>
        if (rx_valid = '1') then
          next_wr_data_s                            <= std_logic_vector(shift_right((unsigned(wr_data_s)), rx_data'length));
          next_wr_data_s(next_wr_data_s'length-1 downto next_wr_data_s'length-rx_data'length) <= rx_data;

          temp_count := count + 1;
          next_count <= temp_count;

          -- if the entire wr_data has been received from rs232, then send it
          -- to the application circuit
          if (temp_count = DATA_ITERATIONS) then
            next_state <= S_SEND_WR_DATA;
          end if;
        end if;

        -- send the write data to the application circuit
      when S_SEND_WR_DATA =>
        wr_addr    <= std_logic_vector(addr);
        wr_enable  <= '1';
        wr_data    <= wr_data_s;
        next_addr  <= addr+1;
        temp_size  := size-1;
        next_size  <= temp_size;
        next_count <= 0;

        -- check if the transfer is complete
        if (unsigned(temp_size) = 0) then
          next_state <= S_INIT;
        else
          next_state <= S_GET_WR_DATA;
        end if;

        -- send a rd request to the application circuit
      when S_SEND_RD_REQUEST =>
        rd_addr    <= std_logic_vector(addr);
        rd_enable  <= '1';
        next_addr  <= addr+1;
        next_size  <= size-1;
        next_state <= S_GET_RD_DATA;

        -- store the data from the circuit
      when S_GET_RD_DATA =>
        next_rd_data_s <= rd_data;
        next_count     <= 0;
        next_state     <= S_SEND_RD_DATA;

        -- transmit the stored data, one tx_data'length chunk at a time
      when S_SEND_RD_DATA =>
        tx_data    <= rd_data_s(tx_data'length-1 downto 0);
        tx_start   <= '1';
        next_count <= count+1;
        next_state <= S_WAIT_SEND_DONE;

        -- wait until the transfer is finished
      when S_WAIT_SEND_DONE =>
        if (tx_busy = '0') then
          next_rd_data_s <= std_logic_vector(shift_right(unsigned(rd_data_s), tx_data'length));

          -- if a full read element has been transmitted
          if (count = DATA_ITERATIONS) then

            -- if the entire read has been handled, start over. Otherwise, send
            -- another read request to the application circuit.
            if (unsigned(size) = 0) then
              next_state <= S_INIT;
            else
              next_state <= S_SEND_RD_REQUEST;
            end if;
          else
            -- if in the middle of transmitting a single read element, then
            -- continue with the transmit
            next_state <= S_SEND_RD_DATA;
          end if;
        end if;
      when others => null;
    end case;
  end process;

end default;
