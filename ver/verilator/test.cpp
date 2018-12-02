#include <cstdio>
#include <iostream>
#include <fstream>
#include <string>
#include <string>
#include <list>
#include "Vjt89.h"
#include "verilated_vcd_c.h"
// #include "feature.hpp"

  // #include "verilated.h"

using namespace std;

class SimTime {
    vluint64_t main_time, time_limit, fast_forward;
    vluint64_t main_next;
    int verbose_ticks;
    bool toggle;
    int PERIOD, SEMIPERIOD, CLKSTEP;
    Vjt89* top;
    int clk;
public:
    void set_period( int _period ) {
        PERIOD =_period;
        PERIOD += PERIOD%2; // make it even
        SEMIPERIOD = PERIOD>>1;
        // CLKSTEP = SEMIPERIOD>>1;
        CLKSTEP = SEMIPERIOD;
    }
    int period() { return PERIOD; }
    SimTime() { 
        top = new Vjt89;  
        clk=0;      
        main_time=0; fast_forward=0; time_limit=0; toggle=false;
        verbose_ticks = 48000*24/2;
        set_period(132*6);
    }
    ~SimTime() {
        delete top;
        top=0;
    }
    Vjt89 *Top() { return top; }

    void set_time_limit(vluint64_t t) { time_limit=t; }
    bool limited() { return time_limit!=0; }
    vluint64_t get_time_limit() { return time_limit; }
    vluint64_t get_time() { return main_time; }
    int get_time_s() { return main_time/1000000000; }
    int get_time_ms() { return main_time/1000000; }
    bool next_quarter() {
        if( toggle ) top->clk = 1-clk;
        top->eval();
        if( !toggle ) {
            main_next = main_time + SEMIPERIOD;
            main_time += CLKSTEP;
            toggle = true;
            return false; // toggle clock
        }
        else {
            main_time = main_next;
            if( --verbose_ticks == 0 ) {
                cerr << '.';
                verbose_ticks = 48000*24/2;
            }
            toggle=false;
            return true; // do not toggle clock
        }
    }
    bool finish() { return main_time > time_limit && limited(); }
};

vluint64_t main_time = 0;      // Current simulation time
// This is a 64-bit integer to reduce wrap over issues and
// allow modulus.  You can also use a double, if you wish.

double sc_time_stamp () {      // Called by $time in Verilog
   return main_time;           // converts to double, to match
                               // what SystemC does
}

class CmdWritter {
    int val;
    Vjt89 *top;
    bool done;
    int last_clk;
    int state;
public:
    CmdWritter( Vjt89* _top );
    void Write( int _val );
    void Eval();
    bool Done() { return done; }
};

class RipParser {
    ifstream f;
public:
    int val;
    vluint64_t wait;
    enum t_action { cmd_write, cmd_wait, cmd_finish, cmd_error };
    RipParser( char *filename );
    int parse();
};

RipParser::RipParser( char *filename ) {
    f.open( filename );
    wait = 0L;
}

int RipParser::parse() {
    char line[512];
    while( !f.eof() ) {
        f.getline( line, 512 );
        char *noblanks=line;
        while( *noblanks==' ' || *noblanks=='\t' ) noblanks++;
        char *cmd = noblanks;
        char *args=cmd;
        while( *args!=' ' || *args!='\t' || *args!=0 ) args++;
        if( *args==0 ) continue;
        args++;
        while( *args==' ' || *args=='\t' ) args++;

        int a,b, cnt;
        cnt=sscanf(args,"%d,%x", a,b);
        if( strcmp(cmd,"vol")==0 )

    }
    return cmd_finish;
}


int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    bool trace = true, slow=false;
    RipParser *gym;
    bool forever=true;
    char *gym_filename;
    SimTime sim_time;
    CmdWritter writter( sim_time.Top() );
    Vjt89 *top = sim_time.Top();

    for( int k=1; k<argc; k++ ) {
        if( string(argv[k])=="-slow" )  {  slow=true;  continue; }
        if( string(argv[k])=="-trace" ) { trace=true;  continue; }
        if( string(argv[k])=="-gym" ) { 
            gym_filename = argv[++k];
            gym = new RipParser( gym_filename );
            if( gym==NULL ) return 1;
            continue;
        }
        if( string(argv[k])=="-time" ) { 
            int aux;
            sscanf(argv[++k],"%d",&aux);
            vluint64_t time_limit = aux;
            time_limit *= 1000000;
            forever=false;
            cout << "Simulate until " << time_limit/1000000 << "ms\n";
            sim_time.set_time_limit( time_limit );
            continue; 
        }
        cout << "ERROR: Unknown argument " << argv[k] << "\n";
        return 1;
    }

    VerilatedVcdC* tfp = new VerilatedVcdC;
    if( trace ) {
        Verilated::traceEverOn(true);
        top->trace(tfp,99);
        tfp->open("test.vcd"); 
    }

    // Reset
    top->rst = 1;
    top->clk = 0;
    top->clk_en = 1;
    top->din = 0;
    top->wr_n = 1;
    // cout << "Reset\n";
    while( sim_time.get_time() < 8*sim_time.period() ) {
        sim_time.next_quarter();
    }
    top->rst = 0;
    enum { WRITE_VAL, WAIT_FINISH } state;
    state = WRITE_VAL;
    
    vluint64_t timeout=0;
    bool wait_nonzero=true;
    const int check_step = 200;
    int next_check=check_step;
    int reg, val;
    bool fail=true;
    // cout << "Main loop\n";
    vluint64_t wait=0;
    int last_sample=0;

    vluint64_t adjust_sum=0;
    int next_verbosity = 200;
    vluint64_t next_sample=0;
    while( forever || !sim_time.finish() ) {
        if( sim_time.next_quarter() ) {
            writter.Eval();

            if( sim_time.get_time() < wait || !writter.Done() ) continue;

            switch( gym->parse() ) {
                default: 
                    if( !sim_time.finish() ) {
                        cout << "go on\n";
                        continue;
                    }
                    goto finish;
                case RipParser::cmd_write: 
                    writter.Write( gym->val );
                    timeout = sim_time.get_time() + sim_time.period()*6*100;
                    break; // parse register
                case RipParser::cmd_wait: 
                    wait=gym->wait;
                    wait+=sim_time.get_time();
                    timeout=0;
                    break;// wait 16.7ms    
                case RipParser::cmd_finish: // reached end of file
                    goto finish;
                case RipParser::cmd_error: // unsupported command
                    goto finish;                
            }       
        }
        if(trace) tfp->dump(sim_time.get_time());
    }
finish:
    if( main_time>1000000000 ) { // sim lasted for seconds
        cout << "$finish at " << dec << sim_time.get_time_s() << "s = " << sim_time.get_time_ms() << " ms\n";
    } else {
        cout << "$finish at " << dec << sim_time.get_time_ms() << "ms = " << sim_time.get_time() << " ns\n";
    }
    if(trace) tfp->close(); 
    delete gym;
 }


CmdWritter::CmdWritter( Vjt89* _top ) {
    top  = _top;
    last_clk = 0;
    done = true;
}

void CmdWritter::Write( int _val ) {
    val  = _val;
    done = false;
    state = 0;
}

void CmdWritter::Eval() {   
    int clk = top->clk; 
    if( (clk==0) && (last_clk != clk) ) {
        switch( state ) {
            case 0: 
                top->din = val;
                top->wr_n = 0;
                state=1;
                break;
            case 1:
                top->wr_n = 1;
                state = 2;
                break;
            case 4:             
                done = true;
                state=5;
                break;
            default: break;
        }
    }
    last_clk = clk;
}
