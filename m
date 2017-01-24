From: Oleg Drokin <oleg.drokin@intel.com>
Date: Tue, 24 Jan 2017 00:29:21 -0500
Subject: [lustre-devel] new tag 2.9.52
Message-ID: <2EE5D2FA-F770-4302-92EC-2C75FBBC85B2@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   I have just tagged 2.9.52 in the lustre master development branch.

   Changelog:
Abrarahmed Momin (1):
      LU-8732 tests: lnet-selftest Error inserting modules

Aditya Pandit (1):
      LU-7471 tests: Modified make_custom_file_for_progress fn

Amitoj Kaur Chawla (1):
      LU-4423 libcfs: Use swap() in cfs_hash_bd_order()

Andreas Dilger (1):
      LU-3764 tests: clean up sanity test_116a code style

Arnd Bergmann (11):
      LU-4423 libcfs: use 64-bit inode timestamps internally
      LU-4423 libcfs: tracefile document seconds overflow
      LU-4423 ldlm: use time64_t for l_last_activity
      LU-4423 ptlrpc: use 64-bit time for adaptive timeout
      LU-4423 libcfs: use 64-bit times for cfs_srand seed
      LU-4423 lnet: use 64-bit time for selftest
      LU-4423 ptlrpc: use 64-bit times for ptlrpc sec expiry
      LU-4423 obd: use ktime_t for calculating elapsed time
      LU-4423 ldlm: use 64-bit time for pl_recalc
      LU-4423 ptlrpc: use 64-bit times in ptlrpc_enc_page_pool
      LU-4423 ptlrpc: use 64-bit times for ptlrpc_sec

Ben Evans (1):
      LU-6401 headers: move lu_fid, ost_id funcs out of lustre_idl.h

Bob Glossman (3):
      LU-8965 kernel: kernel update [SLES11 SP4 3.0.101-91]
      LU-8871 kernel: kernel upgrade [SLES12 SP2 4.4.21-84]
      LU-8996 kernel: kernel update RHEL6.8 [2.6.32-642.13.1.el6]

Di Wang (4):
      LU-8922 lod: check master stripes properly
      LU-8753 llog: remove lgh_write_offset
      LU-8753 osp: add rpc generation
      LU-8994 lmv: honour the specified stripe index

Dmitry Eremin (3):
      LU-8889 llite: replace memory allocation with ll_env usage
      LU-8703 libcfs: remove usless CPU partition code
      LU-8710 ptlrpc: use current CPU instead of harcoded 0

Doug Oucharek (1):
      LU-8752 lnet: Stop MLX5 triggering a dump_cqe

Elena Gryaznova (1):
      LU-8966 tests: rename sanity 39, 43, 44, 241 tests

Emoly Liu (2):
      LU-8635 tests: Use wait_update to expire jobstats
      LU-8973 tests: in sanity 103a use $tdir instead of $MOUNT

Fan Yong (6):
      LU-8569 linkea: linkEA size limitation
      LU-8569 lfsck: handle linkEA overflow
      LU-8288 lfsck: handle dangling LOV EA reference
      LU-8840 osp: handle EA cache properly
      LU-7429 tests: generate dangling name entry properly
      LU-8929 lfsck: dumper gets current position properly

Gregoire Pichon (1):
      LU-8932 lnet: define new network driver ptl4lnd

Hongchao Zhang (1):
      LU-7481 utils: label lustre device correctly

James Nunez (1):
      Revert "LU-8922 lod: check master stripes properly"

James Simmons (10):
      LU-6245 libcfs: add ktime_get_real_seconds support
      LU-6401 header: remove libcfs.h in interval_tree.h
      LU-8378 obd: move s3 in lmd_parse to inner loop
      LU-6142 lnet: change wire protocol typedefs to proper structure
      LU-8835 osc: handle 64 bit time properly in osc_cache_too_much
      LU-8945 ptlrpc : remove userland usage from ptlrpc
      LU-6142 lnet: code style cleanups, improve error handling
      LU-9019 lnet: simplify lnet_eq_wait_locked
      LU-6245 libcfs: remove wrappers for timer functions
      LU-9019 osd : remove struct timeval use in osd-ldiskfs

Jinshan Xiong (2):
      LU-6854 llite: Do not set writeback for sync write pages
      LU-7812 tests: address race condition for sanity:120{e,f}

John L. Hammond (2):
      LU-8821 mdt: avoid double find in mdt_path_current()
      LU-8855 llite: return small device numbers for compat stat()

Lai Siyao (1):
      LU-8314 lfs: improve getdirstripe interface

Ned Bass (1):
      LU-8562 osp: osp_precreate_thread gets stuck after disconnect

Niu Yawei (1):
      LU-8765 ptlrpc: update replay cursor when close during replay

Oleg Drokin (6):
      LU-8066 obd: Generic helpers for sysfs
      LU-8066 obd: Move /proc/fs/lustre root level files to sysfs
      LU-8066 obd: Add debugfs root
      LU-8066 obdclass: move lustre sysctl to sysfs
      LU-8587 utils: Fix incorrect indenting in llapi_hsm_log_ct_progress
      New tag 2.9.52

Patrick Farrell (1):
      LU-8926 llite: reduce jobstats race window

Steve Guminski (10):
      LU-6210 snmp: Change positional struct initializers to C99
      LU-6210 tests: Change positional struct initializers to C99
      LU-6210 obd: Change positional struct initializers to C99
      LU-6210 mdt: Change positional struct initializers to C99
      LU-6210 ldlm: Change positional struct initializers to C99
      LU-6210 osd: Change positional struct initializers to C99
      LU-6210 fid: Change positional struct initializers to C99
      LU-6210 mgs: Change positional struct initializers to C99
      LU-6210 lod: Change positional struct initializers to C99
      LU-4315 docs: Fix Makefile.am to have one man page per line

Tina Ruchandani (1):
      LU-4423 lnet: Better cookie gen

Yang Sheng (3):
      LU-8957 obdclass: fix exp_nid_hash race
      LU-8969 llite: sanity test_56x read failed: Invalid argument
      LU-7115 fld: don't retry for no LWP device
