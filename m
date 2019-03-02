From: James Simmons <jsimmons@infradead.org>
Date: Sat, 2 Mar 2019 19:28:37 +0000 (GMT)
Subject: [lustre-devel] [PATCH 0/7] lustre: move DocBook comments to
 sphinix format
In-Reply-To: <1551553944-6419-1-git-send-email-jsimmons@infradead.org>
References: <1551553944-6419-1-git-send-email-jsimmons@infradead.org>
Message-ID: <alpine.LFD.2.21.1903021928001.29568@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> The Linux kernel deprecated DocBook so update Lustre to using
> sphinix instead. I'm no Sphinix expert so things might be missed
> but the major has been ported over. This should get the lustre
> in shape to move out of staging.

Forgot to add. This is against lustre-testing since the wip* trees
are stil churning.
 
> James Simmons (7):
>   lnet: move comments to sphinix format
>   lustre: move header file comments to sphinix format
>   ptlrpc: move comments to sphinix format
>   ldlm: move comments to sphinix format
>   llite: move comments to sphinix format
>   obdclass: move comments to sphinix format
>   lustre: move remaining comments to sphinix format
> 
>  .../lustre/include/linux/libcfs/libcfs_cpu.h       |  50 ++--
>  .../lustre/include/linux/libcfs/libcfs_crypto.h    |  20 +-
>  .../lustre/include/uapi/linux/lnet/lnetctl.h       |   2 +-
>  .../lustre/include/uapi/linux/lustre/lustre_fid.h  |  20 +-
>  .../lustre/include/uapi/linux/lustre/lustre_idl.h  |   2 +-
>  .../lustre/include/uapi/linux/lustre/lustre_user.h |  13 +-
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |   2 +-
>  drivers/staging/lustre/lnet/libcfs/debug.c         |   2 +-
>  drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    |   2 +-
>  drivers/staging/lustre/lnet/libcfs/libcfs_lock.c   |   8 +-
>  drivers/staging/lustre/lnet/libcfs/libcfs_string.c |  67 +++--
>  drivers/staging/lustre/lnet/libcfs/linux-crypto.c  | 131 ++++-----
>  drivers/staging/lustre/lnet/lnet/api-ni.c          |  34 +--
>  drivers/staging/lustre/lnet/lnet/lib-eq.c          | 100 +++----
>  drivers/staging/lustre/lnet/lnet/lib-md.c          |  67 ++---
>  drivers/staging/lustre/lnet/lnet/lib-me.c          |  76 ++---
>  drivers/staging/lustre/lnet/lnet/lib-move.c        | 113 ++++----
>  drivers/staging/lustre/lnet/lnet/lib-ptl.c         |  12 +-
>  drivers/staging/lustre/lnet/lnet/net_fault.c       |  30 +-
>  drivers/staging/lustre/lnet/lnet/nidstrings.c      | 125 ++++-----
>  drivers/staging/lustre/lustre/fld/fld_cache.c      |   4 +-
>  drivers/staging/lustre/lustre/fld/fld_internal.h   |   2 +-
>  drivers/staging/lustre/lustre/include/cl_object.h  |  91 +++---
>  drivers/staging/lustre/lustre/include/lu_object.h  |   8 +-
>  drivers/staging/lustre/lustre/include/lustre_dlm.h |  10 +-
>  .../staging/lustre/lustre/include/lustre_import.h  |   4 +-
>  drivers/staging/lustre/lustre/include/lustre_mdc.h |   4 +-
>  drivers/staging/lustre/lustre/include/lustre_net.h |  76 ++---
>  drivers/staging/lustre/lustre/include/lustre_nrs.h | 118 ++++----
>  drivers/staging/lustre/lustre/include/lustre_sec.h |  83 +++---
>  drivers/staging/lustre/lustre/include/obd_class.h  |   9 +-
>  drivers/staging/lustre/lustre/include/seq_range.h  |  32 +--
>  drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |  14 +-
>  drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |   8 +-
>  drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |  90 +++---
>  drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |   6 +-
>  drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |  22 +-
>  drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |  99 ++++---
>  drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |  18 +-
>  drivers/staging/lustre/lustre/llite/dir.c          |  14 +-
>  drivers/staging/lustre/lustre/llite/file.c         |  62 +++--
>  drivers/staging/lustre/lustre/llite/glimpse.c      |   4 +-
>  drivers/staging/lustre/lustre/llite/lcommon_cl.c   |   5 +-
>  drivers/staging/lustre/lustre/llite/llite_lib.c    |  48 ++--
>  drivers/staging/lustre/lustre/llite/llite_mmap.c   |  19 +-
>  drivers/staging/lustre/lustre/llite/llite_nfs.c    |   4 +-
>  drivers/staging/lustre/lustre/llite/lproc_llite.c  |  22 +-
>  drivers/staging/lustre/lustre/llite/range_lock.c   |  20 +-
>  drivers/staging/lustre/lustre/llite/rw.c           |  14 +-
>  drivers/staging/lustre/lustre/llite/statahead.c    |  59 ++--
>  drivers/staging/lustre/lustre/llite/super25.c      |   3 +-
>  drivers/staging/lustre/lustre/llite/vvp_io.c       |   2 +-
>  drivers/staging/lustre/lustre/llite/vvp_page.c     |   8 +-
>  drivers/staging/lustre/lustre/llite/xattr_cache.c  |  44 +--
>  .../staging/lustre/lustre/llite/xattr_security.c   |  12 +-
>  drivers/staging/lustre/lustre/lmv/lmv_obd.c        | 119 ++++----
>  drivers/staging/lustre/lustre/lov/lov_io.c         |   2 +-
>  drivers/staging/lustre/lustre/lov/lov_object.c     |  47 ++--
>  drivers/staging/lustre/lustre/lov/lov_pack.c       |   4 +-
>  drivers/staging/lustre/lustre/mdc/mdc_changelog.c  |  91 +++---
>  drivers/staging/lustre/lustre/mdc/mdc_lib.c        |  12 +-
>  drivers/staging/lustre/lustre/mdc/mdc_request.c    |  34 +--
>  drivers/staging/lustre/lustre/mgc/mgc_request.c    |   8 +-
>  drivers/staging/lustre/lustre/obdclass/cl_io.c     |  12 +-
>  drivers/staging/lustre/lustre/obdclass/cl_lock.c   |  11 +-
>  drivers/staging/lustre/lustre/obdclass/cl_object.c |  44 +--
>  drivers/staging/lustre/lustre/obdclass/cl_page.c   |  30 +-
>  drivers/staging/lustre/lustre/obdclass/genops.c    |  22 +-
>  .../staging/lustre/lustre/obdclass/kernelcomm.c    |  23 +-
>  drivers/staging/lustre/lustre/obdclass/linkea.c    |  15 +-
>  .../lustre/lustre/obdclass/lprocfs_status.c        |  30 +-
>  drivers/staging/lustre/lustre/obdclass/lu_object.c |  44 +--
>  drivers/staging/lustre/lustre/obdclass/obd_mount.c |  47 ++--
>  drivers/staging/lustre/lustre/osc/osc_cache.c      |  12 +-
>  drivers/staging/lustre/lustre/osc/osc_lock.c       |  10 +-
>  drivers/staging/lustre/lustre/osc/osc_request.c    |   4 +-
>  drivers/staging/lustre/lustre/ptlrpc/client.c      |  72 ++---
>  drivers/staging/lustre/lustre/ptlrpc/import.c      |   6 +-
>  drivers/staging/lustre/lustre/ptlrpc/layout.c      | 102 +++----
>  .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |  10 +-
>  drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |  14 +-
>  drivers/staging/lustre/lustre/ptlrpc/nrs.c         | 305 +++++++++++----------
>  drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c    |  68 ++---
>  .../staging/lustre/lustre/ptlrpc/pack_generic.c    |   8 +-
>  drivers/staging/lustre/lustre/ptlrpc/sec.c         | 104 +++----
>  drivers/staging/lustre/lustre/ptlrpc/sec_config.c  |   2 +-
>  drivers/staging/lustre/lustre/ptlrpc/service.c     |   4 +-
>  87 files changed, 1641 insertions(+), 1589 deletions(-)
> 
> -- 
> 1.8.3.1
> 
> 
