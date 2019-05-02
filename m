From: Oleg Drokin <green@whamcloud.com>
Date: Thu, 2 May 2019 06:11:14 +0000
Subject: [lustre-devel] New tag 2.12.53
Message-ID: <04A752E5-CEAC-4C90-B1A5-64616EB9625D@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

  I just tagged a new tag 2.12.53 in the Lustre master branch.

  Here?s the changelog:

Alex Zhuravlev (10):
      LU-11408 osc: propagate grant shrink interval immediately
      LU-11409 osc: grant shrink shouldn't account skipped OSC
      LU-11821 lfsck: do not compare negatives to sizeof()
      LU-10929 tests: skip sanity/315 if IO accounting is disabled
      LU-11798 grant: prevent overflow of o_undirty
      LU-12069 mdt: add missing argument to enable compilation
      LU-12160 osd-ldiskfs: use-after-free in osd_object_delete()
      LU-12178 osd: do not rebalance quota under memory pressure
      LU-12195 tests: use sleep instead of wrapped multiop
      LU-12147 utils: statone doesn't place \0

Alexander Boyko (3):
      LU-8760 lfsck: fix bit operations lfsck_assistant_data
      LU-10717 tests: tests should not start mgs
      LU-12168 utils: obdfilter fix for SHORT msgs

Alexander Zarochentsev (1):
      LU-11585 quota: no IS_ERR() check in qsd_lqe_read

Alexey Lyashkov (1):
      LU-12040 mdc: reset lmm->lmm_stripe_offset in mdc_save_lovea

Amir Shehata (2):
      LU-12065 lnd: increase CQ entries
      LU-11931 lnd: bring back concurrent_sends

Andreas Dilger (13):
      LU-11721 lod: limit statfs ffree if less than OST ffree
      LU-12068 tests: add debug for sanity-lfsck test_6b
      LU-11596 tests: skip sanity test_64d for ARM
      LU-6202 misc: delete OBD_IOC_PING_TARGET ioctl
      LU-6202 misc: remove LIBCFS_IOC_DEBUG_MASK ioctl
      LU-11566 utils: improve usage/docs for lctl llog commands
      LU-9625 utils: remove old lfs "cp" and "ls" sub-commands
      LU-12027 utils: add units to "lfs find -amctime"
      LU-930 doc: man pages for lctl pool_new, pool_add
      LU-930 doc: improve formatting of lfs.1 synopsis
      LU-947 ptlrpc: allow stopping threads above threads_max
      LU-930 doc: improve mkfs.lustre --fsname description
      LU-12027 utils: fix "lfs find -amctime" comparison

Andrew Perepechko (1):
      LU-8047 llite: optimizations for not granted lock processing

Andriy Skulysh (4):
      LU-10949 mdt: lost reference on mdt_md_root
      LU-11926 ldlm: Lost lease lock on migrate error
      LU-11756 o2iblnd: kib_conn leak
      LU-11925 hsm: attributes aren't updated after RESTORE

Arshad Hussain (11):
      LU-6142 obdclass: Fix style issues for obd_mount.c
      LU-6142 obdclass: Fix style issues for obd_config.c
      LU-8260 osd-ldiskfs: osd_fiemap_get() fix address space mismatch
      LU-9010 ptlrpc: Change static defines to use macro for sec_gc.c
      LU-6142 utils: Fix style issues for create_iam.c
      LU-6142 utils: Fix style issues for l_getidentity.c
      LU-6142 ldlm: Fix style issues for ldlm_pool.c
      LU-6142 ldlm: Fix style issues for ldlm_lockd.c
      LU-6142 ldlm: Fix style issues for ldlm_request.c
      LU-6142 ptlrpc: Fix style issues for sec_bulk.c
      LU-6142 ldlm: Fix style issues for ptlrpcd.c

Ben Evans (1):
      LU-12044 ptlrpc: Translate HABEO_ macros

Bobi Jam (1):
      LU-10258 lfs: lfs mirror copy command

Bruno Faccini (1):
      LU-9193 security: return security context for metadata ops

Chris Horn (1):
      LU-12152 lnet: Cleanup lnet_get_rtr_pool_cfg

Dmitry Eremin (1):
      LU-8384 scripts: Add scripts to systemd for EL7

Elena Gryaznova (4):
      LU-11636 tests: fix test_mkdir() to work with old severs
      LU-12133 tests: sanityn test_35 syntax error
      LU-12203 tests: skip sanity-lfsck 36[b,c] for FILESET
      LU-12208 tests: fix interop with old clients

Gregoire Pichon (1):
      LU-11860 lnet: support config of LNDs with numeric intf name

Gu Zheng (1):
      LU-12141 build: correct the required kernel version for lustre kmod

Hongchao Zhang (4):
      LU-6836 test: re-add test 4a to sanity-quota for ZFS
      LU-11678 quota: protect quota flags at OSC
      LU-12068 test: compare position for ZFS dot entry
      LU-11678 quota: make overquota flag for old req

