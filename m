From: Oleg Drokin <oleg.drokin@intel.com>
Date: Tue, 9 Aug 2016 12:05:39 -0400
Subject: [lustre-devel] new tag 2.8.56
Message-ID: <6A773ABD-94D9-4EC0-B766-2B5773ADE662@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

  I just tagged a new 2.8.56 tag in Lustre community master branch.

  Here's the changelog:
d23c130 New tag 2.8.56
3f2b093 LU-8323 tests: Fix interop for set_hostid
c3e03f3 LU-7712 mdd: migration is too noisy
7509d5f LU-8056 xattr: update server code for POSIX xattr rename
703ebd8 LU-8401 lnet: remove dependency on OFED headers from lnet
1136148 LU-8257 utils: fix mtab symlink logic
7a4001e LU-8427 build: clear file lustre-tests.files
01a1de2 LU-8426 rpmbuild: fix build with option "--without lustre_utils"
97d11e8 LU-8041 tests: rename sanity test 39p to 39q
7b5f76e LU-937 tests: fix CLIENTONLY mode for KNL testing
2458067 LU-8311 mount: fix lmd_parse() to parse colon as NID delimiter
349c2be LU-7863 osd-zfs: dmu_prefetch change in ZFS master
3973c51 LU-7442 tests: Load modules on MDS/OSS in conf-sanity test_41c
63ef1b3 LU-8399 osp: direct reference object to be invalidate
0f9fa51 Revert "LU-7845 lnet: check if address is visible"
3061a7c LU-7988 hsm: remove hsd.request_sz from struct hsm_scan_data
0804103 LU-8352 libcfs: Migrate file_inode() wrapper to lustre layer
a93ede1 LU-8320 llog: prevent llog ID re-use.
9bb5a2f LU-7429 tests: generate dangling name entry properly
7bdee09 LU-6622 tests: reduce chance of stat timeout in lnet-selftest
008b5ff LU-8056 lprocfs: treat seq_printf as void function
e1cf0bd LU-8394 tests: exportfs unexport failure can be ignored
e2462a1 LU-6888 osp: check return value in osp_update_request_create()
cf62f53 LU-7043 test: skip conf-sanity test_86
dd30f31 LU-7311 osd: quotactl_ops has changed in kernel 3.19
0eee95c LU-7311 osd: ext4_bread has one less parameter in kernel 3.18
542e21f LU-6135 lustreapi: allow specific-OST with llapi_layout
098a19e LU-8356 osp: wakeup osp_precreate_reserve on umount
52a465c LU-7939 osd-ldiskfs: check IS_ERR() instead of NULL
4f2a80a LU-7342 test: test_85a: unused locks error
aa1a240 LU-4825 osp: check max_create_count before use OSP
0f37c05 Revert "LU-7782 scrub: handle slave obj of striped directory"
f0ed14d LU-8389 kernel: kernel update RHEL6.8 [2.6.32-642.3.1.el6]
faa958d LU-8055 ldev: Introduced role filtering
1ce1032 LU-8357 nodemap: reclassify nodemap requires active conf lock
5546521 LU-8354 ldlm: soft lockup in ldlm_plain_compat_queue
fb5a79b LU-8297 obd: release MGC device if connect fails
63d146d LU-8058 lustre: Remove old commented out code
7af958a LU-8056 llite: POSIX_ACL_XATTR_{ACCESS,DEFAULT} removed in 4.5
b18132d LU-7839 nodemap: add a flag to deny access to unmapped users
2112bc0 LU-5814 lov: remove unused code
b2ee26b LU-7645 build: Remove unused --with-release configure option
7b57a7c LU-8386 zfs: Use ZFS_MAXPROPLEN instead of ZFS_MAXNAMELEN
28c17d4 LU-7643 build: Remove Linux version string from RPM release field
9f0a592 LU-7648 man: new man pages for LFSCK commands
1f2bb41 LU-7836 ptlrpc: remove duplicate final ping req
29f9761 LU-8337 kernel: kernel update [SLES12 SP1 3.12.59-60.41]
ba78196 LU-8065 utils: clarify lctl help messages
bfca833 LU-5560 tests: add sanity-selinux.sh
d61ab8d LU-8369 nodemap: ignore loopback NID when classifying
9d84696 LU-8372 llite: Fix suspicious dereference of pointer 'vma->vm_file'
6490222 LU-8368 gnilnd: Use kgnilnd_vzalloc() to avoid stalls
a04d586 LU-8360 llite: check return value for obd_set_info_async
0706879 LU-8328 tests: cleanup system after conf-sanity test_86
8ac2c18 LU-8321 kernel: kernel update RHEL7.2 [3.10.0-327.22.2.el7]
b399a2d LU-7429 tests: inject lfsck failure properly
80a9ca6 LU-7914 obdclass: Removed unused reference of cl_page_list_own()
881e4d6 LU-8298 sec: remove obsolete sec_level parameter
3ecdedd LU-8251 tests: Delete only test files for sanityn
f371db9 LU-8117 build: fix lustre-ppc64 build on el7
ddcade9 LU-7099 lnet: lock improvement for ko2iblnd
e8e440b LU-8056 llite: inode_operations interface changed in 4.5
2c7da05 LU-8056 llite: use inode_lock to access i_mutex
11e4f77 LU-8056 socklnd: NETIF_F_ALL_CSUM renamed to NETIF_F_CSUM_MASK
86068ab LU-6401 headers: Move object_update functions to new header
501fc25 LU-8113 build: Remove obsolete, unused meta packages
53d2f41 LU-6696 llog: improve error handling
77ae71b LU-8021 tests: In interop, ensure to save/restore correct debug flags
2ad5491 LU-7961 build: Fix ldiskfs source autodetect for CentOS 6
6cd79ab LU-7899 osd: batch EA updates
b2d6651 LU-7900 obdclass: lu_object_assign_fid() do not lookup
226fd40 LU-7660 dne: support fs default stripe
80fe81c LU-7782 scrub: handle slave obj of striped directory
57b8058 LU-7845 lnet: check if address is visible
4c0dcdf LU-7674 lmv: remove unused placement parameter
8385143 LU-7619 obdclass: protect REFASSERT() with lu_ref::lf_guard
ac5a9c8 LU-1095 lod: quiet "wanted N, found M" console message
db5156e LU-4739 obd: Fixing code inconsistencies and coding style
698bd21 LU-6429 tests: fix typo in previous patch
98f2f46 LU-8284 osd-ldiskfs: i_size updates from BRW should be atomic
5f08d03 LU-8199 ptlrpc: better lut_reply_bitmap handling
52d4d48 LU-7234 mgs: For handling dash in FSNAME
5e5daba LU-8353 mdt: mdt unlink should lock before lookup
f77c82e LU-8343 build: fix kmod_version on SLES 12
4c066a6 LU-8319 fid: fix race in fid allocation
80a3eb5 LU-8377 build: clean up .rpmmacros
95dbe2c LU-4039 tests: EXCEPT replay-single test 90
4af430d Revert "LU-7334 lov: Cleanup lov_stripe proc files"
c86a1a5 LU-8055 ldev: Add %H and %b to command sub
364bd1d LU-8055 ldev: File system label filtering
87e1428 LU-7317 tests: Called the error function where it was missing.
5b729ad LU-8331 kernel: kernel update [SLES11 SP4 3.0.101-77]
36451f3 LU-8316 tgt: return -ENOMEM while kmalloc failed
0d7022d LU-8270 ptlrpc: correct use of list_add_tail()
87c5e1c LU-8056 lloop: fix bio_for_each_segment_all for newer kernels
2fc4838 LU-7334 lprocfs: Allow default multiplier of 1
2fbec0f LU-8174 llite: restore fd_och when putting lease
31d6445 LU-8056 o2iblnd: ib_query_device removed in 4.5
2f52eda LU-8003 llite: remove obsolete code and comments
219e0a6 LU-6401 obdclass: make get/set_wire_obdo non-inline
ca646b1 LU-3105 llite: Remove unused lli_open_count from ll_inode_info
62713a8 LU-5282 mdc: fix panic at mdc_free_open()
743f742 LU-7931 tests: setup/cleanup after every test script
abf0e13 LU-8303 lnet: make connection more stable with packet loss
0a0f9f7 LU-6215 build: announce linux kernel 4.4.6 support
d6f305f LU-8125 nrs: pol_arg should be copied after the policy starts
ba16220 LU-7623 lnet: remove useless cast
e827855 LU-8022 lnet: Correct position of lnet_ni_decref()
eb2657a LU-4039 tests: ensure osc import in FULL state
23fde1f LU-7759 llite: handle inactive OSTs better in statfs
0e4e1f6 LU-8259 osd-ldiskfs update all *_seq_write() to use "const char __user *buffer"
b384b41 LU-8176 libcfs: Add file_dentry() & file_inode() wrapper
f3ce48c LU-8197 ptlrpc: do not reduce replay request deadline
3a5db1d LU-8159 osd-ldiskfs: cache xattr in osd-ldiskfs
3be9beb LU-7702 ldlm: skip lock if export failed
3b7d27e LU-5614 build: use %kernel_module_package in rpm spec
a84250b LU-7418 tests: avoid background writeout in sanity 29
d700bd7 Revert "LU-5810 tests: add client hostname to lctl mark"
9560e01 LU-7542 obdclass: quiet lockdep recursive lock warning
d34b9df LU-7334 lov: Cleanup lov_stripe proc files
5b04696 LU-8203 tests: Wait for archive operation to be completed.
829ccf4 LU-8058 lnet: Remove old commented out code
6c2bbc0 LU-8150 mdt: Track open+create as mknod
941bd1f LU-8116 build: Fix libmount configure message
f3d42a7 LU-7896: do not call lu_site_purge() for single object exceed
a7d8aa2 LU-7664 test: set_conf_param_and_check() defect
ffe234a LU-5092 nodemap: remove nodemap_idx_action, only act on MGS
dd6623e LU-7403 obd: const correct md_set_lock_data()
e9d2e7d LU-8216 ldiskfs: fix journal quota files for RHEL6.8
91a2331 LU-8220 tests: stripe file over all active OSTs
47b7b31 LU-8106 lnet: Do not drop message when shutting down LNet
5908965 LU-7861 osp: replace the hot spinlock with atomic trackers
a186ede LU-7204 test: handle FSNAME with dashes in replay-single 85b
ef50ce8 LU-7301 test: do cleanup only if required
36e5b72 LU-8040 mgc: Apply changelog defaults values in  mdd_init0()
