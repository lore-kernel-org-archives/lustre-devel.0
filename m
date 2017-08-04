From: Oleg Drokin <oleg.drokin@intel.com>
Date: Fri, 4 Aug 2017 19:01:38 -0400
Subject: [lustre-devel] New tag 2.10.51
Message-ID: <9C643E57-9229-463B-B6C4-0466DC9726CB@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   I tagged 2.10.51 in the master branch of the current community tree recently.
   The changelog is below.

   Additionally I am improving visibility into the landing process. You might have
   noticed there's a new branch master-next, this will contain patches currently
   undergoing integration testing for the next landing opportunity.
   Assuming all is well they would be landed. The branch is going to be rebased as
   needed to remove defective patches or to add new ones.
   Additional testing by all interested parties is welcome, that way we can preemptively
   find problems before they make it to the master branch making the tip
   of master branch more stable at all times.


Alex Zhuravlev (2):
      LU-9305 osd: do not release pages twice
      LU-9683 ptlrpc: fix argument misorder

Amir Shehata (2):
      LU-9729 lnet: correct locking in legacy add net
      LU-9203 lnet: fix lnet_cpt_of_md()

Andreas Dilger (7):
      LU-9715 libcfs: crash in cpu_pattern parsing code
      LU-7631 tests: wait_osts_up waits for MDS precreates
      LU-9153 llog: consolidate common error checking
      LU-282 tests: remove extra logging from sanity 27
      LU-9728 osd: use GFP_HIGHUSER for non-local IO
      LU-6051 utils: allow lfs_migrate to migrate links
      LU-7589 build: update checkpatch to ~4.13-rc1 kernel

Andrew Perepechko (2):
      LU-9417 mdc: excessive memory consumption by the xattr cache
      LU-9716 osc: osc_extent_tree_dump0() implementation is suboptimal

Andriy Skulysh (1):
      LU-6436 llite: NULL pointer dereference in cl_object_top()

Arshad Hussain (1):
      LU-8885 tests: zconf_mount_clients() defect

Bob Glossman (4):
      LU-9738 kernel: kernel update RHEL7.3 [3.10.0-514.26.2.el7]
      LU-9712 kernel: kernel update [SLES11 SP4 3.0.101-107]
      LU-9763 kernel: kernel update RHEL6.9 [2.6.32-696.6.3.el6]
      LU-9773 kernel: kernel update [SLES12 SP2 4.4.74-92.29]

Bobi Jam (1):
      LU-3719 ldiskfs: adjust s_mb_prealloc_table_size correctly

Brian J. Murrell (3):
      LU-9775 Look for kernel-devel in /usr/src/kernels
      LU-9731 kmods need to be limited to EL minor release kernel
      LU-9776 lustre-client cannot be installed if both client and server repos are configured

Dmitry Eremin (4):
      LU-8703 libcfs: change CPT estimate algorithm
      LU-9183 llite: add support set_acl method in inode operations
      LU-9769 lnet: Fix lost lock
      LU-9439 scripts: add lnet script in .gitignore

Doug Oucharek (1):
      LU-9500 lnd: Don't Page Align remote_addr with FastReg

Emoly Liu (3):
      LU-9505 llapi: treat MDT index as a hex number
      LU-9657 llapi: check if the file layout is composite
      LU-9750 nrs: some code cleanup in NRS policies

Fan Yong (7):
      LU-9514 ptlrpc: free reply buffer earlier for open RPC
      LU-9740 ldiskfs: more credits for non-append write
      LU-9753 ofd: 64-bits diff variable to avoid overflow
      LU-9545 lfsck: report "inconsistent" under dryrun mode
      LU-8760 lib: avoid unexpected out of order execution
      LU-7991 osd-zfs: remove obsolete quota code
      LU-9710 utils: adjust barrier_stat input/output

Frank Zago (2):
      LU-7988 hsm: mark the cdt as stopped when its thread exits
      LU-7988 hsm: run HSM coordinator once per second at most

Jadhav Vikram (5):
      LU-9219 tests: add missing mgs reformat to conf-sanity/56
      LU-9511 utils: fix parallel_grouplock test timeout
      LU-9509 tests: fix compilebench timeout
      LU-9620 lod: protected ost pool count updation
      LU-9620 tests: test race between pool_list and pool_remove

James Simmons (8):
      LU-6142 selftest: remove typedefs from lnet selftest
      LU-9183 llite: handle xattr with the xattr_handler infrastructure
      LU-9558 lnet: kernel socket accept takes new bool agrument
      LU-9019 target: migrate to 64 bit time
      LU-9019 lfsck: migrate to 64 bit time
      LU-9019 obdclass: migrate jobstats to 64 bit time
      LU-9558 llite: handle struct vm_operations changes
      LU-9558 llite: user enhanced getattr functionality in newer kernels

