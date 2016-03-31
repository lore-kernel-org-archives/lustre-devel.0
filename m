From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Thu, 31 Mar 2016 02:46:33 +0000
Subject: [lustre-devel] new tag 2.8.51
Message-ID: <893BD51C-BEAE-4E96-88F3-D51EAC1C28E8@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

    I just tagged master branch with new version tag 2.8.51
    This also will work as a test for changes to the build system discussed in LU-7699

    Here's the changelog:
Alex Zhuravlev (5):
      LU-7680 mdd: put migrated object on the orphan list
      LU-7579 mdd: do not mark object as an orphan early
      LU-7713 osd: osd-zfs should serialize destroy vs. others
      LU-7704 utils: check LOOP_CTL_GET_FREE aginst target kernel
      LU-7038 obdclass: lu_site_purge() to handle purge-all

Alyona Romanenko (1):
      LU-7774 lnet: issue in the offset in hash table

Andreas Dilger (4):
      LU-7437 utils: continue on errors in lctl {get,set}_param
      LU-6389 utils: fix lustre_rsync read retry
      LU-7581 ldiskfs: RHEL7.2 fix wrong EA inode backpointer check
      LU-7812 tests: print more stats for sanity 120e failure

Andriy Skulysh (2):
      LU-6304 ldlm: crash on umount in cleanup_resource
      LU-7829 osc: glimpse lock should match only with granted locks

Ben Evans (2):
      LU-7724 mdd: create mdd_changelog_on and _off functions
      LU-6401 headers:  Create a header for obdo related functions

Bob Glossman (7):
      LU-7764 kernel: kernel update RHEL 6.7 [2.6.32-573.18.1.el6]
      LU-6757 ldiskfs: large EA support
      LU-7781 kernel: kernel update RHEL7.2 [3.10.0-327.10.1.el7]
      LU-7608 kernel: kernel upgrade [SLES12 SP1 3.12.51-60.25]
      LU-7818 kernel: kernel update [SLES12 SP1 3.12.53-60.30]
      LU-7841 doc: stop using python-docutils
      LU-5704 utils: stop open hangs on fifo files

Bruno Faccini (1):
      LU-4640 mdt: implement Remove Archive on Last Unlink policy

Christopher J. Morrone (3):
      LU-7518 build: Remove the Phi accelerator-specific packaging
      LU-7699 build: Replace version_tag.pl with LUSTRE-VERSION-GEN
      LU-6862 build: Make dist of contrib's contents consistent

Chuck Fossen (1):
      LU-7850 gnilnd: Fix niov calculation with offset kiov

Cristina Moraru (1):
      LU-4423 lnet: Don't ignore error code for lst_group_info_ioctl

Di Wang (6):
      LU-7579 osd: move ORPHAN/DEAD flag to OSD
      LU-7778 osd: check if the object is destroyed
      LU-7825 mdt: release parent lock correctly for rename
      LU-7815 mdt: pinger should not evict MDT-MDT export
      LU-7768 fld: Do not retry fld request
      LU-7782 osp: save env for update callback

Dmitry Eremin (2):
      LU-5783 o2iblnd: Add Fast Reg memory registration support
      LU-7124 o2iblnd: limit cap.max_send_wr for MLX5

Doug Oucharek (1):
      Revert "LU-7646 o2iblnd: connrace protocol improvement"

Fan Yong (2):
      LU-7256 tests: wait current LFSCK to exit before next test
      LU-7828 statahead: set sai_index_wait with lli_sa_lock held

Frederic Saunier (2):
      LU-7002 utils: SELinux context repeated in mount opts
      LU-7003 utils: must quote the value of the context option

Gregoire Pichon (2):
      LU-7736 scripts: ensure lustre_rmmod unload all modules
      LU-7756 oss: allow larger number of OSS service threads

Jadhav Vikram (1):
      LU-7627 tests: parse filefrag output correctly

James Simmons (3):
      LU-6245 libcfs: remove types.h from userland code
      LU-6245 libcfs: remove typedefs in libcfs source code
      LU-6245 libcfs: remove cfs_fs_time handling

Jinshan Xiong (1):
      LU-5505 clio: revise read ahead algorithm

Johann Lombardi (1):
      LU-2049 grant: add support for OBD_CONNECT_GRANT_PARAM

John L. Hammond (1):
      LU-7799 hsm: use correct record start index for actions

Kirtankumar Krishna Shetty (1):
      LU-3782 test: Fix for faliure when no file are created.

Kit Westneat (1):
      LU-5092 nodemap: save id maps to targets in new index file

Li Dongyang (5):
      LU-7689 obdclass: limit lu_site hash table size on clients
      LU-7727 mdt: fail FMODE_WRITE open if the client is read only
      LU-6215 gss: cache_head is now on a hlist in 4.3+ kernels
      LU-6215 llite: handle locks API change in 4.4+ kernels
      LU-6215 llite: make_request_fn returns blk_qc_t in kernel 4.4

Lokesh Nagappa Jaliminche (2):
      LU-7786 tests: improve racer cleanup
      LU-6966 test: Dash in FSNAME causes warning in testframework

Matthew Tyler (1):
      LU-4423 libcfs: Merge linux-proc.c into module.c

Niu Yawei (1):
      LU-7707 quota: put qqi reference after all things done

Noopur Maheshwari (1):
      LU-7524 fld: fld_clientlookup retries next target

Olaf Faaland (1):
      LU-7893 osd-zfs: calls dmu_objset_disown() with NULL

Oleg Drokin (5):
      LU-7766 lnet: Don't call roundup_pow_of_two on zero in LNetEQAlloc
      Revert "LU-4640 mdt: implement Remove Archive on Last Unlink policy"
      Revert "LU-6245 libcfs: remove cfs_fs_time handling"
      LU-7931 tests: Allow per-subtest setup/cleanup
      New tag 2.8.51

Sergey Cheremencev (1):
      LU-7227 tests: check dmesg for errors after test

Shraddha Barke (2):
      LU-4423 libcfs: remove some unused code and wrappers in libcfs
      LU-4423 lnet: Drop unnecessary wrapper function in lnetselftest console.c

Wally Wang (1):
      LU-6391 llite: Add client mount opt to ignore suppress_pings

Wei Liu (1):
      LU-7024 tests: Skip squash_id if server version is older than 2.5.53

Yang Sheng (4):
      LU-7151 tests: fix sanity test_205 on SLES12
      LU-7084 mem: code cleanup for memory allocation
      LU-6527 ldiskfs: Journal commit callback optimization
      LU-7883 llog: Flush out journal callback data

vinayakswami hariharmath (1):
      LU-7718 utils: lfs getstripe does not work on bind mount
