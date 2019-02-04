From: Oleg Drokin <green@whamcloud.com>
Date: Mon, 4 Feb 2019 17:10:08 +0000
Subject: [lustre-devel] New tag 2.12.51
Message-ID: <56386C0E-6303-44AF-8205-99E90961977A@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   I just tagged 2.12.51 tag in lustre community development branch. here?s the changelog:

Alex Zhuravlev (3):
      LU-11737 lfsck: do not ignore dryrun
      LU-10953 tests: disable sanity/300k on small setups
      LU-11889 tests: disable sanity/156 for ZFS OST

Alexander Boyko (2):
      LU-11716 tests: fix scrub tests
      LU-11852 osc: skip cache entry wakeup without grants

Amir Shehata (1):
      LU-11415 socklnd: improve scheduling algorithm

Andreas Dilger (18):
      LU-11453 misc: add compat for INIT_LIST_HEAD_RCU
      LU-11398 ptlrpc: clean up rq_interpret_reply callbacks
      LU-11579 lov: quiet lov_dump_lmm_ console messages
      LU-11736 utils: don't set max_sectors_kb on MDT/MGT
      LU-11771 osd: avoid use of HZ in brw_stats
      LU-8066 lnet: properly isolate kernel_param_ops
      LU-11820 tests: skip conf-sanity test_106 for SLOW=no
      LU-11579 llite: remove cl_file_inode_init() LASSERT
      LU-11810 misc: allow Fixes: tag in commit signoff block
      LU-11834 llite: fix temporary instance buffer size
      LU-11625 ofd: handle upgraded filter_fid properly
      LU-11845 zfs: put configure checks in version order
      LU-11665 tests: check number of pages correctly
      LU-11566 utils: fix lctl llog_print for large configs
      LU-11770 osd-ldiskfs: clean up inline macro usage
      LU-8066 ldlm: match store macro prototype
      LU-930 doc: move server man pages to server package
      LU-11721 tests: wait for statfs to update on DNE

Andrew Perepechko (1):
      LU-11296 osc: speed up page cache cleanup during blocking ASTs

Andriy Skulysh (4):
      LU-11699 lfsck: Umount while running LFSCK
      LU-11700 osp: GPF in osp_reserved_mb_low_seq_write()
      LU-11757 lod: use calculated stripe count
      LU-7558 ptlrpc: connect vs import invalidate race

Arshad Hussain (10):
      LU-6142 lmv: Fix style issues for lmv_fld.c
      LU-6142 lod: Fix style issues for lod_dev.c
      LU-6142 mgs: Fix style issues for mgs_fs.c
      LU-6142 llite: Fix style issues for glimpse.c
      LU-6142 llite: Fix style issues for llite_nfs.c
      LU-6142 llite: Fix style issues for lcommon_misc.c
      LU-6142 llite: Fix style issues for symlink.c
      LU-11606 utils: Call llapi_error() for errors in liblustreapi files
      LU-9010 ptlrpc: Change static defines to use macro for gss_svc_upcall.c
      LU-9010 tests: Change static defines to use macro for kinode.c

Artem Blagodarenko (5):
      LU-10384 mgs: replace_nids large string and failover support
      LU-10883 llog: fix backup file name comparison
      LU-7159 tests: fix 224c fault injection
      LU-1365 utils: allow set block size for ldiskfs backend
      LU-1365 tests: LARGEDIR and 3-level htree for local ldiskfs

Ben Evans (1):
      LU-10171 headers: define pct(a,b) once

Bobi Jam (1):
      LU-10239 osc: limit chunk number of write submit

Chris Horn (1):
      LU-11712 osd-ldiskfs: Wrap blk integrity with config check

Elena Gryaznova (7):
      LU-11078 tests: customise run_ior()
      LU-11503 tests: fix "division by 0" defect
      LU-11504 tests: trigger lfsck after/during failover/failback
      LU-11717 tests: exit_status () defect
      LU-10815 tests: all_mdts_nodes() all_osts_nodes() defect
      LU-11496 tests: start_client_loads () fix
      LU-11843 tests: customise sanity-quota

