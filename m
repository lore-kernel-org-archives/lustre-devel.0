From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Tue, 9 Feb 2016 19:37:37 +0000
Subject: [lustre-devel] New tags, 2.8 codebase codefreeze,
	2.9 development branch start
Message-ID: <6973BB5C-98F6-4EEC-ADCA-9128A0E5F9C1@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   I just tagged 2.7.90 tag and that marks codefreeze in the 2.8 development branch that is also now split into b2_8 (changelog below).

   Master branch is now tagged as 2.8.50 and would start accepting 2.9-destined patches real soon now.

catAlex Zhuravlev (2):
      LU-7705 ldlm: make round_timeout() static
      LU-7703 mdd: linkea should be updated properly at migration

Alexander Boyko (1):
      LU-7443 llog: remove unused and empty llog

Andreas Dilger (1):
      LU-6587 obdclass: use OBD_FREE_LARGE with OBD_ALLOC_LARGE

Andrew Perepechko (1):
      LU-6020 gss: add lsvcgssd init.d wrapper

Bruno Faccini (1):
      LU-7679 build: strengthen lustre-dkms during on-target build

Christopher J. Morrone (1):
      LU-3953 build: Fix duplicate snmp directory packaging

Chuck Fossen (3):
      LU-7578 gnilnd: Add module parameter reg_fail_timeout
      LU-7578 gnilnd: Handle new return code in gni_mem_register()
      LU-7578 gnilnd: Return correct error on GNI_RC_ERROR_NOMEM

Di Wang (5):
      LU-7716 mdt: No is_subdir check for same dir rename
      LU-7715 out: fix err_serious in out_handle
      LU-7564 osp: Do not match the lock for OSP
      LU-7737 lod: not return -EIO during process updates log
      LU-7725 osp: get update reply from replied req

Fan Yong (1):
      LU-6684 lfsck: set the lfsck notify as interruptable

James Shimek (2):
      LU-7578 gnilnd: Revert max_immediate setting
      LU-7578 gnilnd: Modify allocator flags to prevent waiting

James Simmons (3):
      LU-6245 libcfs: make libcfs_ioctl.h and lnetctl.h uapi compliant
      LU-6245 libcfs: remove userland headers from libcfs.h
      LU-5030 util: migrate lctl params functions to use cfs_get_paths()

Jian Yu (2):
      LU-6824 ldiskfs: add dir htree growing warning patch
      LU-7584 tests: create file on single MDS in sanity test 129

John L. Hammond (1):
      LU-7576 llapi: use dirname() in opendir_parent()

Leonel Ochoa (1):
      LU-7468 tests: update maloo_upload.sh to create upload.tar.gz

Li Xi (1):
      LU-7229 hsm: relax time check of sanity-hsm test_60

Liang Zhen (1):
      LU-7646 o2iblnd: connrace protocol improvement

Nathaniel Clark (1):
      LU-6719 osd-zfs: Ignore EEXIST during object init

Niu Yawei (1):
      LU-7729 target: fix process_req_last_xid() return value

Oleg Drokin (7):
      LU-7623 Update obd iocontrol methods with __user attribute
      LU-7623 lmv: Properly mark lmv_fid2path uarg argment as __user
      LU-7623 lmv: Mark lmv_hsm_ct_register/unregister uarg as __user
      LU-7623 lnet: Properly declare lnet_ping() forward declaration
      LU-4423 socklnd: use kernel socket sockopt apis
      LU-7623 mdt: Match up prototype and definition of mdt_hsm_cdt_control_seq_write
      New tag 2.7.90

Richard Henwood (1):
      LU-3531 doc: update lfs migrate and mkdir documentation.

gaurav mahajan (1):
      LU-6225 test: test-framework does not cleanup for failed tests
