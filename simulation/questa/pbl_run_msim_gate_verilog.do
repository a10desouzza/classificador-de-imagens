transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vlog  -work work +incdir+. {pbl.vo}

vlog -sv -work work +incdir+C:/Users/arthu/OneDrive/Documentos/uefs/SD/classificador\ de\ imagens {C:/Users/arthu/OneDrive/Documentos/uefs/SD/classificador de imagens/tb_elm_accel.sv}

vsim -t 1ps -L altera_ver -L altera_lnsim_ver -L cyclonev_ver -L lpm_ver -L sgate_ver -L cyclonev_hssi_ver -L altera_mf_ver -L cyclonev_pcie_hip_ver -L gate_work -L work -voptargs="+acc"  tb_elm_accel

add wave *
view structure
view signals
run -all
