From: Oleg Drokin <green@whamcloud.com>
Date: Fri, 25 Sep 2020 17:31:43 +0000
Subject: [lustre-devel] New tag 2.13.56
Message-ID: <7F35CD3A-3631-4DA2-B550-D9F512EC7BA5@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   I just tagged Lustre development branch with 2.13.56 tag. The changelog is below

Alex Zhuravlev (5):
      LU-13676 tools: awk script to find unique backtraces
      LU-13827 utils: ofd_access_batch to print top hot files
      LU-13918 lfs: let lfs mirror extend to use prefer flag
      LU-13921 utils: new output format for ofd_access_log_reader
      LU-13013 osd: do not count credits for mapped blocks

Alexander Boyko (2):
      LU-13617 tests: check client deadlock selinux
      LU-13608 out: don't return einprogress error

Alexander Zarochentsev (3):
      LU-13784 tests: allow QUOTA_TYPE to be set
      LU-13809 mdc: fix lovea for replay
      LU-13899 tgt: drop old epoch request

Alexey Lyashkov (1):
      LU-13645 ldlm: don't use a locks without l_ast_data

Amir Shehata (2):
      LU-13750 lnet: Fix peer add command
      LU-10360 mgc: Use IR for client->MDS/OST connections

Andreas Dilger (8):
      LU-13127 ptlrpc: don't require CONFIG_CRYPTO_CRC32
      LU-13687 llite: return -ENODATA if no default layout
      LU-10934 tests: increase timeout for sanityn test_51b
      LU-13127 ptlrpc: prefer crc32_le() over CryptoAPI
      LU-13314 utils: fix lfs find time calculation margin
      LU-12661 tests: skip sanity 817 for kernel 4.12+
      LU-13909 tests: get lustre_inode_cache count from sysfs
      LU-13019 tests: replace usleep in test scripts

Andrew Perepechko (1):
      LU-13935 ofd: object removal is not handled properly

Artem Blagodarenko (1):
      LU-13533 utils: ext4lazyinit should be disabled

Chris Horn (13):
      LU-13502 lnet: Add param to control response tracking
      LU-13502 lnet: Ensure LNet pings and pushes are always tracked
      LU-13712 lnet: Preferred NI logic breaks MR routing
      LU-13734 lnet: Allow duplicate nets in ip2nets syntax
      LU-13764 lnet: Clear lp_dc_error when discovery completes
      LU-13782 lnet: Have LNet routers monitor the ni_fatal flag
      LU-13736 lnet: Do not set preferred NI for MR peer
      LU-13836 lnet: Display correct route aliveness
      LU-13502 lnet: Conditionally attach rspt in LNetPut & LNetGet
      LU-13735 lnet: Loosen restrictions on LNet Health params
      LU-13896 lnet: Fix reference leak in lnet_select_pathway
      LU-13502 lnet: Add response tracking param to lnetctl
      LU-13605 lnet: Do not overwrite destination when routing

Elena Gryaznova (2):
      LU-13943 tests: load modules for list_nids getting
      LU-13944 tests: add ability to set clients parameters

Emoly Liu (1):
      LU-13910 mdt: 0 for success in mdt_path_current()

James Nunez (6):
      LU-13773 tests: use TESTLOG_PREFIX in run_one_logged
      LU-13773 tests: subscript failure propagation
      LU-1538 tests: standardize test script init ? parallel-scale
      LU-1538 tests: standardize test script init ? misc tests
      LU-13960 tests: correct usage of _var variable
      LU-1538 tests: standardize test script init ? full group

James Simmons (6):
      LU-13787 build: fix snmp / libcfs build order
      LU-13740 build: update changelog for ubuntu kernel
      LU-9325 fld: replace simple_strto* with kstr* functions
      LU-11986 lnet: don't read debugfs lnet stats when shutting down
      LU-6142 libcfs: remove last use of container_of0
      LU-13740 ldiskfs: add Ubuntu 20.04 LTS support

Jinshan Xiong (1):
      LU-11518 ldlm: control lru_size for extent lock

John L. Hammond (2):
      LU-13945 utils: add includes for copy_file_range()
      LU-13376 utils: add batching to ofd_access_log_reader

Lai Siyao (8):
      LU-13437 llite: pack parent FID in getattr
      LU-13700 test: increase sanity 230o/230p wait time
      LU-13791 sec: enable FS capabilities
      LU-13481 test: run sanity 33h with more files
      LU-13909 llite: prune invalid dentries
      LU-12295 mdd: don't LBUG() if dir nlink is wrong
      LU-13922 osd-ldiskfs: no need to add OI cache in readdir
      LU-11631 obdclass: nlink is not set in struct obdo

Lee Ochoa (1):
      LU-13969 - Updates to lustre-release yaml.sh

Li Dongyang (1):
      LU-13187 osd-ldiskfs: don't enforce max dir size limit on IAM objects

