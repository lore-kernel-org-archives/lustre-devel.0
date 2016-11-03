From: Oleg Drokin <oleg.drokin@intel.com>
Date: Thu, 3 Nov 2016 00:24:01 -0400
Subject: [lustre-devel] New tag 2.8.60
Message-ID: <65318749-5517-4F61-BF7A-A8CAA31E7637@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   I just tagged 2.8.60 in the master development branch.

   Here's the changelog:

Alex Zhuravlev (4):
      LU-8527 osd: ot_credits must be 32bit
      LU-8695 target: use -1 as an offset to declare write
      LU-8775 osd: do not report special writes in brw stats
      LU-8573 lnet: Revert LU-7650 patches

Amir Shehata (1):
      LU-8492 ptlrpc: Correctly calculate hrp->hrp_nthrs

Andreas Dilger (4):
      LU-8668 tests: print more information about dd failure
      LU-3289 ssk: fix SK_IV_REV_START on 32-bit systems
      LU-8124 osd-zfs: fix statfs small blocksize inode estimate
      LU-930 doc: move DLC doc to Documentation dir

Andriy Skulysh (1):
      LU-8347 ldlm: granting conflicting locks

Artem Blagodarenko (2):
      LU-8239 utils: llanalyze logs parser fix
      LU-8239 utils: llanalyze drops useful logs

Bob Glossman (4):
      LU-8669 kernel: kernel update RHEL6.8 [2.6.32-642.6.1.el6]
      LU-8692 kernel: kernel update RHEL7.2 [3.10.0-327.36.2.el7]
      LU-8751 kernel: kernel update RHEL7.2 [3.10.0-327.36.3.el7]
      LU-8755 kernel: kernel update [SLES12 SP1 3.12.62-60.64.8]

Bobi Jam (4):
      LU-8682 llite: protect from accessing NULL lli_clob
      LU-8413 test: limit # of processes for sanity test_101f
      LU-8683 readahead: update ras window correctly
      LU-8680 osc: soft lock - osc_makes_rpc()

Bruno Faccini (1):
      LU-8685 kernel: jbd2: fix incorrect unlock on j_list_lock

Chris Horn (1):
      LU-8733 gnilnd: Remove read capability of cksum_test procfile

Chuck Fossen (1):
      LU-8429 gnilnd: Option to not reconnect after conn timeout

Di Wang (3):
      LU-8667 osp: validate FID before initializing precreate seq
      LU-8250 mdd: move linkea prepare out of transaction.
      LU-7206 mdd: stop orphan cleanup before finish FLD

Elena Gryaznova (1):
      LU-8705 tests: do not skip lnet-selftest for DNE

Fan Yong (5):
      LU-8592 mdt: hold mdt_device::mdt_md_root until service stop
      LU-8569 lfsck: cleanup lfsck requests list before exit
      LU-6635 lfsck: block replacing the OST-object for test
      LU-8574 osd-ldiskfs: fix FID-in-dirent properly
      LU-7593 target: take ted_lcd_lock after transaction started

Frank Zago (1):
      LU-7988 hsm: make mdt_hsm_cdt_start a static function

Gu Zheng (1):
      LU-4931 ladvise: add code for ladvise_hdr into wirecheck.c

Hongchao Zhang (1):
      LU-8209 ldlm: engage ELC for all ldlm enqueue req

Jadhav Vikram (1):
      LU-8575 lod: clear ost usable flag to avoid striping.

James Simmons (7):
      LU-6245 libcfs: remove last of types abstractions
      LU-6245 libcfs: remove cfs_fs_time handling
      LU-8648 all: remove all Sun license and URL references
      LU-6387 tests: fix lp_utils build issues on Power8
      LU-8660 mgs: handle return code of server_make_name()
      LU-8697 llite: remove IS_ERR(master_inode) check
      LU-6303 osc: remove handling cl_avail_grant less than zero

Jeremy Filizetti (3):
      LU-3289 gss: Change the handling of keys for SK
      LU-3289 gss: Fix issues with SK privacy and integrity mode
      LU-8590 gss: Move DH parameter generation out of upcall

Jian Yu (1):
      LU-8311 doc: add NIDs examples to mkfs.lustre and mount.lustre

Jinshan Xiong (1):
      LU-8633 llite: do not clear uptodate bit in page delete

John L. Hammond (3):
      LU-8654 obd: access ocd_connect_flags2 only when present
      LU-8723 llapi: correct open() handling in llapi_obd_statfs()
      LU-8731 utils: propagate errors in lfs df

Kit Westneat (1):
      LU-8450 nodemap: modify ldlm_revoke_export_locks

Lai Siyao (1):
      LU-8749 osd-ldiskfs: inherit S_ISGID correctly

Li Xi (2):
      LU-4931 ofd: use thread buffer for ladvise
      LU-8289 utils: add ll_decode_linkea tool

Lokesh Nagappa Jaliminche (1):
      LU-7919 mount: Buffer overflow issue while parsing mount

Mikhail Pershin (1):
      LU-8089 lwp: change lwp export only at first connect

Minh Diep (3):
      LU-8519 build: make SLES use lbuild kernel-devel
      LU-8636 build: prevent src download at the same time
      LU-8707 build: fix lbuild-sles for kernel_module_package

Nathaniel Clark (4):
      LU-8630 build: Fix definition of KMP_MODDIR
      LU-7111 revert: b=22386 disallow wrong conf_param options
      LU-8713 utils: Try loading zfs.ko during zfs_init
      LU-8694 docs: ZFS hostid mkfs.lustre(8) man page update

Niu Yawei (6):
      LU-7903 ptlrpc: leaked rs on difficult reply
      LU-8645 ptlrpc: update imp_known_replied_xid on resend-replay
      LU-8681 osd: ingore ENODATA during unlink agent parent
      LU-6808 ptlrpc: no need to reassign mbits for replay
      LU-8631 quota: better error message for 'lfs quota'
      LU-8748 osd-zfs: set block size of echo object

Oleg Drokin (2):
      LU-8246 ldlm: Do not grant a lock twice in a race
      New tag 2.8.60

Parinay Kondekar (1):
      LU-8226 tests: Change check_catastrophe() to check_node_health()

Patrick Farrell (1):
      LU-8658 ptlrpc: Suppress error for flock requests

Rahul Deshmukh (1):
      LU-1882 llite: Adding timed wait in ll_umount_begin

Steve Guminski (2):
      LU-8189 osc: osc_match_base prototype differs from declaration
      LU-8186 llite: Typo in ll_rw_extents_stats_pp_seq_show

Yang Sheng (2):
      LU-7501 utils: keep lfs arguments consistent
      LU-8378 all: remove set but unused variables
