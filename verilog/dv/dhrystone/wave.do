onerror {resume}
quietly virtual function -install /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/core -env /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/core { ( ~(ctrl_killd ) )} dbgTemp1_ex_reg_valid_56
quietly virtual function -install /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/core/ibuf/exp -env /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/core/ibuf/exp { (_io_out_T_2[4:0]  == 5'b11111)} dbgTemp143_1026
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group CPU -radix decimal /testbench/cycle
add wave -noupdate -expand -group CPU -expand -group coreMonitor /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/core/coreMonitorBundle_pc
add wave -noupdate -expand -group CPU -expand -group coreMonitor /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/core/coreMonitorBundle_inst
add wave -noupdate -expand -group CPU -expand -group coreMonitor /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/core/coreMonitorBundle_valid
add wave -noupdate -expand -group CPU -expand -group io_dmem_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/core/io_dmem_req_valid
add wave -noupdate -expand -group CPU -expand -group io_dmem_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/core/io_dmem_req_ready
add wave -noupdate -expand -group CPU -expand -group io_dmem_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/core/io_dmem_req_bits_cmd
add wave -noupdate -expand -group CPU -expand -group io_dmem_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/core/io_dmem_req_bits_addr
add wave -noupdate -expand -group CPU -expand -group io_dmem_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/core/io_dmem_req_bits_size
add wave -noupdate -expand -group CPU -expand -group io_dmem_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/core/io_dmem_resp_valid
add wave -noupdate -expand -group CPU -expand -group io_dmem_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/core/io_dmem_resp_bits_data
add wave -noupdate -expand -group CPU -expand -group io_dmem_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/core/io_dmem_resp_bits_data_word_bypass
add wave -noupdate -expand -group CPU -expand -group io_dmem_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/core/io_dmem_resp_bits_has_data
add wave -noupdate -expand -group CPU -expand -group io_dmem_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/core/io_dmem_resp_bits_tag
add wave -noupdate -expand -group CPU -expand -group io_dmem_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/core/io_dmem_s1_data_data
add wave -noupdate -expand -group CPU -expand -group io_dmem_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/core/io_dmem_s1_kill
add wave -noupdate -expand -group CPU -group auto_slave_in_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/auto_slave_in_a_valid
add wave -noupdate -expand -group CPU -group auto_slave_in_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/auto_slave_in_a_ready
add wave -noupdate -expand -group CPU -group auto_slave_in_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/auto_slave_in_a_bits_opcode
add wave -noupdate -expand -group CPU -group auto_slave_in_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/auto_slave_in_a_bits_size
add wave -noupdate -expand -group CPU -group auto_slave_in_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/auto_slave_in_a_bits_param
add wave -noupdate -expand -group CPU -group auto_slave_in_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/auto_slave_in_a_bits_address
add wave -noupdate -expand -group CPU -group auto_slave_in_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/auto_slave_in_a_bits_corrupt
add wave -noupdate -expand -group CPU -group auto_slave_in_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/auto_slave_in_a_bits_mask
add wave -noupdate -expand -group CPU -group auto_slave_in_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/auto_slave_in_a_bits_data
add wave -noupdate -expand -group CPU -group auto_slave_in_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/auto_slave_in_a_bits_source
add wave -noupdate -expand -group CPU -group auto_slave_in_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/auto_slave_in_d_valid
add wave -noupdate -expand -group CPU -group auto_slave_in_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/auto_slave_in_d_ready
add wave -noupdate -expand -group CPU -group auto_slave_in_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/auto_slave_in_d_bits_opcode
add wave -noupdate -expand -group CPU -group auto_slave_in_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/auto_slave_in_d_bits_size
add wave -noupdate -expand -group CPU -group auto_slave_in_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/auto_slave_in_d_bits_source
add wave -noupdate -expand -group CPU -group auto_slave_in_ /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/auto_slave_in_d_bits_data
add wave -noupdate -expand -group SPI-PSRAM -expand -group qspi_ram /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/qspiClockDomainWrapper_1/qspi_ram_0/auto_mem_xing_in_a_valid
add wave -noupdate -expand -group SPI-PSRAM -expand -group qspi_ram /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/qspiClockDomainWrapper_1/qspi_ram_0/auto_mem_xing_in_a_ready
add wave -noupdate -expand -group SPI-PSRAM -expand -group qspi_ram /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/qspiClockDomainWrapper_1/qspi_ram_0/auto_mem_xing_in_a_bits_opcode
add wave -noupdate -expand -group SPI-PSRAM -expand -group qspi_ram /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/qspiClockDomainWrapper_1/qspi_ram_0/auto_mem_xing_in_a_bits_param
add wave -noupdate -expand -group SPI-PSRAM -expand -group qspi_ram /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/qspiClockDomainWrapper_1/qspi_ram_0/auto_mem_xing_in_a_bits_address
add wave -noupdate -expand -group SPI-PSRAM -expand -group qspi_ram /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/qspiClockDomainWrapper_1/qspi_ram_0/auto_mem_xing_in_a_bits_corrupt
add wave -noupdate -expand -group SPI-PSRAM -expand -group qspi_ram /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/qspiClockDomainWrapper_1/qspi_ram_0/auto_mem_xing_in_a_bits_data
add wave -noupdate -expand -group SPI-PSRAM -expand -group qspi_ram /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/qspiClockDomainWrapper_1/qspi_ram_0/auto_mem_xing_in_a_bits_mask
add wave -noupdate -expand -group SPI-PSRAM -expand -group qspi_ram /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/qspiClockDomainWrapper_1/qspi_ram_0/auto_mem_xing_in_a_bits_size
add wave -noupdate -expand -group SPI-PSRAM -expand -group qspi_ram /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/qspiClockDomainWrapper_1/qspi_ram_0/auto_mem_xing_in_a_bits_source
add wave -noupdate -expand -group SPI-PSRAM -expand -group qspi_ram /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/qspiClockDomainWrapper_1/qspi_ram_0/auto_mem_xing_in_d_valid
add wave -noupdate -expand -group SPI-PSRAM -expand -group qspi_ram /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/qspiClockDomainWrapper_1/qspi_ram_0/auto_mem_xing_in_d_ready
add wave -noupdate -expand -group SPI-PSRAM -expand -group qspi_ram /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/qspiClockDomainWrapper_1/qspi_ram_0/auto_mem_xing_in_d_bits_opcode
add wave -noupdate -expand -group SPI-PSRAM -expand -group qspi_ram /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/qspiClockDomainWrapper_1/qspi_ram_0/auto_mem_xing_in_d_bits_data
add wave -noupdate -expand -group SPI-PSRAM -expand -group qspi_ram /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/qspiClockDomainWrapper_1/qspi_ram_0/auto_mem_xing_in_d_bits_size
add wave -noupdate -expand -group SPI-PSRAM -expand -group qspi_ram /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/qspiClockDomainWrapper_1/qspi_ram_0/auto_mem_xing_in_d_bits_source
add wave -noupdate -expand -group SPI-PSRAM /testbench/spi_ram/SCK_i
add wave -noupdate -expand -group SPI-PSRAM /testbench/spi_ram/nCE_i
add wave -noupdate -expand -group SPI-PSRAM /testbench/spi_ram/NC_io
add wave -noupdate -expand -group SPI-PSRAM /testbench/spi_ram/nWP_io
add wave -noupdate -expand -group SPI-PSRAM /testbench/spi_ram/SI_io
add wave -noupdate -expand -group SPI-PSRAM /testbench/spi_ram/SO_io
add wave -noupdate /testbench/uut/mprj/Marmot/io_oeb
add wave -noupdate -expand -group SPI-Flash /testbench/spi_flash/SCLK
add wave -noupdate -expand -group SPI-Flash /testbench/spi_flash/CS
add wave -noupdate -expand -group SPI-Flash /testbench/spi_flash/SI
add wave -noupdate -expand -group SPI-Flash /testbench/spi_flash/SO
add wave -noupdate -expand -group SPI-Flash /testbench/spi_flash/WP
add wave -noupdate -expand -group SPI-Flash /testbench/spi_flash/SIO3
add wave -noupdate /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/core/ctrl_killd
add wave -noupdate /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/core/id_raddr1
add wave -noupdate /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/core/ex_waddr
add wave -noupdate /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/core/ibuf/exp/io_out_rs1
add wave -noupdate /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/core/ibuf/exp_io_in
add wave -noupdate /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/core/ibuf/icData
add wave -noupdate /testbench/uut/mprj/Marmot/MarmotCaravelChip/dut/sys/tile_prci_domain/tile_reset_domain/tile/core/ibuf/icData_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1714380000 ps} 0} {{Cursor 2} {21100900000 ps} 0} {Trace {21511428110 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 312
configure wave -valuecolwidth 142
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {21099208519 ps} {21102591481 ps}
