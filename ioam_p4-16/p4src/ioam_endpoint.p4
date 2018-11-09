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

#include "v1model.p4"
#include "includes/headers.p4"
#include "includes/parser.p4"

#define IOAM_CLONE_SPEC 0x1000

//Encap:
#define ENCAP_IP_GROWTH (20 + /* ip */ 8 + /* udp */ 8 + /* gpe */ 4 /* gpe_ioam */)

#define ENCAP_UDP_GROWTH (8 + /* udp */ 8 + /* gpe */ 4 /* gpe_ioam */)

#define GPE_NEXT_ETH 0x3
#define IOAM_TRACE_TYPE 0xf800
//


//Decap:
#define IPV4_GROWTH (20 /*ipv4*/ + 8 /*udp*/ + 32 /*1xpayload*/)
#define UDP_GROWTH (8 /*udp*/ + 32 /*1xpayload*/ )
//


/*
counter non_ioam_drop() {
    type : packets;
    instance_count : 1;
}
*/

/*************************************************************************
 ************   C H E C K S U M    V E R I F I C A T I O N   *************
 *************************************************************************/
control MyVerifyChecksum(
    inout headers_t   hdr,
    inout metadata_t  meta)
{
    apply {    }
}


/*************************************************************************
 **************  I N G R E S S   P R O C E S S I N G   *******************
 *************************************************************************/
control MyIngress(
    inout headers_t     hdr,
    inout metadata_t    meta,
    inout standard_metadata_t  standard_metadata)
{

    action do_forward(bit<16> espec, bit<1> is_transit, bit<32> device_id)
    {
        meta.meta.device_id = device_id;
        standard_metadata.egress_spec = espec;
        meta.meta.is_transit = is_transit;
    }

    table tbl_forward {
        key = {
            standard_metadata.ingress_port : exact;
        }
        actions = {
            do_forward;
        }
    }

    action do_forward_clone(bit<16> espec, bit<32> device_id)
    {
        meta.meta.device_id = device_id;
        standard_metadata.egress_spec = espec;
    }

    table tbl_forward_clone {
        key = {
            standard_metadata.ingress_port : exact;
        }
        actions = {
            do_forward_clone;
        }
    }

    action do_drop()
    {
        mark_to_drop();
    }

    table tbl_drop {
        actions = {
            do_drop;
        }
    }

    action do_hdr_prep_udp()
    {
        hdr.inner_ipv4.setValid();
        hdr.inner_udp.setValid();

        hdr.inner_ipv4 = hdr.ipv4;
        hdr.inner_udp = hdr.udp;
    }

    action do_hdr_prep_ipv4()
    {
        hdr.inner_ipv4.setValid();
        hdr.inner_ipv4 = hdr.ipv4;
    }
    action do_decap_clone() {
//    #if 1
//        clone_ingress_pkt_to_ingress(IOAM_CLONE_SPEC);
//    #endif

        /* we will populate the egress ts at the end */
        meta.meta.decapped = 1;
    }

    table tbl_decap_clone {
        actions = {
            do_decap_clone;
        }
    }

    action do_encap(bit<48> eth_dst, bit<48> eth_src, bit<32> ip_dst, bit<32> ip_src, bit<24> vni)
    {
        /* we add headers that might be present */
        hdr.ipv4.setValid();
        hdr.udp.setValid();

        hdr.inner_ethernet.setValid();
        // copy_header(inner_ethernet, ethernet); //??
        hdr.inner_ethernet = hdr.ethernet;

        hdr.ethernet.dstAddr = eth_dst;
        hdr.ethernet.srcAddr = eth_src;
        hdr.ethernet.etherType = 0x0800;

        hdr.ipv4.version = 4;
        hdr.ipv4.ihl = 5;
        hdr.ipv4.totalLen = (bit<16>)(standard_metadata.packet_length + ENCAP_IP_GROWTH);
        hdr.ipv4.ttl = 32;
        hdr.ipv4.protocol = 0x11; // UDP
        hdr.ipv4.srcAddr = ip_src;
        hdr.ipv4.dstAddr = ip_dst;

        hdr.udp.src_port = 0x8888; // TODO: should be a hash
        hdr.udp.dst_port = UDP_PORT_VXLAN_GPE;
        hdr.udp.len = (bit<16>)(standard_metadata.packet_length + ENCAP_UDP_GROWTH);
        hdr.udp.cksum = 0;

        hdr.vxlan_gpe.setValid();
        hdr.gpe_ioam.setValid();

        hdr.vxlan_gpe.next_proto = VXLAN_GPE_NEXT_PROTO_IOAM;
        hdr.vxlan_gpe.vni = vni;
        hdr.vxlan_gpe.flags = 0x0c; // Instance & next proto bits 1

        hdr.gpe_ioam.proto = VXLAN_GPE_NEXT_PROTO_IOAM;
        hdr.gpe_ioam.next_proto = GPE_NEXT_ETH;
        hdr.gpe_ioam.len = 1;

        hdr.gpe_ioam.trace_type = IOAM_TRACE_TYPE;
        hdr.gpe_ioam.max_len = 255;
        hdr.gpe_ioam.flags = 0;
    }

    table tbl_encap {
        actions = {
            do_encap;
        }
    }

    apply {
        if (standard_metadata.clone_spec == IOAM_CLONE_SPEC) {
            tbl_forward_clone.apply();
        } else {
            tbl_forward.apply();
            if (meta.meta.is_transit == 0) {
                if (hdr.gpe_ioam.isValid()) {
                    tbl_decap_clone.apply();
                } else {
                    if (hdr.udp.isValid()) {
                        do_hdr_prep_udp();
                    } else if (hdr.ipv4.isValid()) {
                        do_hdr_prep_ipv4();
                    }
                    tbl_encap.apply();
                }
            } else { // if (not valid(gpe_ioam)) {
                tbl_drop.apply();
            }
        }
    }
}