Jian Yu (1):
      LU-9663 tests: replace ?ls -s? with ?stat -c '%s'? to get file size

Jinshan Xiong (1):
      LU-7372 mgs: reprocess all locks at device fini

Lai Siyao (3):
      LU-5106 statahead: support striped directory
      LU-5106 readdir: improve striped readdir
      LU-8935 ptlrpc: missing barrier before wake_up

Li Xi (1):
      LU-9654 mdt: fix problem of RAoLU HSM policy

Martin Schroeder (1):
      LU-9564 build: Add server-build for Ubuntu with Kernel 4.4.0

Mikhal Pershin (2):
      LU-3285 osc: prepare OSC code to be used from MDC
      LU-9184 ldlm: selective IBITS lock trying

Nathaniel Clark (3):
      LU-6671 wireshark: Process mds_md entries
      LU-9772 utils: Enable new ZFS MMP on mkfs
      LU-4536 tests: Re-enable sanity/65ic

Niu Yawei (4):
      LU-9274 ptlrpc: add replay request into unreplied list
      LU-9671 nodemap: restore client's IDs for OST_WRITE
      LU-9725 lwp: wait on deregister
      LU-7544 doc: improve setquota man page

Oleg Drokin (4):
      LU-8066 obdclass : Add infrastructure for procfs to sysfs migration
      LU-8066 ptlrpc: migrate ptlrpc proc files to sysfs
      Revert "LU-9564 build: Add server-build for Ubuntu with Kernel 4.4.0"
      New tag 2.10.51

Parinay Kondekar (2):
      LU-7653 tests: replay-single/110f fails for mdts on same MDS
      LU-7129 tests: fsx with directio

Patrick Farrell (3):
      LU-9749 llite: Reduce overhead for ll_do_fast_read
      LU-8346 obdclass: Set lc_version
      LU-9778 llite: Read ahead should return pages read

Qian Yingjin (1):
      LU-8849 ofd: Client hanges on ladvise with large start values

Quentin Bouget (1):
      LU-9345 tests: use hsm_remove with --mntpath for deleted files

Rahul Deshmkuh (1):
      LU-9104 obd: Ignore unknown config param while mounting

Saurabh Tandan (1):
      LU-9693 tests: Adding sanity test_42a & 42c to always_except

Sebastien Buisson (2):
      LU-9220 gss: support Kerberos auth from unprivileged container
      LU-7760 ptlrpc: remove incorrect pid printing

Sergey Cheremencev (1):
      LU-9442 osp: can't create IDIF fid number > 0xFFFFFFFF

Steve Guminski (28):
      LU-6210 utils: Use C99 struct initializers in lfs_find()
      LU-6210 utils: Use C99 struct initializers in lfs_mv()
      LU-6210 utils: Use C99 struct initializers in mntdf()
      LU-6210 utils: Use C99 struct initializers in lfs_fid2path()
      LU-6210 utils: Use C99 struct initializers in lfs_hsm_state()
      LU-6210 utils: Use C99 initializers in lfs_get_ladvice()
      LU-6210 utils: Use C99 struct initializers in llverfs.c
      LU-6210 utils: Use C99 struct initializers in lr_reader.c
      LU-6210 utils: Use C99 struct initializers in lshowmount.c
      LU-6210 utils: Use C99 struct initializers in lustre_fsck.c
      LU-6210 utils: Use C99 initializer for lfsck_types_names
      LU-6210 utils: Use consistent naming for option strings
      LU-6210 utils: Use C99 struct initializer in lustre_rsync.c
      LU-6210 utils: Use C99 struct initializer in mkfs_lustre.c
      LU-6210 utils: Use C99 struct initializer for opt_map
      LU-6210 utils: Use C99 struct initializer in parse_opts()
      LU-6210 utils: Use C99 struct initializer for long_opt_start
      LU-6210 utils: Use C99 initializers in lfs_getstripe_internal
      LU-6210 utils: Use C99 struct initializers in lfs_setquota()
      LU-6210 utils: Use C99 struct initializers in lfs_hsm_request()
      LU-6210 utils: Use C99 initializer in jt_obd_md_common()
      LU-6210 utils: C99 initializer in llog_cancel_parse_optional()
      LU-6210 utils: Use C99 initializer in jt_nodemap_add_range()
      LU-6210 utils: Use C99 initializer in jt_nodemap_set_fileset()
      LU-6210 utils: Use C99 initializer in jt_nodemap_modify()
      LU-6210 utils: Use C99 initializer in jt_nodemap_add_idmap()
      LU-6210 utils: Use C99 initializer in jt_nodemap_del_idmap()
      LU-6210 utils: Use C99 struct initializer in mount_utils_zfs.c

Vitaly Fertman (1):
      LU-8062 ptlrpc: increase sleep time in ptlrpc_request_bufs_pack()

Wang Shilong (1):
      LU-9733 obd: fix fsname parsing
