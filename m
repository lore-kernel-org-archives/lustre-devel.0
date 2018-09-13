From: Oleg Drokin <green@whamcloud.com>
Date: Thu, 13 Sep 2018 04:54:14 +0000
Subject: [lustre-devel] New tag 2.11.55
Message-ID: <7C1C845D-AF5A-4E46-84CD-AB88446BD229@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

  I just tagged 2.11.55 in the Lustre community  development branch. Here?s the changelog:

Alex Zhuravlev (5):
      LU-11175 osc: serialize access to idle_timeout vs cleanup
      LU-8215 tests: sanity-benchmark/iozone should wait for space recovery
      LU-11096 osd: wrap new blk integrity stuff
      LU-10018 protocol: MDT as a statfs proxy
      LU-11282 osd-zfs: drop cache immediately

Alexander Boyko (1):
      LU-11116 llog: error handling cleanup

Amir Shehata (33):
      LU-9120 lnet: refactor lnet_select_pathway()
      LU-9120 lnet: add health value per ni
      LU-9120 lnet: add lnet_health_sensitivity
      LU-9120 lnet: add monitor thread
      LU-9120 lnet: handle local ni failure
      LU-9120 lnet: handle o2iblnd tx failure
      LU-9120 lnet: handle socklnd tx failure
      LU-9120 lnet: handle remote errors in LNet
      LU-9120 lnet: add retry count
      LU-9120 lnet: calculate the lnd timeout
      LU-9120 lnet: sysfs functions for module params
      LU-9120 lnet: timeout delayed REPLYs and ACKs
      LU-9120 lnet: remove duplicate timeout mechanism
      LU-9120 lnet: handle fatal device error
      LU-9120 lnet: reset health value
      LU-9120 lnet: add health statistics
      LU-9120 lnet: Add ioctl to get health stats
      LU-9120 lnet: remove obsolete health functions
      LU-9120 lnet: set retry count from lnetctl
      LU-9120 lnet: set transaction timeout from lnetctl
      LU-9120 lnet: set health sensitivity from lnetctl
      LU-9120 lnet: show local ni health stats
      LU-9120 lnet: show peer ni health stats
      LU-9120 lnet: set health value from user space
      LU-9120 lnet: add global health statistics
      LU-9120 lnet: print recovery queues content
      LU-9120 lnet: health error simulation
      LU-9120 lnet: LNet Health/Resiliency Feature
      LU-11271 lnd: conditionally set health status
      LU-11272 lnet: router handling
      LU-11273 lnet: update logging
      LU-11283 lnet: fix setting health value manually
      LU-11309 lnd: Clean up logging

Andreas Dilger (6):
      LU-8066 lov: fix lov.*.stripeoffset printing
      LU-11040 utils: improve mount usage/man page
      LU-8066 tests: don't access /proc/sys/lnet/debug directly
      LU-10740 tests: disable tests for replay-dne-zfs-part-4
      LU-11012 doc: improve the lfs-setstripe.1 man page
      LU-10447 build: fix checkpatch.pl to not mangle case

Andriy Skulysh (1):
      LU-11135 mdt: LASSERT(lu_object_exists(o)) fails

Ann Koehler (1):
      LU-11195 lod: Mark comps cached on replay of layout change

Arshad Hussain (7):
      LU-6142 osd-ldiskfs: Fix style issues for osd_iam_lfix.c
      LU-6142 obdclass: Fix style issues for acl.c
      LU-6142 osd-ldiskfs: Fix style issues for osd_handler.c
      LU-6142 obdclass: Fix style issues for statfs_pack.c
      LU-6142 obdclass: Fix style issues for lustre_peer.c
      LU-6142 obdclass: Fix style issues for lustre_handles.c
      LU-6142 obdclass: Fix style issues for lu_ref.c

Aya Mahfouz (1):
      LU-9855 include: replace OBD_CHECK_DEV by obd_check_dev

