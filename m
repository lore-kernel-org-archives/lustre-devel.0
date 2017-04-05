From: Oleg Drokin <oleg.drokin@intel.com>
Date: Wed, 5 Apr 2017 02:03:38 -0400
Subject: [lustre-devel] New tag 2.9.55
Message-ID: <724028D8-3028-47CF-9A5B-9AAAC87465E2@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

  I just tagged a new tag 2.9.55 in Lustre master repo.
  Of note in this tag:
  snapshot feature for zfs backends was added.

  Here's the changelog:

Abrarahmed Momin (1):
      LU-5361 llite: Remove OBD_FAIL_OSC_CONNECT_CKSUM

Al Viro (1):
      LU-4423 llite: get rid of lustre_dump_dentry()

Andreas Dilger (14):
      LU-4825 ofd: fix OBD_FAIL_OST_ENOINO/ENOSPC behaviour
      LU-9161 utils: don't load bitmaps when checking features
      LU-8813 gss: limit the number of error messages in logs
      LU-9176 osd-zfs: improve statfs estimate for ZFS
      LU-7537 tests: clean up sanity test_133c
      LU-9201 libcfs: reduce libcfs checksum speed test time
      LU-5964 tests: open a large number of files at once
      LU-7092 tests: generate sanity proc_dirs on facet
      LU-1095 mdt: quiet mdt_mfd_set_mode() debugging
      LU-9153 utils: improve llog name parsing
      LU-5969 tests: allow "version" without "lustre:" prefix
      LU-137 obdclass: add dt_object_put() and use it
      LU-1095 obdclass: improve missing operation message
      LU-6051 utils: improve efficiency of lfs_migrate cmp

Andriy Skulysh (1):
      LU-8624 osc: hung in osc_destroy()

Arnd Bergmann (1):
      LU-4423 ptlrpc: use 64-bit time for debugfs import state output

Bob Glossman (3):
      LU-9138 kernel: kernel update [SLES12 SP1 3.12.69-60.64.32]
      LU-9174 kernel: kernel update RHEL7.3 [3.10.0-514.10.2.el7]
      LU-9169 kernel: kernel update [SLES12 SP2 4.4.49-92.11]

Bruno Faccini (2):
      LU-8808 mdt: avoid out of order ChangeLog during restore
      LU-8907 llite: handle client racy case during create

Chris Horn (1):
      LU-8735 llite: Return -ERESTARTSYS in range_lock()

Di Wang (1):
      LU-9197 llog: return 0 if llog destroy fails

Dmitry Eremin (1):
      LU-9026 o2iblnd: Adapt to the removal of ib_get_dma_mr()

Emoly Liu (1):
      LU-9085 llstat: don't use a hash as a reference

Fan Yong (14):
      LU-8900 snapshot: operate write barrier on MDT
      LU-8662 osd-ldiskfs: check OI mapping update
      LU-8900 snapshot: check write barrier before modification
      LU-8900 snapshot: user interface for write barrier on MDT
      LU-8900 snapshot: fork/erase configuration
      LU-8900 snapshot: simulate readonly device
      LU-8900 snapshot: rename filesysetem fsname
      LU-9040 scrub: handle group boundary properly (2)
      LU-8701 tests: scrub-performance with separated MGS and MDS
      LU-8930 lfsck: sync failure with others no check LF_INCOMPLETE
      LU-9231 tests: cleanup obdecho before iokit exit
      LU-8900 snapshot: user space snapshot tools
      LU-8900 doc: Lustre snapshot man page
      LU-9224 fid: race between client_fid_fini and seq_client_flush

Jadhav Vikram (1):
      LU-8952 tests: handling test specific cleanup of ost pools

James Nunez (1):
      LU-8366 test: Remove PIOS tests

James Simmons (5):
      LU-9019 zfs: use 64-bit timestamps for brw stats
      LU-9019 msg : migrate IR stats to 64 bit time
      LU-9019 socklnd: use 64-bit incarnation time stamp
      LU-6401 uapi: split lustre_disk.h into two headers
      LU-9019 obd: use 64-bit time for obd_recovery_* fields

Jian Yu (1):
      LU-9213 scripts: check MGT status in lustre init script

Jinshan Xiong (3):
      LU-7497 tests: Fix test failure in conf-sanity 32b
      LU-9129 llite: ignore layout for ll_writepages()
      LU-2435 osd-zfs: use zfs native dnode accounting

John L. Hammond (6):
      LU-9167 hsm: use a new environment during HSM purge
      LU-8820 hsm: skip LL_IOC_HSM_COPY_START for HSM removes
      LU-8918 obdclass: hoist locking in lu_context_exit()
      LU-9010 obdclass: use static initializer macros where possible
      LU-9014 test: handle separate MGS in conf-sanity test_72()
      LU-8403 obd: remove unused data parameter from obd_notify()

Keith (1):
      LU-9223: Server on Linux 4.4: XATTR_NAME_POSIX_ACL_ACCESS

Lai Siyao (1):
      LU-8857 config: refactor sptlrpc config process

Michael Kuhn (1):
      LU-9003 mdc: support posix_acl_valid with user namespace

Mikhal Pershin (1):
      LU-9066 ldlm: don't evict client on umount if AST fails

Minh Diep (1):
      LU-9222 build: workaround for sles11sp4 MOFED

Nathaniel Clark (1):
      LU-9107 build: Update SPL/ZFS to 0.6.5.9

Nikitas Angelinas (1):
      LU-7131 utils: add "--erase-param" option to tunefs.lustre

Niu Yawei (3):
      LU-8306 ldlm: send blocking ASTs after lock replay
      LU-9216 config: move config types into lustre_idl.h
      LU-8872 quota: incorrect LASSERT

Oleg Drokin (1):
      New tag 2.9.55

Parinay Kondekar (2):
      LU-9182 tests: SKIP sanity/205 for older version of MDS
      LU-9117 tests: SKIP sanity/129 on older MDS versions

Sebastien Buisson (1):
      LU-8880 gss: fix GSS support for DNE

Wei Liu (3):
      LU-6707 test: load loop module to have loop devices
      LU-7790 test: skip test_130a and test_130b if server is less than 2.7.2
      LU-9102 test: Include specific headers needed by Posix suite

Yang Sheng (1):
      LU-9170 test: fix for hostlist_expand

wangdi (1):
      LU-9088 osd: use od_is_ost check OST FID
