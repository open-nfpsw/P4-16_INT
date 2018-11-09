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


#define ETHERTYPE_IPV4            0x0800
#define IP_PROTOCOLS_IPHL_UDP     0x511
/* TODO: confirm this */
#define VXLAN_GPE_NEXT_PROTO_IOAM 0x6
#define UDP_PROTOCOL              0x11

const bit<16> UDP_PORT_VXLAN_GPE = 4790;

/*************************************************************************
 ***********************  P A R S E R  ***********************************
 *************************************************************************/
parser MyParser(
    packet_in packet,
    out   headers_t hd,
    inout metadata_t meta,
    inout standard_metadata_t standard_metadata) {
    state start {
        packet.extract(hd.ethernet);
        transition select(hd.ethernet.etherType) {
            ETHERTYPE_IPV4: parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        packet.extract(hd.ipv4);
//        transition select(hd.ipv4.fragOffset, hd.ipv4.ihl, hd.ipv4.protocol) {
//            IP_PROTOCOLS_IPHL_UDP : parse_udp;
//            default: accept;
//        }
        transition select(hd.ipv4.protocol) {            
            UDP_PROTOCOL : parse_udp;
            default: accept;
        }
    }

    state parse_udp {
        packet.extract(hd.udp);
        transition select(hd.udp.dst_port) {
            UDP_PORT_VXLAN_GPE : parse_vxlan_gpe;
            default: accept;
        }
    }

    state parse_vxlan_gpe {
        packet.extract(hd.vxlan_gpe);
        transition select(hd.vxlan_gpe.next_proto) {
            VXLAN_GPE_NEXT_PROTO_IOAM : parse_gpe_ioam;
            default : accept;
        }
    }

    state parse_gpe_ioam {
        packet.extract(hd.gpe_ioam);
        meta.meta.ioam_cnt = hd.gpe_ioam.len - 1;
        transition select(hd.gpe_ioam.len) {
            0 : accept; //parse_error pe_invalid_ioam; // error
            1 : accept; //parse_inner;
            default : parse_ioam_payload;
        }
    }

    state parse_ioam_payload {
        packet.extract(hd.ioam_payload.next);
        meta.meta.ioam_cnt = (meta.meta.ioam_cnt - 1) >> 2;
        transition select (meta.meta.ioam_cnt) {
            0: accept;
            default: parse_ioam_payload;
        }
    }
}
