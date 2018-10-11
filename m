From: Oleg Drokin <green@whamcloud.com>
Date: Thu, 11 Oct 2018 18:45:34 +0000
Subject: [lustre-devel] New tag 2.11.56
Message-ID: <F8324727-5793-4B14-995B-A99FDC46676D@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

  I just tagged 2.11.56 in lustre master development branch.

  Here?s the changelog:

Alex Zhuravlev (4):
      LU-11128 ptlrpc: new request vs disconnect race
      LU-11164 ldlm: pass env to lvbo methods
      LU-11420 mdt: export mdt_dom_read_open_fops
      LU-11375 mdc: use old statfs format

Alexander Boyko (3):
      LU-11392 llog: fix race llog_process_thread vs llog_add
      LU-10806 target: skip discard for a missing obt_lut
      LU-10595 mgc: don't proccess cld during stopping

Alexey Lyashkov (2):
      LU-11020 osd: use right sync
      LU-11169 obdclass: fix old return code usage

Andreas Dilger (12):
      LU-11016 obdclass: change JobID error into warning
      LU-11303 out: clean up osp_update_rpc_pack() macro
      LU-10899 obdclass: remove unused ll_import_cachep
      LU-11128 ptlrpc: add debugging for idle connections
      LU-11329 utils: add get_maintainer.pl script
      LU-6864 mdc: move RPC semaphore code to lustre/osp
      LU-11237 build: delete obsolete slapd-lustre.conf
      LU-8616 utils: document specific MDT index selection
      LU-8174 misc: name open file handles as such
      LU-11111 lfsck: print correct parent FID
      LU-10899 osc: move obdo_cache to OSC code
      LU-11397 idl: remove obsolete RPC flags

Arshad Hussain (2):
      LU-6142 obdclass: Fix style issues for obd_sysfs.c
      LU-6142 osd-ldiskfs: Fix style issues for osd_iam_lvar.c

Bobi Jam (1):
      LU-11400 flr: add 'nosync' flag for FLR mirrors

Gu Zheng (1):
      LU-11436 build: always dist debian stuff

Hongchao Zhang (1):
      LU-11281 ptlrpc: race in AT early reply

James Nunez (4):
      LU-9268 tests: check obj distribution for PFL striping
      LU-11010 tests: remove calls to return after skip()
      LU-11349 tests: remove insanity test 15
      LU-11381 tests: sanity-flr 201 skip information

James Simmons (13):
      LU-8066 llite: move /proc/fs/lustre/llite/stats_track* to  sysfs
      LU-8066 llite: move /proc/fs/lustre/llite/statahead_{max, agl} to sysfs
      LU-8066 ofd: migrate from proc to sysfs
      LU-11071 build: create lustre resource package for Ubuntu
      LU-8066 llite: move /proc/fs/lustre/llite/lazystatfs to sysfs
      LU-8066 llite: move /proc/fs/lustre/llite/*_easize to sysfs
      LU-8066 llite: move /proc/fs/lustre/llite/xattr_cache to sysfs
      LU-10030 clio: don't use spare bits in iattr.ia_valid
      LU-10906 llite: create checksums to replace checksum_pages
      LU-11424 lnet: copy the correct amount of cpts to lnet_cpts
      LU-8066 llite: move remaining single item proc files to sysfs
      LU-11058 test: reenable sanity 77k test
      LU-7004 tests: move from lctl conf_param to lctl set_param -P

Jian Yu (2):
      LU-10660 mdt: revoke lease lock for truncate
      LU-11412 kernel: kernel update [SLES12 SP3 4.4.155-94.50]

John L. Hammond (3):
      LU-11268 mdc: use smaller buffers for getxattr
      LU-11380 llite: zero lum for stripeless files
      LU-11364 osd: remove unused 'ignore quota' parameters

Lai Siyao (4):
      LU-4684 migrate: migrate striped directory
      LU-4684 migrate: shrink dir layout after migration
      LU-11301 target: add lock in sub_trans_stop_cb()
      LU-4684 lmv: support accessing migrating directory

Li Dongyang (4):
      LU-11071 ldiskfs: fix ldiskfs patch for ubuntu18
      LU-11360 osd-ldiskfs: hold s_umount before calling sync_fs
      LU-11187 ldiskfs: don't mark mmp buffer head dirty
      LU-11368 build: link the shared libraries properly

Mikhail Pershin (4):
      LU-10177 lfs: support DOM-to-OST migration
      LU-11414 ptlrpc: don't change buffer when signature is ready
      LU-11287 ldlm: update l_blocking_lock under lock
      LU-11388 test: disable replay-single test_131b

Nathaniel Clark (1):
      LU-11455 build: Remove conflicting lustre and Lustre

NeilBrown (5):
      LU-8066 llite: use more private data in dump_pgcache
      LU-8130 ptlrpc: convert conn_hash to rhashtable
      LU-8066 llite: remove redundant lookup in dump_pgcache
      LU-8066 llite: change how "dump_page_cache" walks a hash table
      LU-6202 libcfs: replace libcfs_register_ioctl with a blocking notifier_chain

Nikitas Angelinas (1):
      LU-930 doc: update data_version command in lfs man page

Oleg Drokin (2):
      Revert "LU-11058 test: reenable sanity 77k test"
      New tag 2.11.56

Ryan Haasken (1):
      LU-5026 obdclass: Add lbug_on_eviction option

Sebastien Piechurski (1):
      LU-11133 dkms: Add missing ldiskfs module in dkms config

Sonia Sharma (5):
      LU-10124 lnet: Correctly add peer MR value while importing
      LU-11372 o2iblnd: add clarifying comment to ko2iblnd.conf
      LU-10772 utils: incorrect check in build_layout_from_yaml_node
      LU-11370 lnet: cleanup ni_cptlist
      LU-11422 lnet: Fix selftest backward compatibility post health

Vladimir Saveliev (1):
      LU-11441 obdclass: make mod rpc slot wait queue FIFO

Wang Shilong (4):
      LU-11165 llite: set iflags and catch error from md_setattr() properly
      LU-11373 libcfs: fix wrong check in libcfs_debug_vmsg2()
      LU-11198 utils: propagate errors for read_param
      LU-11451 utils: fix to dump usage messages to stdout

Yang Sheng (1):
      LU-9966 tests: sanity-411 check LBUG direct

frank zago (1):
      LU-6081 user: adding llapi_create_volatile_param()