/*************************************************************************
 ****************  E G R E S S   P R O C E S S I N G   *******************
 *************************************************************************/
control MyEgress(
    inout headers_t        hdr,
    inout metadata_t       meta,
    inout standard_metadata_t standard_metadata)
{

    action do_ioam_payload_add()
    {
        hdr.ioam_payload.push_front(1);
        hdr.ioam_payload[0].device_id = meta.meta.device_id;

        /* the timestamp when mac time is used is broken up into two 32-bit words
         * time second and time nseconds
         */
        hdr.ioam_payload[0].device_id = meta.meta.device_id;
        hdr.ioam_payload[0].rx_sec =
                     (bit<48>)(meta.intrinsic_metadata.ingress_global_tstamp >> 32);
        hdr.ioam_payload[0].rx_nsec =
                     (bit<32>)meta.intrinsic_metadata.ingress_global_tstamp;
        hdr.ioam_payload[0].queue_id = 0;
        hdr.ioam_payload[0].congestion = 0;
        hdr.ioam_payload[0].ingress_port =
                     standard_metadata.ingress_port;
        hdr.ioam_payload[0].egress_port =
                     standard_metadata.egress_spec;

        /* NOTE: we could in theory use the MAC prepend to insert this timestamp */
        hdr.ioam_payload[0].tx_nsec =
                     (bit<32>)meta.intrinsic_metadata.current_global_tstamp;
        hdr.gpe_ioam.len = hdr.gpe_ioam.len + 4;

        hdr.ipv4.totalLen = hdr.ipv4.totalLen + 32;
        hdr.udp.len = hdr.udp.len + 32;

    }

    action do_ioam_meta_fwd(bit<48> meta_proc_eth_dst,
                           bit<48> meta_proc_eth_src,
                           bit<32> meta_proc_ip_dst,
                           bit<32> meta_proc_ip_src,
                           bit<16> meta_proc_udp_dport)
    {
        /* add the int headers for this hop
         * NOTE: this will only work if these are the only headers involved!
         */
        hdr.collector_ethernet.setValid();
        hdr.collector_ipv4.setValid();
        hdr.collector_udp.setValid();

        hdr.collector_ethernet.dstAddr = meta_proc_eth_dst;
        hdr.collector_ethernet.srcAddr = meta_proc_eth_src;
        hdr.collector_ethernet.etherType = ETHERTYPE_IPV4;

        hdr.collector_ipv4.version = 4;
        hdr.collector_ipv4.ihl = 5;
        hdr.collector_ipv4.diffserv = 0;
        hdr.collector_ipv4.identification = 0;
        hdr.collector_ipv4.flags = 0;
        hdr.collector_ipv4.fragOffset = 0;
        hdr.collector_ipv4.ttl = 64;
        hdr.collector_ipv4.protocol = 0x11;

        hdr.collector_ipv4.dstAddr = meta_proc_ip_dst;
        hdr.collector_ipv4.srcAddr = meta_proc_ip_src;
        hdr.collector_ipv4.totalLen = (bit<16>)(standard_metadata.packet_length + IPV4_GROWTH);

        hdr.collector_udp.dst_port = meta_proc_udp_dport;
        hdr.collector_udp.dst_port = meta_proc_udp_dport;
        hdr.collector_udp.cksum = 0;
        hdr.collector_udp.len = (bit<16>)(standard_metadata.packet_length + UDP_GROWTH);

        do_ioam_payload_add();
    }

    table tbl_ioam_meta_fwd {
        actions = {
            do_ioam_meta_fwd;
        }
    }

    table tbl_ioam_payload_add {
        actions = {
            do_ioam_payload_add;
        }
    }


    action do_decap_orig() {
    #if 1
        /* remove all the outer headers */
        hdr.ethernet.setInvalid();
        hdr.ipv4.setInvalid();
        hdr.udp.setInvalid();
        hdr.vxlan_gpe.setInvalid();
        hdr.gpe_ioam.setInvalid();
        /* we remove all the headers in one shot */
        hdr.ioam_payload.pop_front(MAX_PAYLOAD_ENTRIES);
    #endif
    }

    table tbl_decap_orig {
        actions = {
            do_decap_orig;
        }
    }



    apply {
        if (standard_metadata.clone_spec == IOAM_CLONE_SPEC) {
            /* this path will never have its lookups cached
             * so we make it as lean as possible
             */
            tbl_ioam_meta_fwd.apply();
        } else {
            if (meta.meta.decapped == 1) {
                tbl_decap_orig.apply();
            } else if (hdr.gpe_ioam.isValid()) {
                tbl_ioam_payload_add.apply();
            }
        }
    }
}


/*************************************************************************
 *************   C H E C K S U M    C O M P U T A T I O N   **************
 *************************************************************************/
control MyComputeChecksum(
    inout headers_t  hdr,
    inout metadata_t meta)
{
    apply {   }
}


/*************************************************************************
 ***********************  D E P A R S E R  *******************************
 *************************************************************************/
control MyDeparser(
    packet_out packet,
    in headers_t hdr)
{
    apply {
        packet.emit(hdr.collector_ethernet);
        packet.emit(hdr.collector_ipv4);
        packet.emit(hdr.collector_udp);
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.udp);
        packet.emit(hdr.ioam_payload);
        packet.emit(hdr.vxlan_gpe);
        packet.emit(hdr.gpe_ioam);
    }
}


V1Switch(
    MyParser(),
    MyVerifyChecksum(),
    MyIngress(),
    MyEgress(),
    MyComputeChecksum(),
    MyDeparser()
) main;
