onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/dut/clock
add wave -noupdate /tb/dut/reset
add wave -noupdate -divider {fluxo IN e OUT}
add wave -noupdate /tb/dut/din
add wave -noupdate /tb/dut/dout
add wave -noupdate -divider {Match notification}
add wave -noupdate /tb/dut/alarme
add wave -noupdate -radix unsigned /tb/dut/pattern
add wave -noupdate -divider progracao
add wave -noupdate -radix hexadecimal /tb/dut/prog
add wave -noupdate -radix unsigned /tb/dut/mode
add wave -noupdate -color Red /tb/dut/valid_p1
add wave -noupdate -color Red -radix hexadecimal /tb/dut/reg_p1
add wave -noupdate /tb/dut/valid_p2
add wave -noupdate -radix hexadecimal /tb/dut/reg_p2
add wave -noupdate -color red /tb/dut/valid_p3
add wave -noupdate -color red -radix hexadecimal /tb/dut/reg_p3
add wave -noupdate /tb/dut/match_en
add wave -noupdate -divider {sinais internos}
add wave -noupdate /tb/dut/EA
add wave -noupdate -radix hexadecimal /tb/dut/reg_din
add wave -noupdate -radix hexadecimal /tb/dut/reg_prog
add wave -noupdate -radix unsigned /tb/dut/cont
add wave -noupdate /tb/dut/match
add wave -noupdate /tb/dut/match_verif
add wave -noupdate /tb/dut/comp_p1
add wave -noupdate /tb/dut/comp_p2
add wave -noupdate /tb/dut/comp_p3
add wave -noupdate /tb/dut/match_p1
add wave -noupdate /tb/dut/match_p2
add wave -noupdate /tb/dut/match_p3
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2051 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 110
configure wave -valuecolwidth 50
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 2000
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 ns} {4200 ns}
