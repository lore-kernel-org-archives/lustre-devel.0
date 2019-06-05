From: Oleg Drokin <green@whamcloud.com>
Date: Wed, 5 Jun 2019 06:41:26 +0000
Subject: [lustre-devel] New tag 2.12.54
Message-ID: <45C1AB6D-E8F5-4F50-9921-CC00C237BC67@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

 I just tagged 2.12.54 in lustre development branch.

Here?s the changelog:

Alex Zhuravlev (7):
      LU-11233 build: support for gcc8
      LU-2233 tests: improve tests sanityn/40-47
      LU-10754 tests: sanityn/47b to sleep for 1s
      LU-12013 lfsck: use correct buffer
      LU-11233 utils: fix build warnings for gcc8
      LU-11233 tests: fix gcc8 build warnings
      LU-12034 obdclass: put all service's env on the list

Alexander Boyko (1):
      LU-12140 lnet: adds checking msg len

Amir Shehata (1):
      LU-12279 lnet: use number of wrs to calculate CQEs

Andreas Dilger (3):
      LU-12159 utils: improve lfs getname functionality
      LU-11233 utils: fix double-free of params fields
      LU-10602 utils: fix file heat support

Andrew Perepechko (2):
      LU-6951 tests: sanity test_27m failure
      LU-12352 libcfs: crashes with certain cpu part numbers

Andriy Skulysh (3):
      LU-12218 ptlrpc: Bulk assertion fails on -ENOMEM
      LU-11090 quota: Oops in qsd_config
      LU-12095 ptlrpc: ocd_connect_flags are wrong during reconnect

Ann Koehler (1):
      LU-12221 statahead: sa_handle_callback get lli_sa_lock earlier

Arshad Hussain (12):
      LU-9010 ptlrpc: Change static defines to use macro for gss_krb5_mech.c
      LU-6142 ldlm: Fix style issues for interval_tree.c
      LU-6142 ptlrpc: Fix style issues for sec_null.c
      LU-6142 ptlrpc: Fix style issues for service.c
      LU-12314 tests: Add Missing Description to sanity test 258a
      LU-6142 ldlm: Fix style issues for ldlm_resource.c
      LU-6142 ptlrpc: Fix style issues for sec_plain.c
      LU-6142 ptlrpc: Fix style issues for sec_gc.c
      LU-6142 ptlrpc: Fix style issues for sec.c
      LU-6142 ptlrpc: Fix style issues for client.c
      LU-6142 ptlrpc: Fix style issues for llog_client.c
      LU-6142 ldlm: Fix style issues for ldlm_plain.c

Artem Blagodarenko (2):
      LU-12335 ldiskfs: fixed size preallocation table
      LU-12345 ldiskfs: optimize nodelalloc mode

Aurelien Degremont (2):
      LU-12227 scripts: check for mounted ZFS devices too
      LU-12236 gss: remove unused code in gss_svc_upcall.c

Ben Menadue (3):
      LU-12269 build: fix hardened builds in rpm spec file
      LU-12269 build: remove %{fullrelease} from Provides
      LU-12269 build: add value to definition of with_gss in spec

Bruno Faccini (2):
      LU-11376 lov: new foreign LOV format
      LU-11376 lmv: new foreign LMV format

Chris Horn (3):
      LU-12302 lnet: Fix NI status in proc for loopback ni
      LU-12333 ptlrpc: Add more flags to DEBUG_REQ_FLAGS macro
      LU-12323 libcfs: check if save_stack_trace_tsk is exported

Dmitry Eremin (1):
      LU-8066 ptlrpc: move sptlrpc procfs entry to debugfs

G?tz Waschk (1):
      LU-12342 spec: mark lsvcgss as a config file in the rpm

Hongchao Zhang (1):
      LU-12232 test: commit before df

James Nunez (1):
      LU-9581 tests: remove recovery-small test from ALWAYS_EXCEPT

James Simmons (5):
      LU-11803 obd: replace class_uuid with linux kernel version.
      LU-11157 obd: round values to nearest MiB for *_mb syfs files
      LU-11771 ldlm: use hrtimer for recovery to fix timeout messages
      LU-11893 ksocklnd: add secondary IP address handling
      LU-11893 o2iblnd: add secondary IP address handling