George Melikov (1):
      LU-10966 utils: Fix `lfs check` documentation and arguments

Gu Zheng (1):
      LU-11575 build: install systemd stuff only for debian with systemd enabled

Hongchao Zhang (1):
      LU-11647 ptlrpc: always unregister bulk

James Nunez (6):
      LU-7631 tests: add debug info to conf-sanity 82a
      LU-10447 tests: deprecate $SETSTRIPE/$GETSTRIPE in sanity
      LU-11402 tests: add version check sanity-quota 60
      LU-10447 tests: replace $SET/$GETSTRIPE in replay tests
      LU-11607 tests: create routine to get Lustre env
      LU-11161 tests: start running sanity 160g again

James Simmons (8):
      LU-7004 mgs: remove using obdname2fsname() from mgs layer.
      LU-8066 obdclass: report all obd states for OBD_IOC_GETDEVICE
      LU-8066 mdd: migrate from proc to sysfs
      LU-8066 sysfs: make ping sysfs file read and writable
      LU-10937 sptlrpc: split sptlrpc_process_config()
      LU-9325 msg: replace obsolete simple_strtoul use
      LU-11838 kernel: harden current_time autoconf test
      LU-11828 clio: fix incorrect invariant in cl_io_iter_fini()

Jeremy Filizetti (1):
      LU-10866 pacemaker: Support additional mount options

Jian Yu (3):
      LU-11669 tests: add project in yml_test_group()
      LU-11723 kernel: kernel update RHEL7.6 [3.10.0-957.1.3.el7]
      LU-11739 lod: don't inherit default layout from root directory

John L. Hammond (1):
      LU-10862 ldlm: remove trace from ldlm_pool_{count,skrink}()

Kit Westneat (1):
      LU-8939 nodemap: remove deprecated lproc files

Lai Siyao (3):
      LU-11620 lfsck: change llsd_rb_lock to rwsemaphore
      LU-11661 test: improve sanityn test_47g
      LU-11418 mdd: delete name if orphan doesn't exist

Li Dongyang (1):
      LU-11790 ldiskfs: add terminating u32 when expanding inodes

Nathaniel Clark (2):
      LU-11683 build: Update ZFS to 0.7.12
      LU-11555 utils: ZFS check multihost enabled in read_ldd()

NeilBrown (4):
      LU-11838 lustre: discard LTIME_S macro
      LU-11838 lnet: change lnet_ipaddr_enumerate() to use for_each_netdev()
      LU-9859 libcfs: add watchdog for ptlrpc service threads.
      LU-11838 o2iblnd: get IP address more directly.

Nikitas Angelinas (2):
      LU-11755 ldlm: remove LASSERT() in ns_is_{client,server}()
      LU-11721 utils: print used inodes ratio when using "lfs df -i"

Olaf Faaland (1):
      LU-7239 mdd: make mdd_attr_set() synchronous less often

Oleg Drokin (1):
      New tag 2.12.51

Patrick Farrell (5):
      LU-11719 ldlm: Adjust search_* functions
      LU-10070 tests: Fix replay-single test_85b
      LU-11825 clio: Remove pio feature
      LU-11868 mdc: Improve xattr buffer allocations
      LU-10059 tests: sanityn 32a restore parameters

Qian Yingjin (1):
      LU-11696 utils: "lfs getsom" returns "24" to userspace

Sebastien Buisson (5):
      LU-11750 krb5: krb5int_derive_key has 'hash' extra parameter
      LU-8955 cfg: reserve flags for SELinux status checking
      LU-8955 nodemap: add SELinux policy info to nodemap
      LU-8955 sec: create new function sptlrpc_get_sepol()
      LU-11871 doc: man page for lctl nodemap_set_fileset

Sergey Cheremencev (2):
      LU-11537 osp: avoid nested transaction
      LU-11605 osp: max_create_count and create_count changes

Wang Shilong (1):
      LU-11689 lfs: make sure project proceed all dirs

Yang Sheng (2):
      LU-11658 lov: cl_cache could miss initialize
      LU-11658 tests: fix typo in previous patch
