From: Oleg Drokin <oleg.drokin@intel.com>
Date: Mon, 12 Jun 2017 18:39:43 -0400
Subject: [lustre-devel] New tag 2.9.59
Message-ID: <1C93B8CA-9BA3-4A07-AA10-109BE98F5FBD@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   I just tagged 2.9.59 in lustre community tree master branch.

   Here's the changelog:

Alex Zhuravlev (2):
      LU-9333 osd: few cleanups to support gcc6
      LU-9288 tests: t-f to check if ZFS module is loaded

Amir Shehata (4):
      LU-9448 lnet: handle empty CPTs
      LU-9549 lnet: prevent assert on ln_state
      LU-9536 lnet: set LND tunalbes properly
      LU-9119 lnet: increment per NI stats

Andreas Dilger (3):
      LU-9090 ofd: increase default OST BRW size to 4MB
      LU-930 doc: improve mount.lustre.8 option descriptions
      LU-930 doc: remove llapi_layout_t from man pages

Andrew Perepechko (1):
      LU-9413 llite: llite.stat_blocksize param for fixed st_blksize

Arnd Bergmann (1):
      LU-4423 libcfs: remove CFS_TIME_T definition

Ben Evans (2):
      LU-9523 obdclass: remove CL_PAGE_INVOKE et. al.
      LU-9575 obdclass: remove cl_for_each defines

Bob Glossman (5):
      LU-9459 kernel: kernel update [SLES12 SP2 4.4.59-92.17]
      LU-9503  kernel: kernel update [SLES11 SP4 3.0.101-100]
      LU-9539 kernel: kernel update [SLES12 SP1 3.12.74-60.64.40]
      LU-9561 kernel: kernel update RHEL7.3 [3.10.0-514.21.1.el7]
      LU-9572 kernel: kernel update RHEL6.9 [2.6.32-696.3.1.el6]

Bobi Jam (5):
      LU-9229 osc: osc page lru list race
      LU-9489 lod: keep minimum LOVEA size
      LU-9486 llapi-test: sanity test_27D failure
      LU-9484 llite: eat -EEXIST on setting trunsted.lov
      LU-9367 llite: restore ll_file_getstripe in ll_lov_setstripe

Bruno Faccini (1):
      LU-4640 mdt: implement Remove Archive on Last Unlink policy

Chris Hanna (1):
      LU-8989 tests: fix sanity test_256() use of hardcoded filename

Dmitry Eremin (4):
      LU-9183 ptlrpc: handle posix_acl: xattr representation cleanups
      LU-8964 libcfs: Introduce parallel tasks framework
      LU-8964 clio: Parallelize generic I/O
      LU-8703 libcfs: make tolerant to offline CPUs and empty NUMA nodes

Doug Oucharek (1):
      LU-9507 lnd: Don't Assert On Reconnect with MultiQP

Elena Gryaznova (2):
      LU-7088 tests: merge sanityn test_1[a-d] into test_1
      LU-6900 tests: parallel-scale-nfs improvement

Emoly Liu (2):
      LU-9463 utils: print lcme_flags in text format
      LU-9550 adio: delete the old Lustre ADIO driver patches

Fan Yong (4):
      LU-9560 tests: sanity test_801a sleeps more time
      LU-9440 osd-ldiskfs: efficient way to get ldiskfs backend name
      LU-9488 scrub: reset noslot for full speed scrub
      LU-9433 osd-ldiskfs: fix inode reference leak

Frank Zago (1):
      LU-7988 hsm: change the cdt event flags to a simple boolean

Giuseppe Di Natale (2):
      LU-9526 spec: Improve systemd compat in spec file
      LU-9439 scripts: Provide a sample lnet.conf file

Gregoire Pichon (1):
      LU-9533 tests: fix get_lustre_version in obdfilter-survey

James Nunez (2):
      LU-6707 tests: Add ability to skip tests in POSIX
      LU-9384 tests: restore 2.9 filesystem images on 2.10

James Simmons (7):
      LU-9397 ksocklnd: move remaining time handling to 64 bits
      LU-9137 utils: replace readdir_r with readdir
      LU-9558 llite: generic_readlink is no longer exported
      LU-6401 uapi: change lustre_cfg.h into a proper UAPI header
      LU-9558 libcfs: handle hotplug state machine
      LU-9019 libcfs: remove no longer use time abstraction
      LU-8661 libcfs: handle pdata_set_cpumasks() removal

Jian Yu (2):
      LU-9487 tests: stop primary and failover services in mmp test 1
      LU-9556 tests: wait recovery complete in replay-single test 57

Jinshan Xiong (1):
      LU-9485 test: revert a change from LU-5361

John L. Hammond (3):
      LU-9312 hsm: convert cdt_llog_lock to a rw semaphore
      LU-9338 hsm: cache agent record locations
      LU-9010 ldlm: use static initializer macros where possible

Nathaniel Clark (6):
      LU-2049 grant: Fix grant interop with pre-GRANT_PARAM clients
      LU-2049 tests: Add GRANT_CHECK_LIST to sanity
      LU-8797 lbuild: Fail build if zfs or spl git checkout fails
      LU-4378 wireshark: Add parsing for HSM commands
      LU-6582 wireshark: Add new LDLM intent bits
      LU-6648 wireshark: Process ldlm intent getxattr

Niu Yawei (8):
      LU-8998 tools: parse optional argument properly
      LU-9513 liblustre: always check return value
      LU-9371 tools: handle component options properly
      LU-9424 tools: v1/v3 as composite layout
      LU-9449 tools: component add to no stripe info file
      LU-9490 llite: return v1/v3 layout for legacy app
      LU-9470 osc: update timestamps on write only
      LU-9490 tests: ll_dirstripe_verify handles PFL layout

Oleg Drokin (2):
      Revert "LU-8359 ldlm: Wrong evict during failover"
      New tag 2.9.59

Parinay Kondekar (1):
      LU-9521 tests: Avoid cleanup() being called twice.

Patrick Farrell (1):
      LU-8656 vvp: Add S_NOSEC support

Prakash Surya (1):
      LU-9439 scripts: Change behavior of lustre_rmmod

Qian Yingjin (1):
      LU-9140 nrs: calculate the measured rate according to dd runtime

Quentin Bouget (2):
      LU-9482 hsm: release restore lock without object (part2)
      LU-7884 utils: mkfs prevents the creation of files in /dev/shm

Robin Humble (1):
      LU-9562 llite: Remove filtering of seclabel xattr

Sebastien Buisson (2):
      LU-8956 llite: set sec ctx on client's inode at create time
      LU-9289 nodemap: fix fileset string length issue

Sonia (2):
      LU-8576 test: Fix hard-coded NETTYPE in test-framework.sh
      LU-9603 test: Fix  test-framework.sh

Steve Guminski (1):
      LU-6210 utils: Use C99 struct initializers in lfs_setstripe()

Yang Sheng (3):
      LU-8364 ldiskfs: fixes for failover mode for RHEL7.3
      LU-9384 ldiskfs: port extra isize patches to sles12sp2
      LU-9384 ldiskfs: extra patch for changing extra isize