Bobi Jam (5):
      LU-11226 flr: mirror resync regression
      LU-11238 lod: refine obj avoid collect for FLR
      LU-11212 lod: preserve mirror ID on mirror extension
      LU-8708 osc: enable/disable OSC grant shrink
      LU-11245 flr: lfs mirror dump command

Chris Horn (1):
      LU-11240 gnilnd: Replace KGNILND_BUILD_REV

Emoly Liu (1):
      LU-11110 ofd: remove obdfilter.*.* symlinks in few releases

Hongchao Zhang (1):
      LU-11056 lwp: fix lwp reconnection issue

James Nunez (1):
      LU-10686 tests: stop running sanity-pfl test 9

James Simmons (10):
      LU-9325 ptlrpc: replace simple_strtol with kstrtol
      LU-11224 obd: use correct ip_compute_csum() version
      LU-8066 lod: migrate from proc to sysfs
      LU-11200 libcfs: handle DECLARE_TIMER reduced to two arguments
      LU-8066 llite: move /proc/fs/lustre/llite/uuid to sysfs
      LU-10824 llite: don't use ll_mnt to get fstype name
      LU-10365 tests: set proper paths headers for sanity test 400a
      LU-9855 obdclass: simplify md_stats code
      LU-8130 libcfs: prepare rhashtable support
      LU-8066 llite: move /proc/fs/lustre/llite/checksum_pages to sysfs

Jian Yu (1):
      LU-11255 kernel: kernel update [SLES12 SP3 4.4.143-94.47]

Jinshan Xiong (1):
      LU-11244 build: apply IB_OPTIONS to debian rules

John L. Hammond (5):
      LU-11014 mdc: remove obsolete intent opcodes
      LU-4256 test: add lustre-rsync-test 2b to ALWAYS_EXCEPT
      LU-10855 llog: use llog_common_cat_ops
      LU-11259 test: correct fail_loc names in replay-{single,dual}
      LU-11075 ldlm: correct logic in ldlm_prepare_lru_list()

Lai Siyao (1):
      LU-11201 lfsck: check linkea entry validity

Li Dongyang (2):
      LU-11215 tests: replace "large_xattr" with "ea_inode"
      LU-11328 ldlm: fix compile problem with --disable-lru-size

Mikhail Pershin (5):
      LU-10509 mdd: don't set size attr for DOM file
      LU-11125 ofd: decrease message level
      LU-11275 llite: check truncate race for DOM pages
      LU-11270 mdt: better DOM data discard
      LU-10961 ldlm: don't cancel DoM locks before replay

Mikhal Pershin (1):
      LU-11121 mdt: take discard lock at cleanup stage

Minh Diep (1):
      LU-11266 build: update changelog for Ubuntu

Nikitas Angelinas (1):
      LU-10818 obdecho: don't set ma_need in echo_attr_get_complex()

Oleg Drokin (3):
      LU-9120 lnet: LNet Health/Resiliency Feature
      Revert "LU-11057 tests: exercise 'network' client mount option"
      New tag 2.11.55

Robin Humble (1):
      LU-11227 lod: lod_sync: don't attempt sync to inactive targets

Sebastien Buisson (2):
      LU-11057 obd: check '-o network' and peer discovery conflict
      LU-11057 tests: exercise 'network' client mount option

Sonia Sharma (2):
      LU-10654 lnet: lnetctl doesn't error out on mistyped options
      LU-11006 lnet: fix show peer yaml tree with no peer

Wang Shilong (4):
      LU-11154 llite: use proper flags for FS_IOC_{FSSET,FSGET}XATTR
      LU-11146 lustre: fix setstripe for specific osts upon dir
      LU-11279 lod: reset ostlist properly in lod_get_default_lov_striping
      LU-11304 misc: update all url links to whamcloud

Wei Liu (1):
      LU-11009 test: add version check to test_102
