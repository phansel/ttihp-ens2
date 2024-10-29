#!/usr/bin/python

tex = open("transforms.tex", 'r')
ver = open("../transforms.v", 'w')
print("trying to open transforms.tex")
linestoread=44
line = 0

startmemline = """module memory_chars(
input wire [9:0] mem_addr,
output reg [15:0] dout,
input wire rst,
input wire clk
);

always @(posedge clk) begin
    if (rst)
        dout <= 16'b0010000000100000;
    case(mem_addr)
"""

stopmemline = """        default: dout <= 16'b0010000000100000;
    endcase;
end

endmodule
"""
ver.write(startmemline)
lhscnt = 0
rhscnt = 0
addr = 0
where = {}
while linestoread>0:
    try:
        lhs, rhs = tex.readline().split(",")
        lhs = lhs[7:]
        rhs = rhs[0:-4]
        lhs = lhs.strip()
        rhs = rhs.strip()
        print(lhs)
        print(rhs)
        strtowrite = ""
        lhsl = len(lhs)
        rhsl = len(rhs)
        print(lhsl, rhsl) 
        ind = max(lhsl, rhsl)
        rhs = rhs.ljust(ind)
        lhs = lhs.ljust(ind)
        print(lhs + ".", rhs + ".")
        print("ind: " + str(ind))
        # very wasteful but maybe it can actually work
        for char in range(ind):
            strtowrite += "        10'b" + '{0:010b}'.format(addr + char) + ": dout <= 16'b" + '{0:08b}'.format(ord(lhs[char])) + "{0:08b}".format(ord(rhs[char])) + ";\n"
        # add padding 
        strtowrite += "        10'b" + '{0:010b}'.format(addr + ind + 1) + ": dout <= 16'b" + '{0:08b}'.format(ord(" ")) + "{0:08b}".format(ord(" ")) + ";\n"
        where[line] = [addr, ind]
        
        addr += ind + 2
        print(strtowrite)
        ver.write(strtowrite)
        #ver.write(strtowrite + "\n")
        linestoread -= 1
        line += 1
        print("addr in mem: " +str(addr))
    except:
        print('out of lines')
        tex.close()
        break

ver.write(stopmemline)
ver.write("\n")
ver.write("\n")
ver.write("\n")


startline2 = """module line_mapper(
input wire clk,
input wire rst,
input wire [7:0] line, 
output reg [19:0] pointer_addr);

always @(posedge clk) begin
    if (rst)
        pointer_addr <= 20'b000000011000000000;
    case(line)
"""

ver.write(startline2)

linestowrite = len(where)
print("writing " + str(linestowrite) + " lines")
line = 0
print("where dict, line: [start_in_mem, chars]")
print(where)
# packing: 12'b[length][start_address]
while linestowrite >0:
    str_to_write = ""
    number_of_this_line = "{0:010b}".format(where[line][1]) + "{0:010b}".format(where[line][0])
    str_to_write += "    8'b" + "{0:08b}".format(line) + ": pointer_addr <= 20'b" + number_of_this_line + ";\n"
    print(str_to_write)
    linestowrite -= 1
    line += 1
    ver.write(str_to_write)

endline_line_mapper = """    default: pointer_addr <= 20'b00000000110000000000;
    endcase;
end

endmodule"""

ver.write(endline_line_mapper)

ver.write("\n\n\n\n")


ver.close()





