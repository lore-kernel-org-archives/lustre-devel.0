From: Oleg Drokin <oleg.drokin@intel.com>
Date: Tue, 20 Sep 2016 12:02:50 -0400
Subject: [lustre-devel] New tag 2.8.58
Message-ID: <5D5D6A5F-F936-498E-AE0B-5B07128661D5@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   I just tagged a new 2.8.58 tag in Lustre master development tree.

   Here's the changelog:

Alex Zhuravlev (2):
      LU-7898 osd: remove unnecessary declarations
      LU-7898 osd: remove unnecessary declarations

Alexey Lyashkov (2):
      LU-8348 recovery: don't send last_committed after panic
      LU-8410 ldiskfs: new FIEMAP API

Andreas Dilger (1):
      LU-8081 osd-ldiskfs: improve transaction debug message

Andriy Skulysh (4):
      LU-7927 llite: Deadlock between ll_setattr and write/ll_fsync
      LU-7593 target: umount vs tgt_last_rcvd_update deadlock
      LU-8349 ldlm: ASSERTION(flock->blocking_export!=0) failed
      LU-8175 ldlm: conflicting PW & PR extent locks on a client

Arshad Hussain (1):
      LU-7950 osp: Remove assigned but not used variable

Artem Blagodarenko (2):
      LU-8443 utils: exclude "resize" parameter with meta_bg option
      LU-7149 tests: restore writethrough_cache_enable

Bob Glossman (3):
      LU-8513 kernel: kernel update RHEL7.2 [3.10.0-327.28.3.el7]
      LU-8518 kernel: kernel update [SLES12 SP1 3.12.62-60.62]
      LU-8537 kernel: kernel update RHEL6.8 [2.6.32-642.4.2.el6]

Bobi Jam (2):
      LU-8510 dne: set osd_obj_ea_ops::dt_invalidate
      LU-8284 osd-ldisksf: need lock around i_size update

Bruno Faccini (1):
      LU-8165 target: detect race by checking last_rcvd slot index

Christopher J. Morrone (1):
      LU-8540 o2iblnd: Add support for 5arg ib_map_mr_sg()

Di Wang (1):
      LU-7809 lod: stop recovery before destory dtrq list

Dmitry Eremin (1):
      LU-1482 mdd: Setting xattr are properly checked with and without ACLs

Doug Oucharek (3):
      LU-8501 lnet: Ensure routing is turned on first time
      LU-8507 lnet: Enable setting per NI peer_credits
      LU-7650 o2iblnd: Put back work queue check previously removed

Fan Yong (6):
      LU-8408 mgc: handle config_llog_data::cld_refcount properly
      LU-8361 lfsck: detect Lustre device automatically
      LU-8407 recovery: more clear message about recovery failure
      LU-7782 scrub: handle slave obj of striped directory
      LU-6284 ptlrpc: comment for FLD_QUERY RPC reply swab
      LU-6808 ptlrpc: properly set "rq_xid" for 4MB IO

Gu Zheng (1):
      LU-8565 test: change sanity 255a to not fail for performance when running in VM

Hongchao Zhang (2):
      LU-8500 ldlm: fix export reference problem
      LU-8333 test: make sure COS is cleared

Jadhav Vikram (1):
      LU-522 lod: do not ignore degraded flag of ost.

James Nunez (1):
      LU-7813 tests: clean up ost-pools.sh

James Simmons (9):
      LU-6245 libcfs: cleanup list handling
      LU-8025 llite: make vvp_io_write_start lockless for newer kernels
      LU-6245 libcfs: move uid handling to linux directory
      LU-8560 lustre: remove unused crypto handlers in lustre_compat.h
      LU-8560 libcfs: add autoconf test for crypto changes
      LU-8560 libcfs: handle PAGE_CACHE_* removal in newer kernels
      LU-8560 libcfs: handle stacktrace function address() change
      LU-8560 llite: handle is_compat_task() rename
      LU-8560 libcfs: handle page_cache_*() removal in newer kernels

Jinshan Xiong (3):
      LU-7655 tests: ost fake write for performance testing
      LU-8600 tests: ignore error if running in vm for sanity 399
      LU-6441 ptlrpc: fix sanity 224c for different RPC sizes

Kit Westneat (3):
      LU-8498 nodemap: new zfs index files not properly initialized
      LU-8340 nodemap: debug patch
      LU-8508 nodemap: improve object handling in cache saving

Lai Siyao (1):
      LU-8514 mdd: transaction failure should be checked

Li Xi (1):
      LU-4931 ladvise: Add dontneed advice support for ladvise

Nathaniel Clark (1):
      LU-7803 tests: Cleanup after sanity/78

Niu Yawei (3):
      LU-2547 test: re-enable 24a/b of recovery-small
      LU-7903 mdt: dump exports information on console
      LU-7310 clio: sync write should update mtime

Olaf Faaland (1):
      LU-930 misc: update README path to git hooks

Oleg Drokin (2):
      Revert "LU-7898 osd: remove unnecessary declarations"
      New tag 2.8.58

Saurabh Tandan (2):
      LU-3815 tests: sanity-hsm - Remove tests from Always_Except
      LU-8524 tests: Awk command re-structured to pass correct value

Vitaly Fertman (1):
      LU-7433 ldlm: xattr locks are lost on mdt

Wei Liu (1):
      LU-7044 test: Skip sanityn test_77e/77f/77g
