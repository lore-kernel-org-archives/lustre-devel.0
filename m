From: NeilBrown <neilb@suse.com>
Date: Fri, 15 Jun 2018 17:11:30 +1000
Subject: [lustre-devel] [PATCH 00/24] lustre - more cleanups including
 module reduction.
Message-ID: <152904663333.10587.10934053155404014785.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Here are a bunch more cleanups that will appear in my lustre-testing
tree shortly.

The interesting stuff is some enhancements to kbuild to let us
build modules from multiple directories.
I've used that to clean up the build of ptlrpc+ldlm and to
merge libcfs and lnet into the one module - I've left the lnds
separate.

I've haven't progressed further in lustre because I'm not sure which -
if any - modules are also used by the server.
I'd rather shared code was in a separate module to client-only.

Which parts of lustre/lustre/* are also used by server?

After that, it is all fairly simple cleanups.

I plan to submit the kbuild stuff upstream next week.

Thanks,
NeilBrown

---

NeilBrown (24):
      kbuild: detect directories in components of a module.
      kbuild: treat a directory listed in a composite object as foo/mod.a
      kbuild: support building of per-directory mod.a
      kbuild: disable KBUILD_MODNAME when building for mod.a
      kbuild: Add documentation for modobj-m
      lustre: build ldlm in the ldlm directory.
      lustre: merge libcfs module into lnet.
      lustre: use truncate_inode_page in place of truncate_complete_page
      lustre: don't use spare bits in iattr.ia_valid
      lustre: remove lustre_patchless_compat.h
      lustre: discard current_n*groups macros.
      lustre: discard LTIME_S macro
      lustre: discard NO_QUOTA and QUOTA_OK
      lustre: discard ext2* bit operations
      lustre: centralize TIMES_SET_FLAGS
      lustre: remove redefinition of module_init().
      lustre: remove lustre_compat.h
      lustre/lnet: move tracefile locking from linux-tracefile.c to tracefile.c
      lustre: open code cfs_trace_max_debug_mb() into cfs_trace_set_debug_mb()
      lustre: move tcd locking across to tracefile.c
      lustre: move remainder of linux-tracefile.c to tracefile.c
      lustre: fold cfs_tracefile_*_arch into their only callers.
      lustre: renamed CFS_TCD_TYPE_MAX to CFS_TCD_TYPE_CNT
      lustre: discard TCD_MAX_TYPES


 Documentation/kbuild/makefiles.txt                 |   65 +++++
 drivers/staging/lustre/lnet/Makefile               |    7 -
 drivers/staging/lustre/lnet/libcfs/Makefile        |    7 -
 drivers/staging/lustre/lnet/libcfs/debug.c         |    6 
 .../staging/lustre/lnet/libcfs/linux-tracefile.c   |  258 --------------------
 drivers/staging/lustre/lnet/libcfs/module.c        |   26 +-
 drivers/staging/lustre/lnet/libcfs/tracefile.c     |  241 +++++++++++++++++--
 drivers/staging/lustre/lnet/libcfs/tracefile.h     |   40 ---
 drivers/staging/lustre/lnet/lnet/Makefile          |   11 -
 drivers/staging/lustre/lnet/lnet/module.c          |    9 +
 drivers/staging/lustre/lustre/fid/lproc_fid.c      |    1 
 drivers/staging/lustre/lustre/fld/lproc_fld.c      |    1 
 drivers/staging/lustre/lustre/include/cl_object.h  |    6 
 .../staging/lustre/lustre/include/lustre_compat.h  |   82 ------
 drivers/staging/lustre/lustre/include/lustre_net.h |    1 
 .../lustre/include/lustre_patchless_compat.h       |   68 -----
 drivers/staging/lustre/lustre/include/obd.h        |    7 +
 .../staging/lustre/lustre/include/obd_support.h    |    1 
 drivers/staging/lustre/lustre/ldlm/Makefile        |   11 +
 drivers/staging/lustre/lustre/llite/dir.c          |    3 
 drivers/staging/lustre/lustre/llite/file.c         |   36 +--
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |   11 -
 .../staging/lustre/lustre/llite/llite_internal.h   |   13 +
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   52 ++--
 drivers/staging/lustre/lustre/llite/namei.c        |   16 +
 drivers/staging/lustre/lustre/llite/vvp_io.c       |    8 -
 drivers/staging/lustre/lustre/llite/vvp_object.c   |    6 
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |    6 
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   21 +-
 drivers/staging/lustre/lustre/lov/lov_io.c         |    3 
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    2 
 drivers/staging/lustre/lustre/lov/lov_pack.c       |    1 
 drivers/staging/lustre/lustre/lov/lov_page.c       |    1 
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |   19 +
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |    4 
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   12 -
 drivers/staging/lustre/lustre/obdclass/class_obd.c |    1 
 drivers/staging/lustre/lustre/obdclass/llog.c      |    7 -
 .../lustre/lustre/obdclass/lprocfs_status.c        |    1 
 .../staging/lustre/lustre/obdclass/obd_config.c    |    1 
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |    1 
 drivers/staging/lustre/lustre/obdclass/obdo.c      |   10 -
 .../staging/lustre/lustre/obdecho/echo_client.c    |    1 
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |    1 
 drivers/staging/lustre/lustre/osc/osc_cache.c      |    4 
 drivers/staging/lustre/lustre/osc/osc_io.c         |   23 +-
 drivers/staging/lustre/lustre/osc/osc_quota.c      |    4 
 drivers/staging/lustre/lustre/osc/osc_request.c    |    1 
 drivers/staging/lustre/lustre/ptlrpc/Makefile      |   12 -
 drivers/staging/lustre/lustre/ptlrpc/import.c      |    1 
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |    1 
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |    1 
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |   15 +
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c   |    1 
 drivers/staging/lustre/lustre/ptlrpc/service.c     |    1 
 scripts/Makefile.build                             |   57 +++-
 scripts/Makefile.lib                               |   63 +++--
 57 files changed, 584 insertions(+), 685 deletions(-)
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
 delete mode 100644 drivers/staging/lustre/lustre/include/lustre_compat.h
 delete mode 100644 drivers/staging/lustre/lustre/include/lustre_patchless_compat.h
 create mode 100644 drivers/staging/lustre/lustre/ldlm/Makefile

--
Signature
