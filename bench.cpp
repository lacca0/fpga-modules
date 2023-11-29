#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "obj_dir/Vaddr_gen.h"
#include "obj_dir/Vaddr_gen___024root.h"

#define SOME_TIME 650
#define MORE_TIME 400

vluint64_t sim_time = 0;

int main(int argc, char** argv, char** env) {
    Vaddr_gen *inst = new Vaddr_gen;

    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    inst->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    do {
    inst->clk ^= 1;
    inst->i_gen_ena = 1;
    inst->rst_n = 1;
    inst->eval();
    m_trace->dump(sim_time);
    sim_time++;

    inst->clk ^= 1;
    inst->i_gen_ena = 0;
    inst->eval();
    m_trace->dump(sim_time);
    sim_time++;

    inst->clk ^= 1;
    inst->eval();
    m_trace->dump(sim_time);
    sim_time++;

    inst->i_gen_ena = 1;

    } while (false);

    while (sim_time < SOME_TIME) {
        inst->clk ^= 1;
        inst->eval();
        m_trace->dump(sim_time);
        sim_time++;
    }

    do {

    inst->clk ^= 1;
    inst->i_gen_ena = 0;
    inst->eval();
    m_trace->dump(sim_time);
    sim_time++;

    inst->clk ^= 1;
    inst->eval();
    m_trace->dump(sim_time);
    sim_time++;

    inst->i_gen_ena = 1;

    } while (false);


    while (sim_time < MORE_TIME) {
        inst->clk ^= 1;
        inst->eval();
        m_trace->dump(sim_time);
        sim_time++;
    }


    m_trace->close();
    delete inst;
    exit(EXIT_SUCCESS);
}