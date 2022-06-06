# add_waves.tcl 
#set sig_list [list sig_name_a, register_name\[32:0\], ... ] # note the escaping of the [,] brackets

set sig_list [list clk\[0:0\], en\[0:0\], iter_cnt\[0:0\], mode\[0:0\], o_d_a00\[15:0\], reset\[0:0\], A_mat\[143:0\], B_mat\[143:0\], C_mat\[143:0\], PE00_accu\[15:0\], PE01_accu\[15:0\], PE02_accu\[15:0\], PE10_accu\[15:0\], PE11_accu\[15:0\], PE12_accu\[15:0\], PE20_accu\[15:0\], PE21_accu\[15:0\], PE22_accu\[15:0\]]
gtkwave::addSignalsFromList $sig_list
