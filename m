From: Oleg Drokin <oleg.drokin@intel.com>
Date: Mon, 6 Jun 2016 21:47:12 -0400
Subject: [lustre-devel] New tag 2.8.54
Message-ID: <856050BA-DAD9-42BD-BFB8-EE7AEEB0486B@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   I just tagged a new tag, 2.8.54 in master branch of Lustre develompent tree.

   Here's the changelog:

Alex Zhuravlev (3):
      LU-7905 osd: pin OI objects
      LU-7906 osd: no blocksize on non-OST objects
      LU-7918 mdd: no need to declare attr_set at create

Andreas Dilger (4):
      LU-8139 tests: skip sanity test 101g until fix is landed
      LU-5810 tests: add client hostname to lctl mark
      LU-7352 tests: don't fail conf-sanity test_78 on ENOSPC
      LU-7352 tests: conf-sanity 78 don't check missing files

Andriy Skulysh (1):
      LU-7728 osp: soft lockup in osp_precreate_reserve()

Bob Glossman (6):
      LU-8094 ldlm: restore missing newlines
      LU-8093 kernel: kernel update RHEL 6.7 [2.6.32-573.26.1.el6]
      LU-7733 ptlrpc: print times in microseconds
      LU-8134 kernel: kernel update RHEL7.2 [3.10.0-327.18.2.el7]
      LU-8141 tests: fix for acl test
      LU-8126 kernel: new kernel RHEL 6.8 [2.6.32-642.el6]

Brian Behlendorf (1):
      LU-8068 osd-zfs: large dnode support

Bruno Faccini (4):
      LU-8010 mdt: fix orphan layout_lock cases for restore
      LU-7975 lod: fix delayed stripe error path & Client resend
      LU-4330 lnet: Allocate MEs and small MDs in own kmem_caches
      LU-8136 tests: allow CT to registers with all MDTs

Christopher J. Morrone (2):
      LU-8116 build: Shrink multi-line pclmulqdq warnings
      LU-8116 build: Cleanup GSS configure script messages

Di Wang (2):
      LU-8097 mdt: remove assertion for lock resent
      LU-7848 target: Do not fail MDT-MDT connection

Dmitry Eremin (1):
      LU-6215 lnet: split struct ib_send_wr

Doug Oucharek (1):
      LU-8022 lnet: Don't access NULL NI on failure path

Emoly Liu (2):
      LU-8098 doc: add "lfs mdts" to lfs main man page
      LU-8078 iokit: correct obdfilter-survey output data format

Fan Yong (6):
      LU-8127 lfsck: compile XATTR_NAME_LFSCK_NAMESPACE_OLD
      LU-8048 mgc: use the same lu_env for mgc_fs_{set,clean}up
      LU-8127 lfsck: remove XATTR_NAME_LFSCK_NAMESPACE_OLD
      LU-7888 obdclass: not hold global lock when lwp callback
      LU-8049 obdclass: use __BIG_ENDIAN to detect local endianness
      LU-8071 ldiskfs: handle system freeze protection

Frank Zago (2):
      LU-8014 hsm: remove invalid kuc_free in coordinator
      LU-8030 hsm: prevent duplicated HSM requests

Giuseppe Di Natale (2):
      LU-7334 lprocfs: Refactored string to value helpers
      LU-8100 lmv: Correctly generate target_obd

HemaHarish (1):
      LU-7469 test: add missing init to lustre-rsync-test:test_1a

Henri Doreau (1):
      LU-8079 llog: Remove llog_cat_init_and_process

James Nunez (1):
      LU-7667 tests: Write to unique files in $TMP

Jeremy Filizetti (1):
      LU-7185 ldlm: Restore connect flags on failure

Jinshan Xiong (3):
      LU-4257 obdclass: Get rid of cl_env hash table
      LU-4257 llite: fix up iov_iter implementation
      LU-4257 llite: fast read implementation

John L. Hammond (4):
      LU-8035 obd: rename md_getstatus() to md_get_root()
      LU-7403 llite: change it_data to it_request
      LU-7403 dlm: const qualify struct lustre_handle * params
      LU-4781 test: wait for dbench to stop

Kit Westneat (2):
      LU-5092 nodemap: users of ted_nodemap should take ref
      LU-5092 nodemap: transfer nodemaps between MGS, MDTs, and OSTs

Li Dongyang (1):
      LU-6215 o2iblnd: port to new fast reg API introduced in 4.4

Liang Zhen (1):
      LU-5050 libcfs: default CPT matches NUMA topology

Nathaniel Clark (3):
      LU-7870 osd-zfs: Build against SPL/ZFS 0.6.5.6
      LU-8155 tests: Fix timing of sanity-hsm/16
      LU-7134 utils: Ensure hostid set for ZFS during mkfs

Niu Yawei (4):
      LU-8041 mdd: increasing only atime update on close
      LU-8091 mount: error out properly in server_lsi2mti()
      LU-7795 quota: tuneable soft least qunit
      LU-8193 ptlrpc: set proper mbits for EINPROGRESS resend

Noopur Maheshwari (1):
      LU-7656 tests: tar fix for replay-single/70c

Oleg Drokin (2):
      Revert "LU-5050 libcfs: default CPT matches NUMA topology"
      New tag 2.8.54

Parinay Kondekar (2):
      LU-6518 obd: Unhandled possible allocation failure in lustre_start_mgc
      LU-7064 obd: detect errors from llog_declare_destroy()

Quentin Bouget (2):
      LU-8080 utils: Replace calls to signal with sigaction
      LU-8132 tests: do not truncate fsname from paths to ost/mdt

Saurabh Tandan (1):
      LU-7346 tests: Reintroduce SLOW tests to review process

Sebastien Buisson (2):
      LU-7846 nodemap: add fileset info to nodemap
      LU-7846 mdt: mount with fileset info from nodemap

Sergey Cheremencev (1):
      LU-7422 llite: don't panic when fid is insane

Wang Shilong (2):
      LU-8210 osd-ldiskfs: fix setting pages PageUptodate state
      LU-4017 quota: redefine LL_MAXQUOTAS for Lustre

Yang Sheng (2):
      LU-8027 llite: ensure obd is effective in onu_upcall
      LU-8147 osd-zfs: fix osd_mount error path
