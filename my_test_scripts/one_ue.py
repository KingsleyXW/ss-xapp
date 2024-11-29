#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# SPDX-License-Identifier: GPL-3.0
#
# GNU Radio Python Flow Graph
# Title: 1UE Flowgraph
# GNU Radio version: 3.8.1.0

from gnuradio import blocks
from gnuradio import gr
from gnuradio.filter import firdes
import sys
import signal
from argparse import ArgumentParser
from gnuradio.eng_arg import eng_float, intx
from gnuradio import eng_notation
from gnuradio import zeromq

class one_ue(gr.top_block):

    def __init__(self):
        gr.top_block.__init__(self, "1UE Flowgraph")

        ##################################################
        # Variables
        ##################################################
        self.samp_rate = samp_rate = 23.04e6

        ##################################################
        # Blocks
        ##################################################
        # ZeroMQ source for UE1
        #elf.zeromq_req_source_0 = zeromq.req_source(gr.sizeof_gr_complex, 1, 'tcp://localhost:2010', 100, False, -1)
        # ZeroMQ sink for UE1
        #self.zeromq_rep_sink_0 = zeromq.rep_sink(gr.sizeof_gr_complex, 1, 'tcp://*:2009', 100, False, -1)
        
        self.zeromq_req_source_0 = zeromq.req_source(gr.sizeof_gr_complex, 1, 'tcp://localhost:5006', 100, False, -1)
        # ZeroMQ sink for UE1
        self.zeromq_rep_sink_0 = zeromq.rep_sink(gr.sizeof_gr_complex, 1, 'tcp://*:5006', 100, False, -1)
        # Throttle block for flow control
        self.blocks_throttle_0 = blocks.throttle(gr.sizeof_gr_complex * 1, samp_rate, True)
            
        # Multiply const block for signal gain
        self.blocks_multiply_const_vxx_0 = blocks.multiply_const_cc(0.05)

        ##################################################
        # Connections
        ##################################################
        # Connect UE1 source to multiplier, throttle, and sink
        self.connect((self.zeromq_req_source_0, 0), (self.blocks_multiply_const_vxx_0, 0))
        self.connect((self.blocks_multiply_const_vxx_0, 0), (self.blocks_throttle_0, 0))
        self.connect((self.blocks_throttle_0, 0), (self.zeromq_rep_sink_0, 0))

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.blocks_throttle_0.set_sample_rate(self.samp_rate)
        self.blocks_throttle_0_0.set_sample_rate(self.samp_rate)

    def get_min_gain(self):
        return self.min_gain

    def set_min_gain(self, min_gain):
        self.min_gain = min_gain

    def get_max_gain(self):
        return self.max_gain

    def set_max_gain(self, max_gain):
        self.max_gain = max_gain


def main(top_block_cls=one_ue, options=None):
    tb = top_block_cls()

    def sig_handler(sig=None, frame=None):
        tb.stop()
        tb.wait()
        sys.exit(0)

    signal.signal(signal.SIGINT, sig_handler)
    signal.signal(signal.SIGTERM, sig_handler)

    tb.start()
    try:
        input('Press Enter to quit: ')
    except EOFError:
        pass
    tb.stop()
    tb.wait()


if __name__ == '__main__':
    main()
