From: Oleg Drokin <oleg.drokin@intel.com>
Date: Thu, 1 Sep 2016 13:34:35 -0400
Subject: [lustre-devel] New tag 2.8.57
Message-ID: <0D37BAC2-63FA-4527-8295-8F5A95BE14D3@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   I just tagged 2.8.57 in community master branch.

   Here's the changelog:

Aditya Pandit (1):
      LU-7472 tests: Allows to specify IOR block size with suffix

Andreas Dilger (2):
      LU-8248 tests: fix sanity test_248 VM checks
      LU-8480 ofd: hold obd_dev_lock across grant comparison

Artem Blagodarenko (1):
      LU-7160 mgs: Skip processing .bak files on MGS

Ben Evans (1):
      LU-6401 headers: Move functions out of lustre_idl.h

Bob Glossman (3):
      LU-7732 ldlm: silence verbose "waking for gap" log messages
      LU-8468 kernel: kernel update RHEL7.2 [3.10.0-327.28.2.el7]
      LU-8495 kernel: kernel update [SLES11 SP4 3.0.101-80]

Bobi Jam (1):
      LU-8460 osc: max_pages_per_rpc should be chunk size aligned

Bruno Faccini (1):
      LU-6449 mdt: broadcast orphan hsm_remove requests

Di Wang (3):
      LU-7800 llog: check if next llog exists
      LU-8493 osp: Do not set stale for new osp obj
      LU-6844 tests: re-enable striped dir

Dmitry Eremin (2):
      LU-8383 build: Spec file cleanup after LU-5614
      LU-8383 build: Spec file cleanup after LU-5614

Doug Oucharek (3):
      LU-7646 lnet: Stop Infinite CON RACE Condition
      LU-8285 test: Allow LNet logging as default in autotest
      LU-7977 lnet: Have selftest use proper units (MB/s or MiB/s)

Elena Gryaznova (1):
      LU-8415 tests: customise MPIRUN

Fan Yong (5):
      LU-7117 osp: set ptlrpc_request::rq_allow_replay properly
      LU-8083 lfsck: repair symbol file nlink properly
      LU-8085 scrub: increase iteration cursor to skip unused inodes
      LU-4433 tests: fix mds-survey.sh to support multiple MDTs
      LU-8084 lfsck: handle linkea record length properly

Frank Zago (4):
      LU-7988 hsm: Fix possible out of bounds reference in message
      LU-7988 hsm: only browse entries of hsd.request when needed
      LU-7988 hsm: remove compound_id from mdt_hsm_add_actions proto
      LU-8471 obdclass: restore EXPORT_SYMBOL for lu_ref* functions

James Simmons (5):
      LU-6688 tests: use proper nodes for NRS test
      LU-6245 client: remove types abstraction from client code
      LU-7650 o2iblnd: handle mixed page size configurations.
      LU-8056 mem: handle GFP_IOFS removal in newer kernels
      LU-8056 build: announce linux kernel 4.5.7 support

Jeremy Filizetti (1):
      LU-3289 gss: Fix for SK bulk HMACs

Jian Yu (2):
      LU-8473 tests: skip conf-sanity test 41a with separate MGT and MDT
      LU-8474 tests: stop MGS before setup_noconfig in conf-sanity.sh

Jinshan Xiong (1):
      LU-4865 zfs: grow block size by write pattern

John L. Hammond (2):
      LU-7669 lmv: assume a real connection in lmv_connect()
      LU-5560 security: send file security context for creates

Kirtankumar Krishna Shetty (1):
      LU-7528 test: Deregister changelog client on test fail.

Kit Westneat (5):
      LU-8287 nodemap: don't stop config lock when target stops
      LU-5092 nodemap: save nodemaps to targets for caching
      LU-8436 nodemap: MGS local MGC should not get_config
      LU-7061 osd-ldiskfs: NULL pointer in osd_scrub_refresh_mapping
      LU-8258 nodemap: fix userspace address access in proc code

Lai Siyao (4):
      LU-8370 dne: error in spliting update records
      LU-8314 utils: revert lfs_getdirstripe to non-recursive mode
      LU-8454 llite: normal user can't set FS default stripe
      LU-8523 test: sanity 311 is too strict

Li Xi (2):
      LU-4931 ladvise: Add willread advice support for ladvise
      LU-8006 ptlrpc: specify ordering of TBF policy rules

Lokesh Nagappa Jaliminche (1):
      LU-7613 llite: changes to avoid cache corruption

Niu Yawei (1):
      LU-7903 hsm: leaked export refcount

Oleg Drokin (6):
      LU-8371 llite: optimize atomic_open of negative dentry.
      LU-6447 mdt: mdt_identity_upcall to not block with rwlock held
      Revert "LU-8383 build: Spec file cleanup after LU-5614"
      Revert "LU-7899 osd: batch EA updates"
      LU-8371 llite: Trust creates in revalidate too.
      New tag 2.8.57

Patrick Farrell (1):
      LU-7225 llite: ladvise protocol changes

Quentin Bouget (1):
      LU-8249 lnet: potential deadlock in lnet

Saurabh Tandan (2):
      LU-2805 tests: sanity -Remove test_184c from Always Except
      LU-7483 tests: sanity test_103a misc test in acl corrected

Sebastien Buisson (2):
      LU-8305 tests: add traces for sanity-sec
      LU-7845 lnet: check if ni is in current net namespace

Wang Shilong (1):
      LU-8387 test: fix check in sanity test_129

Yang Sheng (2):
      LU-4039 tests: enable test_90 for replay-single
      LU-8479 obdclass: Reserve some value for OBD_FAIL_* macros

frank zago (1):
      LU-7311 osd: smp_mb__before_clear_bit deprecated since kernel 3.16
