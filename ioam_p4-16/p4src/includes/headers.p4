/*
Copyright (C) 2018 Netronome Systems, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors
   may be used to endorse or promote products derived from this software 
   without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/


#define MAX_PAYLOAD_ENTRIES 9

header meta_t {
    bit<8> ioam_cnt;
    bit<1> decapped; /* set when decapsulation is done */
    bit<1> is_transit; /* is the packet treated as just transit */
    bit<32> device_id; /* retrieved from a p4 register */
}

header intrinsic_metadata_t {
    bit<64> ingress_global_tstamp; /* sec[63:32], nsec[31:0] */
    bit<64> current_global_tstamp; /* sec[63:32], nsec[31:0] */
}

header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType;
}

header ipv4_t {
    bit<4> version;
    bit<4> ihl;
    bit<8> diffserv;
    bit<16> totalLen;
    bit<16> identification;
    bit<3> flags;
    bit<13> fragOffset;
    bit<8> ttl;
    bit<8> protocol;
    bit<16> hdrChecksum;
    bit<32> srcAddr;
    bit<32> dstAddr;
}

header udp_t {
    bit<16> src_port;
    bit<16> dst_port;
    bit<16> len;
    bit<16> cksum;
}

header vxlan_gpe_t {
    bit<8> flags;
    bit<16> reserved_1;
    bit<8> next_proto;
    bit<24> vni;
    bit<8> reserved_2;
}

header gpe_ioam_t {
    bit<8> proto;
    bit<8> len;
    bit<8> reserved_0;
    bit<8> next_proto;
    bit<16> trace_type;
    bit<8> max_len;
    bit<8> flags;
}

header ioam_payload_t {
    bit<32> device_id;
    bit<48> rx_sec;
    bit<32> rx_nsec;
    bit<32> tx_nsec;
    bit<16> reserved_0;
    bit<16> ingress_port;
    bit<16> egress_port;
    bit<16> queue_id;
    bit<16> congestion;
    bit<32> reserved_1;
}


struct headers_t {
    ethernet_t ethernet;
    ipv4_t ipv4;
    udp_t udp;
    vxlan_gpe_t vxlan_gpe;
    gpe_ioam_t gpe_ioam;
    ioam_payload_t[MAX_PAYLOAD_ENTRIES] ioam_payload;
    ethernet_t collector_ethernet;
    ipv4_t collector_ipv4;
    udp_t collector_udp;
    ethernet_t inner_ethernet;
    ipv4_t inner_ipv4;
    udp_t inner_udp;
}

struct metadata_t {
    meta_t meta;
    intrinsic_metadata_t intrinsic_metadata;
}
