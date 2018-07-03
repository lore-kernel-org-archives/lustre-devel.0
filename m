From: NeilBrown <neilb@suse.com>
Date: Tue, 03 Jul 2018 14:57:33 +1000
Subject: [lustre-devel] [PATCH 00/18] lustre: missing updates from
 lustre 2.9
In-Reply-To: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
Message-ID: <87lgas29xe.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jul 02 2018, James Simmons wrote:

> This patch set fills in the known missing pieces from the Lustre
> 2.9 release. With these patches this brings us to the pre-2.10
> development cycle. The grant allocation fixes were missing as
> well as security hole closes. The rest are small changes in
> addition to support for filesets and ladvise feature.
>
> Alexander Boyko (1):
>   lustre: obd: add callback for llog_cat_process_or_fork
>
> Bobi Jam (1):
>   lustre: osc: max_pages_per_rpc should be chunk size aligned
>
> Fan Yong (1):
>   lustre: ptlrpc: properly set "rq_xid" for 4MB IO
>
> Henri Doreau (1):
>   lustre: llite: restore fd_och when putting lease
>
> James Simmons (2):
>   lustre: libcfs: restore original behavior in cfs_str2num_check

Apart from this patch which I couldn't bring myself to apply, I've
applied all these patches - making changes to only one as mentioned
below.
I'll probably add some cleanups later as separately described.

>   lustre: update version to 2.8.99
>
> Jian Yu (1):
>   lustre: mount: fix lmd_parse() to handle new delimiters
>
> Jinshan Xiong (1):
>   lustre: llite: fast read implementation
>
> Johann Lombardi (1):
>   lustre: grant: add support for OBD_CONNECT_GRANT_PARAM
>
> John L. Hammond (3):
>   lustre: obd: rename md_getstatus() to md_get_root()
>   lustre: obd: reserve connection flag OBD_CONNECT2_FILE_SECCTX
>   lustre: security: send file security context for creates
>
> Lai Siyao (1):
>   lustre: fileset: add fileset mount support

When I removed the union name as promised, this went from
 14 files changed, 135 insertions(+), 43 deletions(-)
to
 14 files changed, 120 insertions(+), 28 deletions(-)

Not an enormous change, but worthwhile I think.

Thanks
NeilBrown

>
> Li Xi (3):
>   lustre: ladvise: Add feature of giving file access advices
>   lustre: ladvise: Add willread advice support for ladvise
>   lustre: ladvise: Add dontneed advice support for ladvise
>
> Niu Yawei (1):
>   lustre: ldlm: reduce mem footprint of ldlm_resource
>
> Patrick Farrell (1):
>   lustre: llite: ladvise protocol changes
>
>  .../lustre/include/uapi/linux/lustre/lustre_idl.h  |  52 ++-
>  .../lustre/include/uapi/linux/lustre/lustre_user.h |  51 +++
>  .../lustre/include/uapi/linux/lustre/lustre_ver.h  |   4 +-
>  drivers/staging/lustre/lnet/libcfs/libcfs_string.c |  17 +-
>  drivers/staging/lustre/lustre/include/cl_object.h  |  13 +
>  .../staging/lustre/lustre/include/lustre_disk.h    |   2 +
>  drivers/staging/lustre/lustre/include/lustre_dlm.h |  24 +-
>  .../staging/lustre/lustre/include/lustre_import.h  |   1 +
>  .../lustre/lustre/include/lustre_req_layout.h      |  10 +-
>  .../staging/lustre/lustre/include/lustre_swab.h    |   2 +
>  drivers/staging/lustre/lustre/include/obd.h        |  17 +-
>  drivers/staging/lustre/lustre/include/obd_class.h  |  16 +-
>  .../staging/lustre/lustre/include/obd_support.h    |   5 +-
>  drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |   1 +
>  drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |   1 +
>  drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |  20 +-
>  drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |  32 +-
>  drivers/staging/lustre/lustre/llite/dir.c          |  54 +++-
>  drivers/staging/lustre/lustre/llite/file.c         | 360 ++++++++++++++++++---
>  .../staging/lustre/lustre/llite/llite_internal.h   |  34 +-
>  drivers/staging/lustre/lustre/llite/llite_lib.c    |  37 ++-
>  drivers/staging/lustre/lustre/llite/llite_mmap.c   |  34 +-
>  drivers/staging/lustre/lustre/llite/lproc_llite.c  |  38 +++
>  drivers/staging/lustre/lustre/llite/namei.c        |  40 ++-
>  drivers/staging/lustre/lustre/llite/rw.c           |  68 +++-
>  drivers/staging/lustre/lustre/llite/vvp_internal.h |   1 +
>  drivers/staging/lustre/lustre/llite/vvp_io.c       |   3 +
>  .../staging/lustre/lustre/llite/xattr_security.c   |  38 ++-
>  drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  34 +-
>  drivers/staging/lustre/lustre/lov/lov_io.c         |  28 ++
>  drivers/staging/lustre/lustre/mdc/mdc_internal.h   |   4 +
>  drivers/staging/lustre/lustre/mdc/mdc_lib.c        |  32 ++
>  drivers/staging/lustre/lustre/mdc/mdc_locks.c      |   7 +
>  drivers/staging/lustre/lustre/mdc/mdc_reint.c      |   7 +
>  drivers/staging/lustre/lustre/mdc/mdc_request.c    |  50 ++-
>  drivers/staging/lustre/lustre/obdclass/cl_io.c     |   2 +
>  drivers/staging/lustre/lustre/obdclass/llog_cat.c  |  16 +-
>  .../lustre/lustre/obdclass/lprocfs_status.c        |  72 ++++-
>  drivers/staging/lustre/lustre/obdclass/obd_mount.c | 135 +++++++-
>  drivers/staging/lustre/lustre/osc/lproc_osc.c      |  18 ++
>  drivers/staging/lustre/lustre/osc/osc_cache.c      |  95 ++++--
>  .../staging/lustre/lustre/osc/osc_cl_internal.h    |   1 +
>  drivers/staging/lustre/lustre/osc/osc_dev.c        |   1 +
>  drivers/staging/lustre/lustre/osc/osc_internal.h   |   4 +
>  drivers/staging/lustre/lustre/osc/osc_io.c         |  79 +++++
>  drivers/staging/lustre/lustre/osc/osc_request.c    | 184 +++++++++--
>  drivers/staging/lustre/lustre/ptlrpc/client.c      |   9 +-
>  drivers/staging/lustre/lustre/ptlrpc/import.c      |  10 +
>  drivers/staging/lustre/lustre/ptlrpc/layout.c      |  66 +++-
>  .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |   3 +-
>  .../staging/lustre/lustre/ptlrpc/pack_generic.c    |  27 +-
>  drivers/staging/lustre/lustre/ptlrpc/wiretest.c    | 122 +++++--
>  52 files changed, 1722 insertions(+), 259 deletions(-)
>
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180703/51b3eeb3/attachment.sig>