Mikhail Pershin (6):
      LU-13759 dom: lock cancel to drop pages
      LU-13759 test: make sanityn test_20 repeatable
      LU-13599 mdt: add test for rs_lock limit exceeding
      LU-13127 ptlrpc: avoid ISO C90 mixed declaration
      LU-10810 osd: implement lseek method in OSD
      LU-13763 osc: don't allow negative grants

Minh Diep (1):
      LU-13818 build: use libsnmp-dev instead of libsnmp30

Mr NeilBrown (26):
      LU-6142 socklnd: remove declarations of missing functions.
      LU-6142 lnet: discard unused lnet_print_hdr()
      LU-12678 lnet: clarify initialization of lpni_refcount
      LU-12275 sec: use memchr_inv() to check if page is zero.
      LU-6142 lustre: use init_wait(), not init_waitqueue_entry()
      LU-6142 obdclass: make obd_psdev static
      LU-6142 lov: make various lov_object.c function static.
      LU-6142 lmv: make various functions static.
      LU-9859 libcfs: rename CFS_TCD_TYPE_MAX to CFS_TCD_TYPE_CNT
      LU-9859 libcfs: don't save journal_info in dumplog thread.
      LU-11310 ldiskfs: Fix suse15/ext4-max-dir-size.patch
      LU-8522 tests: improve slabinfo accuracy when slub is used.
      LU-10428 lnet: call event handlers without res_lock
      LU-12780 osd: use native kthreads for scrub.
      LU-13903 tests: skip test_410 if modules weren't built
      LU-4671 tests: give multiop a chance to exit.
      LU-13359 quota: call rhashtable_lookup near params decl
      LU-6142 lov: don't use inline for operations functions.
      LU-6142 lustre: all rhashtable_params should be static.
      LU-8066 osc: restore cur_dirty_grant_bytes
      LU-13783 osc: handle removal of NR_UNSTABLE_NFS
      LU-13904 tests: don't assume echo_client is a module.
      LU-13902 config: add test for /usr/include/libiberty/
      LU-6142 lov: discard unused lov_dump_lmm* functions
      LU-6142 lov: guard against class_exp2obd() returning NULL.
      LU-6142 lustre: don't take spinlock to read a 'long'.

Nathaniel Clark (1):
      LU-13819 build: Update ZFS version to 0.8.4

Nikitas Angelinas (3):
      LU-13688 tests: remove duplicate HSM functions
      LU-13688 hsm: handle in-tree executed copytools correctly
      LU-13151 mdt: add parent FID to Changelog recordss

Oleg Drokin (2):
      LU-13931 Revert "LU-13688 hsm: handle in-tree executed copytools correctly"
      New tag 2.13.56

Patrick Farrell (1):
      LU-11518 osc: Do ELC on locks with no OSC object

Sebastien Buisson (5):
      LU-12275 sec: O_DIRECT for encrypted file
      LU-12275 sec: restrict fallocate on encrypted files
      LU-12275 sec: ldiskfs not aware of client-side encryption
      LU-12275 sec: encryption with different client PAGE_SIZE
      LU-12275 sec: verify dir is empty when setting enc policy

Sergey Cheremencev (6):
      LU-13359 quota: make used for pool correct
      LU-13686 utils: pool_add/remove error code fix
      LU-13810 tests: OST Pool Quotas with wide striping
      LU-12397 osp: always set opd_new_connection
      LU-13840 utils: --pool instead of -o with lfs setquota
      LU-13967 quota: change warning to cdebug

Sergey Gorenko (1):
      LU-13761 o2ib: Fix compilation with MOFED 5.1

Serguei Smirnov (2):
      LU-13790 socklnd: NID to interface mapping issues
      LU-12233 lnet: deadlock on LNet shutdown

Shaun Tancheff (3):
      LU-13742 llite: do not bypass selinux xattr handling
      LU-13940 llite: it_lock_bits should be bit-wise tested
      LU-13941 test: Restrict create_count to valid range

Vikentsi Lapa (1):
      LU-13718 tests: add LU numbers to skipped tests

Vitaly Fertman (5):
      LU-13645 ldlm: re-process ldlm lock cleanup
      LU-11518 ldlm: lru code cleanup
      LU-11518 ldlm: cancel LRU improvement
      LU-11518 ldlm: pool fixes
      LU-11518 ldlm: pool recalc forceful call

Wang Shilong (5):
      LU-13775 target: fix memory copy in tgt_pages2shortio()
      LU-13835 llite: reuse same cl_dio_aio for one IO
      LU-13846 llite: move iov iter forward by ourself
      LU-13733 llite: report client stats sumsq
      LU-13900 clio: don't call aio_complete() in lustre upon errors

Yang Sheng (1):
      LU-13915 ldiskfs: Avoid atomic operation while bitmap prefetch
