#!/bin/bash


 ~/nfp-sdk-6.1-preview/p4/bin/nfp4build --output-nffw-filename ./out/app.nffw \
         --incl-p4-build ./p4src/ioam_endpoint.p4 \
         --sku AMDA0081-0001:0 \
         --platform hydrogen \
         --reduced-thread-usage \
         --no-shared-codestore \
         --disable-component gro \
         --no-debug-info \
         --nfp4c_p4_version 14 \
         --nfp4c_p4_compiler hlir \
         --nfirc_default_table_size 65536 \
         --nfirc_no_all_header_ops \
         --nfirc_implicit_header_valid \
         --nfirc_no_zero_new_headers \
         --nfirc_multicast_group_count 00 \
         --nfirc_multicast_group_size 16 \
#         --nfirc_no_mac_ingress_timestamp

