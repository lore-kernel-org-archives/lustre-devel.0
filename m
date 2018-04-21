From: Oleg Drokin <oleg.drokin@intel.com>
Date: Fri, 20 Apr 2018 23:42:29 -0400
Subject: [lustre-devel] New tag 2.11.51
Message-ID: <DBB7C9A0-4BF8-4C29-A158-620D1B829611@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   I just tagged 2.11.51 in Lustre master development branch.

   Here?s the changelog:
Alex Zhuravlev (2):
      LU-9273 tests: disable random I/O in replay-ost-single/5
      LU-10833 tests: missing sed command

Alexander Boyko (1):
      LU-10889 ptlrpc: update req timeout if resending happened

Alexey Lyashkov (1):
      LU-10877 lu: fix reference leak

Andreas Dilger (5):
      LU-10830 utils: fix create mode for lfs setstripe
      LU-10264 mdc: fix possible NULL pointer dereference
      LU-10698 obdclass: allow specifying complex jobids
      LU-10898 tests: disable failing conf-sanity test
      LU-1187 idl: remove obsolete directory split flags

Andriy Skulysh (2):
      LU-10643 ptlrpc: ptlrpc_register_bulk() LBUG on ENOMEM
      LU-10841 ldlm: ASSERTION(lock->l_granted_mode!=lock->l_req_mode)

Ann Koehler (1):
      LU-10649 llite: yield cpu after call to ll_agl_trigger

Ben Evans (3):
      LU-10629 lod: Clear OST pool with setstripe
      LU-4939 obdclass: llog_print params file
      LU-4939 tests: fix typo in sanity.sh

Bob Glossman (3):
      LU-10845 kernel: kernel update [SLES12 SP3 4.4.120-94.17]
      LU-10847 kernel update [SLES12 SP2 4.4.120-92.70]
      LU-10847 doc: fix broken ChangeLog

Bruno Faccini (1):
      LU-10826 ptlrpc: fix test_req_buffer_pressure behavior

Dmitry Eremin (1):
      LU-4423 obdclass: use workqueue for zombie management

Elena Gryaznova (1):
      LU-10834 tests: fix cleanup_77c() defect

Emoly Liu (2):
      LU-10703 nodemap: save and clear fileset correctly
      LU-8913 nodemap: fix nodemap range format '*@<net>' support

Fan Yong (5):
      LU-10761 osd-ldiskfs: not create REMOTE_PARENT_DIR on OST
      LU-10773 obdclass: yield cpu during changelog_block_trim_ext
      LU-10598 obdclass: ignore IGIF formatted last_id
      LU-10887 lfsck: offer shard's mode when re-create it
      LU-10732 tests: sanity-lfsck to reset speed limit

Hongchao Zhang (2):
      LU-8999 quota: fix issue of multiple call of seq start
      LU-10368 mdc: resend quotactl if needed

James Nunez (4):
      LU-10461 tests: call exit in the skip routine
      LU-9444 tests: replace SINGLEMDS1 with SINGLEMDS
      LU-10710 tests: fix run_write_disjoint line continuation
      LU-9586 tests: remove replay-dual 15c from ALWAYS_EXCEPT

James Simmons (3):
      LU-10752 build: fix rpm packaging issues for gss
      LU-10157 lnet: make LNET_MAX_IOV dependent on page size
      LU-10869 build: package configuration files for Ubuntu / Debian

Jian Yu (1):
      LU-10835 tests: unload dm-flakey module

Jinshan Xiong (1):
      LU-10779 llite: rename FSFILT_IOC_* to system flags

John L. Hammond (11):
      LU-10383 hsm: remove struct hsm_thread_data
      LU-10383 hsm: add action count to hsm scan data
      LU-10383 hsm: ignore compound_id
      LU-10541 llite: setxattr directly in ll_set_acl
      LU-10792 llite: remove unused parameters from md_{get,set}xattr()
      LU-10788 llite: pass flags through __vfs_setxattr()
      LU-10787 llite: correct removexattr detection
      LU-10785 llite: use xattr_handler name for ACLs
      LU-10819 o2ib: use splice in kiblnd_peer_connect_failed()
      LU-10912 mdc: use large xattr buffers for old servers
      LU-10699 hsm: remove struct hsm_compat_data_cb

Li Dongyang (2):
      LU-10560 mdt: remove extra headers from mdt_identity.c
      LU-10805 lnet: switch to module_param

Liang Zhen (2):
      LU-6032 ldlm: don't disable softirq for exp_rpc_lock
      LU-6032 obdclass: new wrapper to convert NID to string

Mike Marciniszyn (2):
      LU-10560 libcfs: Use kernel_write when appropriate
      LU-10560 libcfs: Fix inconsistent declaration for cfs_kernel_write()

Mikhail Pershin (1):
      LU-7420 echo: fix echo server to work with unified target

Minh Diep (1):
      LU-10566 test: fix nfs exports clean up

Nathaniel Clark (2):
      LU-9551 utils: add l_tunedisk to fix disk tunings
      LU-10901 build: Update ZFS/SPL to 0.7.8

Oleg Drokin (2):
      LU-10766 utils: Correct error handling in llapi_dir_create
      New tag 2.11.51

Patrick Farrell (1):
      LU-10776 osc: Do not request more than 2GiB grant

Qian Yingjin (1):
      LU-10802 nrs: mismatch problem for wildcard in jobid TBF

Steve Guminski (1):
      LU-5170 lfs: Standardize error messages in lfs_changelog()

Teddy Chan (1):
      LU-9658 ptlrpc: Add QoS for uid and gid in NRS-TBF

Vladimir Saveliev (1):
      LU-6632 mgs: dont remove EXCLUDE records on lctl replace_nids

Wang Shilong (3):
      LU-10837 ldiskfs: skip bitmap check if block bitmap is uninitialized
      LU-10795 quota: fix wrong skipping of reintegration
      LU-10859 ldiskfs: fix deadlock with heavy memory preassure

Yang Sheng (3):
      LU-10565 osd: bi_error, pagevec_init, PAGE_CACHE_SHIFT changes
      LU-10565 osd: unify interface for vfs
      LU-10565 osd: move ext4_tranfer_project to osd

dilip krishnagiri (2):
      LU-9592 tests: remove sanity-quota tests from ALWAYS_EXCEPT
      LU-9043 test: remove conf-sanity test 24a ALWAYS_EXCEPT
