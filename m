From: Oleg Drokin <oleg.drokin@intel.com>
Date: Tue, 21 Jun 2016 21:11:12 -0400
Subject: [lustre-devel] New tag 2.8.55
Message-ID: <D8CF8237-EA4F-4F98-921A-A8E1205E7D6C@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   I just tagged new version in master development tree: 2.8.55.

   Here's the changelog:

Abrarahmed Momin (1):
      LU-7776 tests: lnet-selftest.sh local_mode failure

Alex Zhuravlev (3):
      LU-7908 osp: fake precreate support
      LU-7901 osd: put sa_bulk_attr_t in osd_thread_info
      LU-7893 osd-zfs: fix error handling in osd_mount()

Alexander Boyko (1):
      LU-7934 osp: fix tr->otr_next_id overflow

Amitoj Kaur Chawla (1):
      LU-8057 ko2iblnd: Replace sg++ with sg = sg_next(sg)

Andreas Dilger (7):
      LU-7372 tests: disable replay-dual test_26
      LU-7418 tests: cancel all locks in sanity test_29
      LU-5969 lustreapi: replace llapi_get_version()
      LU-1595 build: improve prepare-commit-msg git hook
      LU-3434 misc: style check whole patch when rebasing
      LU-7813 utils: improve lfs setstripe pool error message
      LU-7004 utils: remove "lctl conf_param" deprecation

Andriy Skulysh (2):
      LU-7626 ldlm: refcount nonzero (1) after lock cleanup
      LU-7830 ost: do not evict during truncate

Ann Koehler (1):
      LU-7997 obd: RCU stalls in lu_cache_shrink_count()

Ben Evans (1):
      LU-8058 utils: Remove old commented out code

Bob Glossman (2):
      LU-8196 obd: force very large allocations to use vmalloc
      LU-8227 kernel: kernel update RHEL6.8 [2.6.32-642.1.1.el6]

Bobi Jam (1):
      LU-7860 ldlm: revert part of commit 657bbc49

Bruno Faccini (1):
      LU-7486 obdclass: health_check to report unhealthy upon LBUG

Chris Horn (1):
      LU-8102 ldlm: Correlate ptlrpc req w/AST error

Di Wang (1):
      LU-8044 mgs: Only add OSP for registered MDT

Dmitry Eremin (5):
      LU-8241 ofed: fix compilation with MOFED 3.3
      LU-7258 osc: fix signed one bit field
      LU-7259 osd-ldiskfs: fix signed one bit field
      LU-8056 libcfs: Support for linux 4.2 kernels
      LU-7747 lfs: fix help message for migrate

Elena Gryaznova (1):
      LU-7445 test: combine dependent sanity 51b and 51ba tests

Fan Yong (5):
      LU-6861 scrub: only trigger full OI scrub when necessary
      LU-7302 scrub: join the running OI scrub properly
      LU-8182 mdt: check connection data properly
      LU-8279 scrub: fix inode reference leak
      LU-6971 cleanup: not support remote client anymore

Frank Zago (3):
      LU-8157 tests: functional testing for swap layout
      LU-8163 hsm: user_request_mask can't be unset in test 24c
      LU-8171 hsm: stack overrun in hai_dump_data_field

Giuseppe Di Natale (1):
      LU-7334 lprocfs: Allow a new line before null terminator

Henri Doreau (2):
      LU-8138 utils: misc fixes in wirecheck
      LU-8232 obdclass: remove dead code

Hongchao Zhang (2):
      LU-7428 osd: set device read-only correctly
      LU-5564 mdt: skip permission check for close

Jadhav Vikram (1):
      LU-7536 mdt: handling NULL dereference in mdt_reconstruct

James Nunez (1):
      LU-4257 test: Correct error_ignore message

James Shimek (1):
      LU-7955 gnilnd: Add ability to set bte_get/put_dlvr_mode

James Simmons (1):
      LU-6245 libcfs: remove types abstraction from libcfs/LNet code

Jeremy Filizetti (8):
      LU-3289 gss: Interface and code changes for shared key
      LU-3289 gss: Add Shared key and GSS Null functionality
      LU-3289 osp: osp_precreate_thread does not check for errors
      LU-3289 gss: Return GSS major and minor status
      LU-3289 gss: Add userspace support for GSS null and sk
      LU-3289 gss: Add option for loading keys during mount
      LU-3289 gss: Cleanup gss print statements and comments
      LU-3289 gss: Add two additional security flavors for sk

Jinshan Xiong (1):
      LU-2766 llite: don't ignore layout for group lock request

John L. Hammond (5):
      LU-8036 utils: remove ARRAY_SIZE() define from lustreapi.h
      LU-5560 obd: reserve connection flag OBD_CONNECT2_FILE_SECCTX
      LU-4781 utils: handle EEXIST in lustre_rsync
      LU-8277 scripts: add missing commas in checkpatch.pl
      LU-5969 procfs: restore missing newline for version param

Kit Westneat (1):
      LU-5092 nodemap: handle config changes while mid-flight

Li Xi (1):
      LU-8006 ptlrpc: cleanup codes of TBF command

Minh Diep (1):
      LU-5953 build: use installed OFED by default with dpkg

Nathaniel Clark (5):
      LU-8146 osd-zfs: Build against SPL/ZFS 0.6.5.7
      LU-7890 lov: Ensure correct operation for large object sizes
      LU-7993 test: Fix division by 0 in info prints
      LU-7920 hsm: Account for decreasing max request count
      LU-3289 gss: Cleanup gss code

Oleg Drokin (4):
      LU-8019 llite: Restore proper opencache operations
      LU-8179 libcfs: Do not include libcfs/util/ioctl.h in kernel code
      LU-7805 llite: Remove unused members of struct ll_sb_info
      New tag 2.8.55

Sebastien Buisson (2):
      LU-4048 build: fix 'control flow' errors
      LU-7846 tests: test for nodemap fileset in sanity-sec

Sergey Cheremencev (1):
      LU-8178 lproc: fix negative recovery_duration

Ulka Vaze (1):
      LU-6523 lmv: Error not handled for lmv_find_target

Vitaly Fertman (1):
      LU-7434 ptlrpc: lost bulk leads to a hang

Wang Shilong (1):
      LU-8216 ldiskfs: fix journal quota files

akam kumar bharathi (1):
      LU-5954 IOC_MDC_GETFILEINFO returns the wrong ino
