From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 21:52:07 -0400
Subject: [lustre-devel] [PATCH 00/11] lustre: cleanup most check patch issues
Message-ID: <1563760338-806-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Another run at fs/lustre to reduce the check patch issue to a small
number that are mostly over 80 characters per line issues. This
makes Lustre appear to be real Linux kernel code :-) No code changes
in this patch series. This is again the main lustre branch of Neil
Brown's kernel tree.

James Simmons (11):
  lustre: ptlrpc: checkpatch cleanup
  lustre: llite: checkpatch cleanup
  lustre: fid: checkpatch cleanup
  lustre: mgc: checkpatch cleanup
  lustre: lmv: checkpatch cleanup
  lustre: mdc: checkpatch cleanup
  lustre: osc: checkpatch cleanup
  lustre: lov: checkpatch cleanup
  lustre: obdclass: checkpatch cleanup
  lustre: ldlm: checkpatch cleanup
  lustre: internal headers checkpatch cleanup

 fs/lustre/fid/fid_request.c         |  1 -
 fs/lustre/fid/lproc_fid.c           |  3 +-
 fs/lustre/fld/fld_internal.h        |  5 +--
 fs/lustre/include/cl_object.h       | 13 +++----
 fs/lustre/include/lprocfs_status.h  | 11 +++---
 fs/lustre/include/lu_object.h       | 26 +++++++-------
 fs/lustre/include/lustre_acl.h      |  4 +--
 fs/lustre/include/lustre_dlm.h      | 53 +++++++++++++++++-----------
 fs/lustre/include/seq_range.h       |  8 ++---
 fs/lustre/ldlm/ldlm_extent.c        |  1 -
 fs/lustre/ldlm/ldlm_flock.c         | 15 ++++----
 fs/lustre/ldlm/ldlm_internal.h      |  5 +--
 fs/lustre/ldlm/ldlm_lib.c           |  4 +--
 fs/lustre/ldlm/ldlm_lock.c          |  8 ++---
 fs/lustre/ldlm/ldlm_lockd.c         | 22 +++++++-----
 fs/lustre/ldlm/ldlm_pool.c          |  3 +-
 fs/lustre/ldlm/ldlm_request.c       | 18 +++++-----
 fs/lustre/llite/dir.c               | 18 +++++-----
 fs/lustre/llite/file.c              | 24 ++++++-------
 fs/lustre/llite/llite_internal.h    |  8 +++--
 fs/lustre/llite/llite_lib.c         | 26 +++++++-------
 fs/lustre/llite/llite_nfs.c         |  3 +-
 fs/lustre/llite/lproc_llite.c       |  8 +++--
 fs/lustre/llite/namei.c             | 15 +++++---
 fs/lustre/llite/rw26.c              |  3 +-
 fs/lustre/llite/statahead.c         | 23 ++++++++-----
 fs/lustre/llite/super25.c           |  3 +-
 fs/lustre/llite/vvp_dev.c           |  3 +-
 fs/lustre/llite/vvp_io.c            |  2 +-
 fs/lustre/lmv/lmv_intent.c          |  9 +++--
 fs/lustre/lmv/lmv_obd.c             | 22 +++++++-----
 fs/lustre/lov/lov_io.c              |  2 +-
 fs/lustre/lov/lov_lock.c            |  4 +--
 fs/lustre/lov/lov_merge.c           |  6 ++--
 fs/lustre/lov/lov_obd.c             |  6 ++--
 fs/lustre/lov/lov_object.c          |  6 ++--
 fs/lustre/lov/lov_pool.c            | 24 +++++++++----
 fs/lustre/lov/lov_request.c         |  3 +-
 fs/lustre/mdc/mdc_changelog.c       | 15 +++++---
 fs/lustre/mdc/mdc_lib.c             | 15 +++++---
 fs/lustre/mdc/mdc_locks.c           |  2 +-
 fs/lustre/mdc/mdc_request.c         | 16 +++++----
 fs/lustre/mgc/mgc_request.c         | 17 +++++----
 fs/lustre/obdclass/cl_io.c          | 16 ++++++---
 fs/lustre/obdclass/cl_lock.c        |  8 +++--
 fs/lustre/obdclass/cl_object.c      | 12 +++----
 fs/lustre/obdclass/cl_page.c        |  9 ++---
 fs/lustre/obdclass/class_obd.c      |  3 +-
 fs/lustre/obdclass/genops.c         |  9 +++--
 fs/lustre/obdclass/llog.c           |  3 +-
 fs/lustre/obdclass/llog_obd.c       |  8 ++---
 fs/lustre/obdclass/llog_swab.c      |  6 ++--
 fs/lustre/obdclass/lprocfs_status.c |  4 +--
 fs/lustre/obdclass/lu_object.c      |  3 +-
 fs/lustre/obdclass/obd_config.c     | 12 ++++---
 fs/lustre/obdclass/obd_mount.c      |  3 +-
 fs/lustre/obdecho/debug.c           | 12 ++++---
 fs/lustre/osc/lproc_osc.c           |  7 ++--
 fs/lustre/osc/osc_cache.c           | 15 +++-----
 fs/lustre/osc/osc_internal.h        |  6 ++--
 fs/lustre/osc/osc_lock.c            |  6 ++--
 fs/lustre/osc/osc_object.c          |  6 ++--
 fs/lustre/osc/osc_page.c            |  3 +-
 fs/lustre/osc/osc_quota.c           | 20 ++++++-----
 fs/lustre/osc/osc_request.c         | 38 +++++++++-----------
 fs/lustre/ptlrpc/client.c           | 67 ++++++++++++++++++++++-------------
 fs/lustre/ptlrpc/connection.c       |  2 +-
 fs/lustre/ptlrpc/events.c           |  5 +--
 fs/lustre/ptlrpc/import.c           | 69 +++++++++++++++++++++----------------
 fs/lustre/ptlrpc/layout.c           | 19 +++++-----
 fs/lustre/ptlrpc/llog_client.c      |  3 +-
 fs/lustre/ptlrpc/lproc_ptlrpc.c     | 21 +++++++----
 fs/lustre/ptlrpc/niobuf.c           | 12 ++++---
 fs/lustre/ptlrpc/nrs.c              |  2 +-
 fs/lustre/ptlrpc/pack_generic.c     |  6 ++--
 fs/lustre/ptlrpc/pinger.c           |  6 ++--
 fs/lustre/ptlrpc/ptlrpc_internal.h  |  5 ++-
 fs/lustre/ptlrpc/ptlrpc_module.c    |  6 ++--
 fs/lustre/ptlrpc/ptlrpcd.c          |  3 +-
 fs/lustre/ptlrpc/recover.c          |  3 +-
 fs/lustre/ptlrpc/sec.c              | 21 ++++++-----
 fs/lustre/ptlrpc/sec_config.c       | 15 +++++---
 fs/lustre/ptlrpc/sec_lproc.c        |  3 +-
 fs/lustre/ptlrpc/service.c          | 40 ++++++++++++---------
 84 files changed, 588 insertions(+), 412 deletions(-)

-- 
1.8.3.1
