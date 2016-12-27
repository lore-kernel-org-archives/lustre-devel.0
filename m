From: Oleg Drokin <oleg.drokin@intel.com>
Date: Tue, 27 Dec 2016 18:10:27 -0500
Subject: [lustre-devel] New tag 2.9.51
Message-ID: <3782A05D-FA82-4CBA-8936-E9E1A0EEEEF4@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   I just tagged 2.9.51 in Lustre master development branch,
   this hosts a bunch of backlogged features and other such patches that
   have been waiting since 2.9.0 was feature and code frozen.

   Here's the changelog:
Alex Zhuravlev (2):
      LU-6838 llog: limit file size of plain logs
      LU-8367 osp: do not block orphan cleanup

Andreas Dilger (6):
      LU-8590 utils: remove duplicate code in lgss_sk
      LU-8813 gss: allow svcgssd to start without "-k"
      LU-8619 lbuild: update ZFS to use 0.6.5.8
      LU-8920 utils: don't print deactivated OSTs in "lfs df"
      LU-8901 misc: update Intel copyright messages for 2016
      LU-3425 utils: rename l_getgroups.8 to l_getidentity.8

Arshad Hussain (3):
      LU-8586 test: Fix failure due to mixed OST size.
      LU-8596 tests: lnet-selftest test failed.
      LU-7952 osp: Move strlen() call below LASSERT()

Bhagyesh Dudhediya (1):
      LU-8627 test: wait on MDS for ost-pool proc entry to update

Bob Glossman (1):
      LU-8925 kernel: kernel update RHEL7.3 [3.10.0-514.2.2.el7]

Bruno Faccini (3):
      LU-6449 hsm: handle completions with non-existent objects
      LU-6449 mdt: correct status and ChangeLogs for dead objects
      LU-8295 tests: comply with OBD_RACE() behavior

Chennaiah Palla (1):
      LU-8640 tests: relax time check of sanity-hsm test_16

Dmitry Eremin (5):
      LU-8703 libcfs: fix error messages
      LU-8789 build: add files to .gitignore
      LU-8790 test: Limit lock number by available inodes count
      LU-8887 ptlrpc: remove unused pc->pc_env
      LU-8890 ptlrpc: fix module_param in ptlrpcd.c

Emoly Liu (2):
      LU-8809 osp: print more opd_pre information in LASSERTF()
      LU-8793 tests: add version check to conf-sanity.sh test_99

Fan Yong (3):
      LU-8740 lfsck: hold lock when access trace file object
      LU-8810 tests: skip non-crucial LFSCK intermediateness check
      LU-8886 lfsck: handle -ENODATA for the end of iteration

Frank Zago (1):
      LU-7988 hsm: don't use a ptlrpc_thread struct for the cdt

Henri Doreau (2):
      LU-7264 mdd: refactor changelog handling for XATTR ops
      LU-8906 mdd: Return rc in mdd_local_file_create()

Jadhav Vikram (1):
      LU-8684 mgs: prevent duplicate pool to be added to the log

James Nunez (1):
      LU-8832 tests: Generalize check of virtual machine

James Simmons (4):
      LU-6142 lnet: change lnet selftest UAPI typedefs to proper structure
      LU-8836 lprocfs: move lprocfs_stats_[un]lock to a source file
      LU-8844 llite: delete lloop
      LU-6142 socklnd: change UAPI typedefs to proper structure

Jinshan Xiong (1):
      LU-4423 lov: check return value of lov_sub_get()

John L. Hammond (5):
      LU-8403 obd: remove OBD_NOTIFY_CREATE
      LU-7714 osd: propagate errors in osd_objset_open()
      LU-8739 test: disable DNE in racer for old MDSs
      LU-8846 lfs: try to unlink volatile file in lfs_migrate()
      LU-8811 mdc: avoid returning freed request

Liang Zhen (1):
      LU-8867 ksocklnd: ignore timedout TX on closing connection

Lokesh Nagappa Jaliminche (1):
      LU-8364 ldiskfs: fixes for failover mode.

Niu Yawei (6):
      LU-8491 quota: sleep while holding spinlock
      LU-8801 quota: fix ldiskfs accounting iterator
      LU-8826 recovery: don't shrink recovery hard time
      LU-8197 ptlrpc: set correct rq_timeout for normal replay reply
      LU-6374 tests: wait for zfs commit
      LU-8807 llite: check reply status in ll_migrate()

Oleg Drokin (4):
      LU-8538 tests: Silence conf-sanity 63 on debug kernel
      LU-7765 tests: Fix replay-dual test_26 stderr redirection
      LU-8972 tests: Disable conf-sanity test 101
      New tag 2.9.51

Patrick Farrell (3):
      LU-8272 ldlm: Use interval tree to update kms
      LU-8515 osc: Send RPCs when extents are full
      LU-8842 mdc: Make IT_OPEN take lookup bits lock

Sebastien Buisson (3):
      LU-7845 gss: support namespace in lgss_keyring
      LU-7845 obd: add 'network' client mount option
      LU-8305 tests: fix fileset setup in sanity-sec

Sebastien Piechurski (1):
      LU-7735 utils: Allow revert of NO_PRIMNODE

Sergey Cheremencev (1):
      LU-8562 osp: fix precreate_cleanup_orphans/precreate_reserve race

Steve Guminski (4):
      LU-6210 libcfs: Change positional struct initializers to C99
      LU-8847 tests: llapi_fid_test uses incorrect parameters
      LU-8776 build: Fix weird inline definitions
      LU-8724 utils: Use open() instead of opendir() with dirfd()

Thomas Stibor (1):
      LU-8869 build: Fix building of DEB packages

Vladimir Saveliev (1):
      LU-8351 ptlrpc: allow blocking asts to be delayed

Wei Liu (1):
      LU-7605 test: Skip sanityn test_78


Bye,
    Oleg