Jian Yu (5):
      LU-12276 lnet: check const parameters for ib_post_send and ib_post_recv
      LU-12139 kernel: kernel update [SLES12 SP3 4.4.176-94.88]
      LU-12242 kernel: kernel update RHEL7.6 [3.10.0-957.12.1.el7]
      LU-12269 kernel: new kernel [RHEL 8.0 4.18.0-80.el8]
      LU-12306 kernel: kernel update RHEL7.6 [3.10.0-957.12.2.el7]

Lai Siyao (2):
      LU-11907 dne: allow access to striped dir with broken layout
      LU-11213 dne: add new dir hash type "space"

Li Dongyang (7):
      LU-11838 lnet: getname dropping addrlen argument
      LU-12248 lov: fix ost objects calculation in lod_statfs
      LU-12093 osc: don't check capability for every page
      LU-11838 osp: atomic64_read() returns s64
      LU-11838 ldlm: struct timespec64.tv_sec type change
      LU-11838 llite: address_space ->page_tree renamed ->i_pages
      LU-12270 o2iblnd: pci_unmap_addr() removed in 4.19

Mikhail Pershin (5):
      LU-12212 mdt: fix SECCTX reply buffer handling
      LU-11359 mdt: fix mdt_dom_discard_data() timeouts
      LU-10894 dom: per-resource ELC for WRITE lock enqueue
      LU-10894 dom: mdc_lock_flush() improvement
      LU-12120 grants: prevent negative ted_grant value

Minh Diep (2):
      LU-12282 build: export IB_OPTIONS before build
      LU-11041 kernel: Enable tons of kernel debug options

Nathaniel Clark (3):
      Revert "LU-8384 scripts: Add scripts to systemd for EL7"
      LU-12298 init: Add init info to lustre sysvinit script
      LU-12309 osd-zfs: Support disabled project quotas

NeilBrown (6):
      LU-8066 obd: embed typ_kobj in obd_type
      LU-11089 obdclass: remove locking from lu_context_exit()
      LU-11838: lnet: remove lnet_ipif_enumerate()
      LU-11089 obd: use wait_event_var() in lu_context_key_degister()
      LU-11089 obd: remove lock from key register/degister
      LU-10467 ptlrpc: discard SVC_SIGNAL and related functions

Olaf Faaland (2):
      LU-11946 build: no zlib check during configure --enable-dist
      LU-11946 build: no yaml check during configure --enable-dist

Oleg Drokin (6):
      LU-12263 build: push depreciation of LMV_HASH_FLAG_DEAD to 2.12.55
      LU-12324 mdd: Do not record xattr size get in changelogs
      LU-10948 llite: Revalidate dentries in ll_intent_file_open
      LU-11623 llite: hash just created files if lock allows
      LU-12341 tests: Add kmemleak awareness to test-framework
      New tag 2.12.54

Patrick Farrell (7):
      LU-9846 obd: Add overstriping CONNECT flag
      LU-11403 tests: Fix $tfile usage
      LU-11690 lod: fix LBUG with wide striping
      LU-10754 tests: Clear mdc locks before tests
      LU-9846 lod: Add overstriping support
      LU-12350 tests: Do not use background failover
      LU-11963 osd: Add nonrotational flag to statfs

Qian Yingjin (1):
      LU-11526 rpc: support maximum 64MB I/O RPC

Sebastien Buisson (5):
      LU-12131 tests: only create lgssc.conf file if necessary
      LU-12266 mdd: fix up non-dir creation in SGID dirs
      LU-12098 mdd: explicitly clear changelogs on deregister
      LU-12131 tests: fix SSK handling in tests
      LU-12267 tests: update filter in acl for SElinux case

Sergey Cheremencev (1):
      LU-11760 ofd: formatted OST recognition change

Thomas Stibor (1):
      LU-12019 build: Recognize Debian Kernel and set KMP dir

Vitaly Fertman (1):
      LU-11251 mdt: ASSERTION (req_transno < next_transno) failed

Vladimir Saveliev (1):
      LU-12206 mdt: mdt_init0 failure handling

Wang Shilong (6):
      LU-12043 llite, readahead: fix to call ll_ras_enter() properly
      LU-12225 obdclass: fix race access vs removal of jobid_hash
      LU-12225 obdclass: improve jobid memory reclaim policy
      LU-12299 libcfs: fix panic for too large cpu partions
      LU-11872 utils: don't follow link files in default
      LU-12361 lov: fix wrong calculated length for fiemap

Yang Sheng (1):
      LU-11851 ldiskfs: reschedule for htree thread.
