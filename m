From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Wed, 11 May 2016 02:52:02 +0000
Subject: [lustre-devel] New tag 2.8.53
Message-ID: <710856DE-D1A6-4C66-8303-C1B51C9465EF@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   I just tagged 2.8.53 in Lustre master branch, this also includes saity-hsm rhel7 fix that John was talking about earlier today, so now is a good time to rebase if you did not yet.

   Here's the changelog:
Alex Zhuravlev (3):
      LU-7902 osd: no need to set same [acm]time
      LU-7521 ldlm: LDLM_DEBUG() shouldn't be passed \n
      LU-7904 osd: honor LOC_F_NEW

Alexander Boyko (1):
      LU-6722 ldiskfs: fix credits at ldiskfs_delete_inode

Andreas Dilger (3):
      LU-7746 tests: some fixes for sanity.sh with upstream kernel
      LU-6215 llite: remove obsolete conditional code
      LU-6844 tests: disable DNE testing of dbench

Andrew Perepechko (1):
      LU-8059 ldiskfs: wrong ldiskfs patch

Andriy Skulysh (1):
      LU-7791 ldlm: signal vs CP callback race

Artem Blagodarenko (1):
      LU-7592 osd-ldiskfs: increase supported ldiskfs fs size limit

Ashley Pittman (1):
      LU-7835 checkpatch: Update gerrit_checkpatch for new features.

Bob Glossman (3):
      LU-8024 kernel: kernel update [SLES12 SP1 3.12.57-60.35]
      LU-8052 test: stop using unknonwn sed option
      LU-7957 kernel: kernel update [SLES11 SP4 3.0.101-71]

Bobi Jam (1):
      LU-7198 clio: remove mtime check in vvp_io_fault_start()

Bruno Faccini (2):
      LU-7973 llite: lock i_lock/dcache_lock before __d_drop()
      LU-7980 ldiskfs: always pre-allocate max depth for path

Christopher J. Morrone (5):
      LU-7699 build: Convert lustre_ver.h.in into a static .h file
      LU-5725 ofd: Expose OFD site_stats through proc
      LU-7699 build: Convert version underscores to dashes for dpkg
      LU-8072 build: Restore module debuginfo
      LU-8073 build: Eliminate lustre-source binary package

Dmitry Eremin (4):
      LU-7998 utils: fix fd lost
      LU-7937 utils: Fix NULL pointer dereference
      LU-8023 lbuild: add find-requires parameter to rpmbuild
      LU-7999 utils: fix double free the pointer

Elena Gryaznova (1):
      LU-7435 test: managing OST pools properly

Emoly Liu (2):
      LU-7972 tests: use $REFORMAT in test-framework.sh correctly
      LU-8064 lctl: fix a typo in lustre_cfg.c

Fan Yong (2):
      LU-5070 utils: mkfs.lustre code cleanup
      LU-5070 osd-zfs: get object's FID from its LMA EA

Frank Zago (1):
      LU-8014 hsm: remove kuc_ispayload

Herbert Xu (1):
      LU-4423 libcfs: use ahash for libcfs crypto layer

Hongchao Zhang (1):
      LU-7851 mdt: skip SOM related configuration

James Simmons (4):
      LU-6245 libcfs: replace CFS_MODULE_PARAM with linux kernel module api
      LU-6245 libcfs: remove sysctl module handling
      LU-6245 libcfs: Remove kp30.h
      LU-8017 obd: report correct health state of a node

Jian Yu (1):
      LU-8015 utils: fix lr_link() to get correct src and dest

Jinshan Xiong (3):
      LU-7990 ofd: add a parameter to adjust preferred brw size
      LU-8005 osc: set lock data for readahead lock
      LU-7990 clio: revise readahead to support 16MB IO

John L. Hammond (6):
      LU-7992 hsm: close KUC pipe before unregistering
      LU-7986 hsm: update actions llog in place
      LU-7402 llite: correct request handling after ll_lookup_it()
      LU-7403 llite: flatten struct lookup_intent
      LU-7152 hsm: sync volatile file before setting times
      LU-6937 test: use ps in get_agent_uuid()

Kirtankumar Krishna Shetty (1):
      LU-8051 tests: Skipping sanity tests 300[a-d] for old servers.

Kit Westneat (1):
      LU-8001 nodemap: fix null deref when reclassifying

Kyrylo Shatskyy (1):
      LU-7130 test: sanity/162 doesn't handle DIR values properly

Li Dongyang (3):
      LU-6215 gss: key->payload.data is an array in 4.4+ kernels
      LU-6215 o2iblnd: ib_alloc_fast_reg_mr() removed in 4.3
      LU-6215 o2iblnd: rdma_create_id() takes extra parameter

Li Xi (1):
      LU-7982 libcfs: memory allocation without CPT for binheap

Lokesh Nagappa Jaliminche (1):
      LU-7922 ldiskfs: correction in ext4_kzalloc

Mel Gorman (1):
      LU-4423 mem: remove GFP_IOFS

Mikhal Pershin (1):
      LU-7558 import: don't reconnect during connect interpret

Nathaniel Clark (1):
      LU-7859 tests: Use getent instead of /etc/passwd

Oleg Drokin (3):
      Revert "LU-7434 ptlrpc: lost bulk leads to a hang"
      Revert "LU-7791 ldlm: signal vs CP callback race"
      New tag 2.8.53

Parinay Kondekar (4):
      LU-7110 tests: sanity-hsm.sh can erase all files on filesystem
      LU-7121 tests: Extra items shown in the stack trace in t-f
      LU-7323 test: Unknown symbol mb_cache_create (err 0)" on RHEL7
      LU-6512 llite:ll_dir_ioctl cleanup of redundant comparisons

Patrick Farrell (1):
      LU-7981 llite: take trunc_sem only at vvp layer

Tatsushi Takamura (1):
      LU-8009 utils: Lustre_rsync does not sync files on MDT1

Vitaly Fertman (2):
      LU-7434 ptlrpc: lost bulk leads to a hang
      LU-7434 ptlrpc: Early Reply vs Reply MDunlink

Wang Shilong (1):
      LU-8037 fileset: reject dotdot as a path component

Yang Sheng (3):
      LU-1118 llite: Invoke file_update_time in page_mkwrite
      LU-6601 tests: test case validate OSP status op
      LU-8038 tests: test case for lfs migrate --block
