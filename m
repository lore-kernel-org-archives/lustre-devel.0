From: Oleg Drokin <oleg.drokin@intel.com>
Date: Tue, 23 May 2017 01:48:53 -0400
Subject: [lustre-devel] new tag 2.9.58
Message-ID: <3C6162D1-5FE5-4EFC-9D31-D2A7CE83F5B8@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   I just tagged 2.9.58 tag in the lustre development master tree.

   Here's the changelog:
Alex Zhuravlev (3):
      LU-9285 osp: revert patches LU-8367 and LU-8973
      LU-8367 osp: orphan cleanup do not wait for reserved
      LU-9394 osd: __osd_obj2dnode() to return negative errors

Amir Shehata (1):
      LU-9119 lnet: selftest MR fix

Andreas Dilger (9):
      LU-9201 test: avoid long sleeps in mount_facet()
      LU-8998 llapi: add LLAPI_LAYOUT_COMP_USE_PREV
      LU-9411 tests: skip llapi_layout_test 30, 31 for interop
      LU-7567 utils: fix timestamp printing in lfs_changelog()
      LU-8998 tests: improve sanity.sh::check_seq_oid()
      LU-7584 tests: clean up sanity test_129
      LU-8589 osd: remove "object" from method function names
      LU-9415 lfsck: quiet noisy console message
      LU-9330 osp: make variables match proc tunables

Andriy Skulysh (3):
      LU-7062 ldlm: GPF in _ldlm_lock_debug()
      LU-8359 ldlm: Wrong evict during failover
      LU-9241 llite: ASSERTION( de->d_op == &ll_d_ops ) failed

Arnd Bergmann (2):
      LU-4423 ptlrpc: use 64-bit times for request times
      LU-4423 selftest: use jiffies_to_*() instead of cfs_duration_usec

Arshad Hussain (1):
      LU-8670 tests: test_115 Fixes & Improvements

Bob Glossman (1):
      LU-9458 ptlrpc: handle case of epp_free_pages <= PTLRPC_MAX_BRW_PAGES

Bobi Jam (6):
      LU-9324 lfs: output stripe info in YAML format
      LU-9357 pfl: should inherit pool from previous layout comp
      LU-9324 lnet: move cyaml.h under lnet/include/
      LU-9362 lfs: getstripe print last init-ed component info
      LU-9315 pfl: static analysis issues
      LU-9412 lfs: A invalid memory write in llapi_layout_to_lum

Bruno Faccini (3):
      LU-8376 ost: enhance end to end bulk cksum error report
      LU-9372 ptlrpc: drain "ptlrpc_request_buffer_desc" objects
      LU-9477 tests: check correct handling of dead object

Chris Hanna (1):
      LU-9430 utils: fix logic errors and putchar in sk_name2hmac()

Chris Horn (1):
      LU-9447 o2iblnd: Check for 2 arg ib_alloc_pd

Dmitry Eremin (5):
      LU-9183 llite: handle make the string hashes salt the hash
      LU-9183 llite: handle removal the pos argument of generic_write_sync
      LU-9205 tests: fix failures in CLIENTONLY mode
      LU-9183 ptlrpc: handle changes in struct group_info
      LU-9183 llite: remove struct file on stack in ll_setxattr()

Doug Oucharek (4):
      LU-8943 lnd: Enable Multiple OPA Endpoints between Nodes
      LU-9456 lnd: Change sock_create() to sock_create_kern()
      LU-9425 lnd: Turn on 2 sges by default
      LU-9472 lnd: Fix FastReg map/unmap for MLX5

Emoly Liu (1):
      LU-9369 lfs: make lfs find work correctly

Fan Yong (4):
      LU-9040 scrub: detect dead loop scanning
      LU-7473 acl: increase ACL entries limitation
      LU-9202 lfsck: skip unavailable targets when sync failures
      LU-9303 doc: man pages for snapshot components

Frank Zago (1):
      LU-7988 hsm: change coordinator start/stop mechanisms

Giuseppe Di Natale (1):
      LU-9439 scripts: lnet systemd service

Hongchao Zhang (3):
      LU-5788 test: fix the cmd to getfree space
      LU-8346 obdclass: guarantee all keys filled
      LU-6952 mount: Mount options parsing problem

James Nunez (4):
      LU-9125 test: Update setstripe options
      LU-9096 test: add sanity 253 to ALWAYS_EXCEPT
      LU-9514 test: sanity 51f add to ALWAYS_EXCEPT
      LU-9522 test: sanity 27z fix update local variable

James Simmons (2):
      LU-9019 libcfs: migrate watchdog to 64 bit time
      LU-6401 uapi: turn lustre_param.h into a proper UAPI header

Jinshan Xiong (3):
      LU-9305 osd-zfs: arc_buf could be non-pagesize aligned
      LU-9340 lov: Initialize component extents unconditionally
      LU-9491 llite: Handle multi-vec append write correctly

John L. Hammond (8):
      LU-9312 hsm: fix error handling around mdt_hsm_get_md_hsm()
      LU-9312 hsm: add a cookie indexed request hash
      LU-9403 mdt: prevent HSM leak on re-archive
      LU-9404 mdt: set HSM xattr only when needed
      LU-9385 mdt: remove XATTR locking from mdt_add_dirty_flag()
      LU-9443 mdd: omit changelog records for volatile files
      LU-9312 hsm: release restore lock without object
      LU-9464 hsm: use OBD_ALLOC_LARGE() for hsm_scan_data array

Kit Westneat (1):
      LU-8294 gss: quiet cache_check return ENOENT warning

Lai Siyao (1):
      LU-8650 mdt: enable REP-ACK for DNE

Niu Yawei (1):
      LU-8998 tools: support negative flags

Oleg Drokin (2):
      Revert "LU-9439 scripts: Change behavior of lustre_rmmod"
      New tag 2.9.58

Patrick Farrell (1):
      LU-8307 ldlm: cond_resched in ldlm_bl_thread_main

Prakash Surya (1):
      LU-9439 scripts: Change behavior of lustre_rmmod

Qian Yingjin (1):
      LU-9140 nrs: add some debug log for NRS TBF

Saurabh Tandan (1):
      LU-7108 test: Remove sanityn tests from ALWAYS_EXCEPT list

Sebastien Buisson (1):
      LU-8659 tests: use runcon in sanity-selinux

Sushant Mane (1):
      LU-8730 test: Remove duplicate $dev from conf-sanity test_83

Wang Shilong (1):
      LU-4017 quota: cleanup to improve quota codes

Yang Sheng (2):
      LU-8364 ldiskfs: fixes for failover mode
      LU-9384 ldiskfs: port upstream patches for changing extra isize

sharmaso (1):
      LU-9119 lnet: Fix deleting peers from YAML

wangdi (1):
      LU-8746 update: restore tdtd_refcount during failure