James Nunez (5):
      LU-10073 tests: stop running smoke test
      Revert "LU-11771 ldlm: use hrtimer for recovery to fix timeout messages"
      LU-11779 tests: add version check for sanity-hsm
      LU-11673 tests: replace obsolete '-o' to '||'
      LU-8434 tests: add script language option to auster

James Simmons (8):
      LU-8066 fid: use LDEBUGFS_SEQ_* macro
      LU-11742 test: have libtool execute the test binaries
      LU-8066 obd: make health_check sysfs compliant
      LU-8130 nrs: convert NRS CRR to rhashtable
      LU-8066 llite: don't use class_setup_tunables()
      LU-11771 ldlm: use hrtimer for recovery to fix timeout messages
      LU-11986 lnet: properly cleanup lnet debugfs files
      LU-8066 obd: update udev event handling

Jian Yu (2):
      LU-12172 kernel: kernel update RHEL7.6 [3.10.0-957.10.1.el7]
      LU-12138 kernel: kernel update SLES12 SP4 [4.12.14-95.13.1]

Jinshan Xiong (1):
      LU-11999 dne: performance improvement for file creation

Lai Siyao (4):
      LU-12037 mdt: call mdt_dom_discard_data() after rename unlock
      LU-12081 mdt: rename shouldn't PDO lock if parent is remote
      LU-11213 uapi: reserve connect flag for plain layout
      LU-12037 mdt: add option for cross-MDT rename

Li Dongyang (1):
      LU-11922 ldiskfs: make dirdata work with metadata_csum

Li Xi (1):
      LU-10602 llite: add file heat support

Mikhail Pershin (7):
      LU-11836 ldlm: don't convert wrong resource
      LU-10496 ofd: move FMD to the target code
      LU-11964 mdc: prevent glimpse lock count grow
      LU-11835 mdt: return DOM size on open resend
      LU-11752 osc: pass client page size during reconnect too
      LU-10496 tgt: move FMD handling from OFD to target
      LU-10777 dom: disable read-on-open with resend

Nathaniel Clark (4):
      LU-12059 build: Update ZFS version to 0.7.13
      LU-11394 build: Remove SPL requirements
      LU-11394 utils: Adjust HOSTID constant
      LU-11845 osd-zfs: Support encrypted ZFS datasets

NeilBrown (1):
      LU-9859 libcfs: remove wi_data from cfs_workitem

Oleg Drokin (3):
      LU-12030 tests: Properly detect debug kernel use on rhel7.6
      Revert "LU-11367 som: integrate LSOM with lfs find"
      New tag 2.12.53

Patrick Farrell (6):
      LU-11403 llite: ll_fault fixes
      LU-12175 tests: Partial revert of LU-11636
      LU-11868 osd: Set max ea size to XATTR_SIZE_MAX
      LU-11691 lov: Limit layout size to max ea size
      LU-11796 lov: Remove unnecessary assert
      LU-12261 tests: Race between exec and truncate

Qian Yingjin (3):
      LU-12021 lsom: Add an OBD_CONNECT2_LSOM connect flag
      LU-10092 pcc: Reserve a new connection flag for PCC
      LU-11367 som: integrate LSOM with lfs find

Sebastien Buisson (7):
      LU-12039 tests: fix 'lfs mkdir' in sanity-selinux
      LU-8955 ptlrpc: manage SELinux policy info at connect time
      LU-8955 ptlrpc: manage SELinux policy info for metadata ops
      LU-8955 tests: exercise SELinux policy info
      LU-930 doc: add audit_mode in lctl-nodemap-modify man page
      LU-930 doc: man page for lctl nodemap_set_sepol
      LU-930 doc: man page for l_getsepol

Sergey Cheremencev (1):
      LU-11601 ptlrpc: IR doesn't reconnect after EAGAIN

Sonia Sharma (1):
      LU-11986 lnet: Avoid lnet debugfs read/write if ctl_table does not exist

Thomas Stibor (1):
      LU-11902 build: Remove obsolete lustre-utils files and entries

Vladimir Saveliev (2):
      LU-11898 libcfs: do not calculate debug_mb if it is set
      LU-12055 lod: ignore root layout if parent's one includes pool

Wang Shilong (7):
      LU-11885 test: reset quota upon test failed
      LU-12165 quota: fix to use correct fsname array size
      LU-12151 osd-ldiskfs: pass owner down rather than transfer it
      LU-12166 test: fix broken detection on ZFS
      LU-11355 lustre: enable fstrim on lustre device
      LU-12043 llite: switch to use ll_fsname directly
      LU-12169 llite: fill copied dentry name's ending char properly

Yang Sheng (1):
      LU-12072 lov: remove KEY_CACHE_SET to simplify the code
