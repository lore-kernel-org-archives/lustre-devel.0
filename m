From: Oleg Drokin <oleg.drokin@intel.com>
Date: Fri, 7 Oct 2016 17:43:53 -0400
Subject: [lustre-devel] New tag 2.8.59
Message-ID: <9502AD2F-AED9-4EEE-A177-B979413B7075@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

  I just tagged a new tag in master branch of community development tree.

  Here's the changelog:

Alex Zhuravlev (1):
      LU-8619 osd: define DN_MAX_BONUSLEN

Alexander Boyko (1):
      LU-6910 osp: add procfs values for OST reserved size

Andreas Dilger (5):
      LU-8599 utils: restore lshowmount utility
      LU-4315 doc: split lctl-network.8 man page from lctl.8
      LU-3888 utils: print lmm_fid as part of getstripe
      LU-3289 gss: don't build SSK if libssl-1.0+ not available
      LU-4931 doc: update ladvise man page

Andrew Perepechko (1):
      LU-8509 llite: drop_caches hangs in cl_inode_fini()

Arshad Hussain (1):
      LU-7949 osd: Move assignment below LASSERT()

Artem Blagodarenko (1):
      LU-4474 osd: Add nodelalloc to ldiskfs mount options

Bob Glossman (1):
      LU-8615 kernel: kernel update RHEL7.2 [3.10.0-327.36.1.el7]

Bobi Jam (3):
      LU-8018 lov: ld_target could be NULL
      LU-8413 llite: specify READA debug mask for sanity_101f
      LU-4185 llite: Revise create with no open optimization

Chennaiah Palla (1):
      LU-8625 tests: replay-single test_87 renamed to test_87a

Christopher J. Morrone (1):
      LU-8529 config: Print clear message when ldiskfs series not found

Dmitry Eremin (2):
      LU-5050 libcfs: default CPT matches NUMA topology
      LU-8632 osc: remove of usage removed 'page_count' local variable

Emoly Liu (1):
      LU-8021 tests: Add leading $ to "DEBUGSAVE_SERVER"

Fan Yong (6):
      LU-8218 osd: handle stale OI mapping for non-restore case
      LU-8300 lfsck: pass LOC_F_NEW when create new object
      LU-8301 lfsck: handle ROOT fid properly
      LU-8472 scrub: try to avoid recovery during OI scrub
      LU-8579 osd-ldiskfs: code cleanup for osd_ldiskfs_add_entry
      LU-8637 obdclass: LWP callback hold export reference

Giuseppe Di Natale (1):
      LU-8100 tests: Test the correctness of target_obd

Hongchao Zhang (2):
      LU-7428 test: remove test 84 from ALWAYS_EXCEPT
      LU-8544 test: using lfs df in client_up

James Simmons (6):
      LU-6142 lnet: replace white spaces with tabs for LNet core
      LU-6245 server: remove types abstraction from lfsck and OSS code
      LU-6245 server: remove types abstraction from MDS/MGS code
      LU-6245 libcfs: remove byteorder.h
      LU-6245 server: remove types abstraction from quota/target/nodemap code
      LU-6401 header: remove assert from interval_set()

Jinshan Xiong (2):
      LU-8135 osc: limits the number of chunks in write RPC
      LU-8561 osd-zfs: make smatch happy

John L. Hammond (1):
      LU-6638 test: wait for grace delay in sanity-hsm test_37()

Kit Westneat (2):
      LU-8499 wireshark: fix packet-lustre so it compiles
      LU-8340 tests: in sanity-sec 25 client nodemap must be admin

Lai Siyao (3):
      LU-8454 mountconf: delay FS default stripe config setting
      LU-8581 osd: misuse of RCU in osd xattr cache
      LU-8612 mdt: maintain Sync-on-Lock-Cancel locks per target

Li Xi (2):
      LU-8551 test: Use mds1 rather than mds to operate on MDT0000
      LU-8549 test: optimize restore_and_check_size() in sanity-hsm

Liang Zhen (1):
      LU-5718 lnet: add offset for selftest brw

Nathaniel Clark (2):
      LU-5473 tests: sanity/51b Account for ZFS inode size
      LU-4444 test: Re-enable conf-sanity/69 for ZFS

Niu Yawei (1):
      LU-8446 llite: clear inode timestamps after losing UPDATE lock

Oleg Drokin (1):
      New tag 2.8.59

Rahul Deshmkuh (1):
      LU-8535 lod: RR policy should not allocate on same ost

Sandhya Bankar (1):
      LU-8629 obdclass: Fix error exit loop in cl_env_percpu_init

Saurabh Tandan (1):
      LU-8547 test: Skip ost-pools test_24 for older MDS version

Yang Sheng (1):
      LU-8327 ldiskfs: release bh in make_indexed_dir
