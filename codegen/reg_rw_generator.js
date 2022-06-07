var N = 3

//0: begin
//    input_registers[0 +: W] = data_in;
//end

var output = ''

//Load
for(var i = 0; i < 2 * N * N; i++) {
    output += i + ': begin\n'
    output += '    input_registers[' + i + ' * W +: W] = data_in;\n'
    output += 'end\n'
}

output = ''
//Store
for(var i = 0; i < 2 * N * N; i++) {
    output += i + ': begin\n'
    output += '    data_out = C_mat[' + i + ' * W +: W];\n'
    output += 'end\n'
}

document.querySelector('pre').textContent = output
