From: James Simmons <jsimmons@infradead.org>
Date: Sun,  8 Nov 2015 18:09:37 -0500
Subject: [lustre-devel] [PATCH] staging: lustre: update Intel copyright
	messages 2015
In-Reply-To: <1447024177-2219-1-git-send-email-jsimmons@infradead.org>
References: <1447024177-2219-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1447024177-2219-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <andreas.dilger@intel.com>

Update copyright messages in files modified by Intel employees
in 2015 by non-trivial patches.  Exclude patches that are only
deleting code, renaming functions, or adding or removing whitespace.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7243
Reviewed-on: http://review.whamcloud.com/16758
Reviewed-by: James Nunez <james.a.nunez@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    2 +-
 .../lustre/include/linux/libcfs/libcfs_cpu.h       |    3 ++-
 .../lustre/include/linux/libcfs/libcfs_hash.h      |    2 +-
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    2 +-
 .../staging/lustre/include/linux/lnet/lib-types.h  |    2 +-
 drivers/staging/lustre/include/linux/lnet/nidstr.h |    2 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    2 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    2 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    2 +-
 drivers/staging/lustre/lnet/lnet/acceptor.c        |    2 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    2 +-
 drivers/staging/lustre/lnet/lnet/config.c          |    2 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c        |    2 +-
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |    2 +-
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |    2 +-
 drivers/staging/lustre/lnet/lnet/module.c          |    2 +-
 drivers/staging/lustre/lnet/lnet/router.c          |    2 +-
 drivers/staging/lustre/lnet/selftest/brw_test.c    |    2 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         |    2 +-
 drivers/staging/lustre/lustre/fid/fid_request.c    |    2 +-
 drivers/staging/lustre/lustre/fid/lproc_fid.c      |    2 +-
 drivers/staging/lustre/lustre/fld/fld_internal.h   |    2 +-
 drivers/staging/lustre/lustre/fld/fld_request.c    |    2 +-
 drivers/staging/lustre/lustre/fld/lproc_fld.c      |    2 +-
 drivers/staging/lustre/lustre/include/cl_object.h  |    2 +-
 .../staging/lustre/lustre/include/lprocfs_status.h |    2 +-
 drivers/staging/lustre/lustre/include/lu_object.h  |    2 +-
 .../lustre/lustre/include/lustre/ll_fiemap.h       |    2 ++
 .../lustre/lustre/include/lustre/lustre_idl.h      |    2 +-
 .../lustre/lustre/include/lustre/lustre_user.h     |    2 +-
 drivers/staging/lustre/lustre/include/lustre_dlm.h |    2 +-
 .../staging/lustre/lustre/include/lustre_export.h  |    2 +-
 drivers/staging/lustre/lustre/include/lustre_fid.h |    2 +-
 drivers/staging/lustre/lustre/include/lustre_fld.h |    2 +-
 drivers/staging/lustre/lustre/include/lustre_ha.h  |    2 +-
 drivers/staging/lustre/lustre/include/lustre_log.h |    2 +-
 drivers/staging/lustre/lustre/include/lustre_net.h |    2 +-
 .../staging/lustre/lustre/include/lustre_param.h   |    2 +-
 .../lustre/lustre/include/lustre_req_layout.h      |    2 +-
 drivers/staging/lustre/lustre/include/obd.h        |    2 +-
 drivers/staging/lustre/lustre/include/obd_class.h  |    2 +-
 .../staging/lustre/lustre/include/obd_support.h    |    2 +-
 drivers/staging/lustre/lustre/lclient/lcommon_cl.c |    2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |    2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |    2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |    2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |    2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |    2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |    2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    2 +-
 drivers/staging/lustre/lustre/libcfs/fail.c        |    2 +-
 drivers/staging/lustre/lustre/libcfs/libcfs_lock.c |    2 +-
 .../staging/lustre/lustre/libcfs/libcfs_string.c   |    2 +-
 .../staging/lustre/lustre/libcfs/linux/linux-cpu.c |    3 ++-
 .../lustre/lustre/libcfs/linux/linux-curproc.c     |    2 +-
 drivers/staging/lustre/lustre/libcfs/module.c      |    2 +-
 drivers/staging/lustre/lustre/llite/dcache.c       |    2 +-
 drivers/staging/lustre/lustre/llite/dir.c          |    2 +-
 drivers/staging/lustre/lustre/llite/file.c         |    2 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    2 +-
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |    2 +-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |    2 +-
 drivers/staging/lustre/lustre/llite/namei.c        |    2 +-
 drivers/staging/lustre/lustre/llite/rw.c           |    2 +-
 drivers/staging/lustre/lustre/llite/statahead.c    |    2 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |    2 +-
 drivers/staging/lustre/lustre/llite/vvp_internal.h |    2 ++
 drivers/staging/lustre/lustre/llite/vvp_io.c       |    2 +-
 drivers/staging/lustre/lustre/llite/vvp_lock.c     |    2 ++
 drivers/staging/lustre/lustre/llite/vvp_object.c   |    2 +-
 drivers/staging/lustre/lustre/llite/vvp_page.c     |    2 +-
 drivers/staging/lustre/lustre/llite/xattr.c        |    2 +-
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |    2 ++
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |    2 +-
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |    2 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    2 +-
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |    2 +-
 drivers/staging/lustre/lustre/lov/lov_dev.c        |    2 +-
 drivers/staging/lustre/lustre/lov/lov_ea.c         |    2 +-
 drivers/staging/lustre/lustre/lov/lov_internal.h   |    2 +-
 drivers/staging/lustre/lustre/lov/lov_io.c         |    2 +-
 drivers/staging/lustre/lustre/lov/lov_merge.c      |    2 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    2 +-
 drivers/staging/lustre/lustre/lov/lov_object.c     |    2 +-
 drivers/staging/lustre/lustre/lov/lov_offset.c     |    2 +-
 drivers/staging/lustre/lustre/lov/lov_pack.c       |    2 +-
 drivers/staging/lustre/lustre/lov/lov_page.c       |    2 +-
 drivers/staging/lustre/lustre/lov/lov_request.c    |    2 +-
 drivers/staging/lustre/lustre/lov/lovsub_dev.c     |    2 ++
 drivers/staging/lustre/lustre/lov/lovsub_object.c  |    2 +-
 drivers/staging/lustre/lustre/lov/lproc_lov.c      |    2 +-
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c      |    2 +-
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |    2 +-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |    2 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |    2 +-
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |    2 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    2 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    2 +-
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |    2 +-
 drivers/staging/lustre/lustre/obdclass/cl_object.c |    2 +-
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |    2 +-
 drivers/staging/lustre/lustre/obdclass/class_obd.c |    2 +-
 drivers/staging/lustre/lustre/obdclass/genops.c    |    2 +-
 .../lustre/lustre/obdclass/linux/linux-sysctl.c    |    2 +-
 drivers/staging/lustre/lustre/obdclass/llog.c      |    2 +-
 drivers/staging/lustre/lustre/obdclass/llog_cat.c  |    2 +-
 .../staging/lustre/lustre/obdclass/llog_internal.h |    2 +-
 drivers/staging/lustre/lustre/obdclass/llog_obd.c  |    2 +-
 drivers/staging/lustre/lustre/obdclass/llog_swab.c |    2 +-
 .../lustre/lustre/obdclass/lprocfs_status.c        |    2 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    2 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |    2 +-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |    2 +-
 .../staging/lustre/lustre/obdecho/echo_client.c    |    2 +-
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |    2 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |    2 +-
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |    2 +-
 drivers/staging/lustre/lustre/osc/osc_dev.c        |    2 +-
 drivers/staging/lustre/lustre/osc/osc_internal.h   |    2 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |    2 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       |    2 +-
 drivers/staging/lustre/lustre/osc/osc_object.c     |    2 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       |    2 +-
 drivers/staging/lustre/lustre/osc/osc_quota.c      |    2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/events.c      |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/import.c      |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/llog_client.c |    2 +-
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/pers.c        |    2 ++
 drivers/staging/lustre/lustre/ptlrpc/pinger.c      |    2 +-
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/recover.c     |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c  |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c   |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |    2 +-
 144 files changed, 152 insertions(+), 138 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 4d74e8a..049f6a9 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
index 7878678..1530b04 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
@@ -22,7 +22,8 @@
  */
 /*
  * Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved.
- * Copyright (c) 2012, Intel Corporation.
+ *
+ * Copyright (c) 2012, 2015 Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index f14db92..c3f2332 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015 Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index b61d504..b67a660 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -23,7 +23,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012 - 2015, Intel Corporation.
+ * Copyright (c) 2012, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index d792c4a..3bb9468 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -23,7 +23,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012 - 2015, Intel Corporation.
+ * Copyright (c) 2012, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/include/linux/lnet/nidstr.h b/drivers/staging/lustre/include/linux/lnet/nidstr.h
index 46ad914..4fc9ddc 100644
--- a/drivers/staging/lustre/include/linux/lnet/nidstr.h
+++ b/drivers/staging/lustre/include/linux/lnet/nidstr.h
@@ -23,7 +23,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011 - 2015, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 #ifndef _LNET_NIDSTRINGS_H
 #define _LNET_NIDSTRINGS_H
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index de0f85f..72af486 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 5f78b42..55bf30d 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 8989e36..3389688 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index ebde036..05aa90e 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index 92ca1dd..fed57d9 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 284150f..41e0a91 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index 5390ee9..284a3c2 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 5631f60..919410d 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
index b4f573a..bd7b071 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
@@ -21,7 +21,7 @@
  * GPL HEADER END
  */
 /*
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index 6f7ef4c..589ecc8 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -23,7 +23,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2015 Intel Corporation.
+ * Copyright (c) 2012, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
index ac2fdf0..c93c007 100644
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ b/drivers/staging/lustre/lnet/lnet/module.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index fe49f1b..d98941d 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -1,7 +1,7 @@
 /*
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  *
  *   This file is part of Portals
  *   http://sourceforge.net/projects/sandiaportals/
diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index 0f26226..1f04cc1 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 752e614..544b8e1 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index fe7c39a..ff8f38d 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2013, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/fid/lproc_fid.c b/drivers/staging/lustre/lustre/fid/lproc_fid.c
index ce90c1c..39f2aa3 100644
--- a/drivers/staging/lustre/lustre/fid/lproc_fid.c
+++ b/drivers/staging/lustre/lustre/fid/lproc_fid.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/fld/fld_internal.h b/drivers/staging/lustre/lustre/fld/fld_internal.h
index 959b8e6..12eb164 100644
--- a/drivers/staging/lustre/lustre/fld/fld_internal.h
+++ b/drivers/staging/lustre/lustre/fld/fld_internal.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2013, Intel Corporation.
+ * Copyright (c) 2012, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index 469df68..d92c01b 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2013, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/fld/lproc_fld.c b/drivers/staging/lustre/lustre/fld/lproc_fld.c
index 603f56e..41ceaa8 100644
--- a/drivers/staging/lustre/lustre/fld/lproc_fld.c
+++ b/drivers/staging/lustre/lustre/fld/lproc_fld.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2013, Intel Corporation.
+ * Copyright (c) 2012, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 73564f8..1e7391a 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index f18c0c7..0ac8e0e 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index fa78689..1d79341 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/include/lustre/ll_fiemap.h b/drivers/staging/lustre/lustre/include/lustre/ll_fiemap.h
index 06ce8c9..09088f4 100644
--- a/drivers/staging/lustre/lustre/include/lustre/ll_fiemap.h
+++ b/drivers/staging/lustre/lustre/include/lustre/ll_fiemap.h
@@ -26,6 +26,8 @@
 /*
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
+ *
+ * Copyright (c) 2014, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 0b721c6..b064b58 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 80f8ec5..2b4dd65 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2010, 2012, Intel Corporation.
+ * Copyright (c) 2010, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 138479a..9b319f1 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2010, 2012, Intel Corporation.
+ * Copyright (c) 2010, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/include/lustre_export.h b/drivers/staging/lustre/lustre/include/lustre_export.h
index 1daf4c5..311e5aa 100644
--- a/drivers/staging/lustre/lustre/include/lustre_export.h
+++ b/drivers/staging/lustre/lustre/include/lustre_export.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index 47c3f37..9b1a9c6 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/include/lustre_fld.h b/drivers/staging/lustre/lustre/include/lustre_fld.h
index d8b3db9..5511626 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fld.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fld.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2013, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/include/lustre_ha.h b/drivers/staging/lustre/lustre/include/lustre_ha.h
index 49dfbb1..5488a69 100644
--- a/drivers/staging/lustre/lustre/include/lustre_ha.h
+++ b/drivers/staging/lustre/lustre/include/lustre_ha.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/include/lustre_log.h b/drivers/staging/lustre/lustre/include/lustre_log.h
index 1de0c4d..53af4cd 100644
--- a/drivers/staging/lustre/lustre/include/lustre_log.h
+++ b/drivers/staging/lustre/lustre/include/lustre_log.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 0127f45..d834ddd 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2010, 2012, Intel Corporation.
+ * Copyright (c) 2010, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/include/lustre_param.h b/drivers/staging/lustre/lustre/include/lustre_param.h
index 8f6c0b2..383fe6f 100644
--- a/drivers/staging/lustre/lustre/include/lustre_param.h
+++ b/drivers/staging/lustre/lustre/include/lustre_param.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/include/lustre_req_layout.h b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
index df292f6..46a662f 100644
--- a/drivers/staging/lustre/lustre/include/lustre_req_layout.h
+++ b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 5c90b59..bcbe613 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 0b7e90a..97d8039 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index a22a530..d031437 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/lclient/lcommon_cl.c b/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
index 12c7f0e..34dde7d 100644
--- a/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index db3c9b7..849cc98 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index ccce1e5..3c8d441 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2010, 2012, Intel Corporation.
+ * Copyright (c) 2010, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 7f8c700..cf9ec0c 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2010, 2012, Intel Corporation.
+ * Copyright (c) 2010, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index ca11511..79aeb2b 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2010, 2012, Intel Corporation.
+ * Copyright (c) 2010, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index e59b286..3d7c137 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2010, 2012, Intel Corporation.
+ * Copyright (c) 2010, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index fdf81b8..b9eb377 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2010, 2012, Intel Corporation.
+ * Copyright (c) 2010, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index b55a4f0..0ae6100 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2010, 2012, Intel Corporation.
+ * Copyright (c) 2010, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/libcfs/fail.c b/drivers/staging/lustre/lustre/libcfs/fail.c
index ea059b0..2783143 100644
--- a/drivers/staging/lustre/lustre/libcfs/fail.c
+++ b/drivers/staging/lustre/lustre/libcfs/fail.c
@@ -26,7 +26,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_lock.c b/drivers/staging/lustre/lustre/libcfs/libcfs_lock.c
index 94bc007..15782d9 100644
--- a/drivers/staging/lustre/lustre/libcfs/libcfs_lock.c
+++ b/drivers/staging/lustre/lustre/libcfs/libcfs_lock.c
@@ -21,7 +21,7 @@
  * GPL HEADER END
  */
 /* Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved.
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015 Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
index d40be53..205a3ed 100644
--- a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015 Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c
index 58a4034..e52afe3 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c
@@ -22,7 +22,8 @@
  */
 /*
  * Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved.
- * Copyright (c) 2012, Intel Corporation.
+ *
+ * Copyright (c) 2012, 2015 Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-curproc.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-curproc.c
index c74c809..68515d9 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-curproc.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-curproc.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/libcfs/module.c b/drivers/staging/lustre/lustre/libcfs/module.c
index 570f05c..9224607 100644
--- a/drivers/staging/lustre/lustre/libcfs/module.c
+++ b/drivers/staging/lustre/lustre/libcfs/module.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015 Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging/lustre/lustre/llite/dcache.c
index 80cba04..3d6745e 100644
--- a/drivers/staging/lustre/lustre/llite/dcache.c
+++ b/drivers/staging/lustre/lustre/llite/dcache.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 5c2ef92..7b35531 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 02f2759..baffd52 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 157c328..eb8d6a7 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 4a8c759..1db93af 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index 7df9783..bbae95c 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 190fc44..f134ad9 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 2ca2200..14370b9 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index f79193f..465e2f6 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 18f5f2b..e87aa12 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index d16d6cf..fdca4ec 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index b5a6661..2e39533 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -26,6 +26,8 @@
 /*
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
+ *
+ * Copyright (c) 2013, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 37773c1..346b8a1 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/llite/vvp_lock.c b/drivers/staging/lustre/lustre/llite/vvp_lock.c
index f7b1144..ff09480 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_lock.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_lock.c
@@ -26,6 +26,8 @@
 /*
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
+ *
+ * Copyright (c) 2014, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index e13afb7..c82714e 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index 92f60c3..99c0d7a 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 4b7eb33..92f579e 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/llite/xattr_cache.c b/drivers/staging/lustre/lustre/llite/xattr_cache.c
index e1e599c..d140276 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_cache.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_cache.c
@@ -1,6 +1,8 @@
 /*
  * Copyright 2012 Xyratex Technology Limited
  *
+ * Copyright (c) 2013, 2015, Intel Corporation.
+ *
  * Author: Andrew Perepechko <Andrew_Perepechko@xyratex.com>
  *
  */
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index 3c585ae..66de27f 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index 467cfb3..eb8e673 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index a4de9a3..bbafe0a 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index 1c0fe65..66a2492 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015 Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/lov/lov_dev.c b/drivers/staging/lustre/lustre/lov/lov_dev.c
index 2e8b566..3733fdc 100644
--- a/drivers/staging/lustre/lustre/lov/lov_dev.c
+++ b/drivers/staging/lustre/lustre/lov/lov_dev.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index 34c1346..b3c9c85 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index b802873..2d00bad 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 5e6228b..93fe69e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/lov/lov_merge.c b/drivers/staging/lustre/lustre/lov/lov_merge.c
index dd1cf3d..97115be 100644
--- a/drivers/staging/lustre/lustre/lov/lov_merge.c
+++ b/drivers/staging/lustre/lustre/lov/lov_merge.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2005, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index b52609a..6c2bdfe 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index c7ff817..3b79ebc 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/lov/lov_offset.c b/drivers/staging/lustre/lustre/lov/lov_offset.c
index 9c8c77c..aa520aa 100644
--- a/drivers/staging/lustre/lustre/lov/lov_offset.c
+++ b/drivers/staging/lustre/lustre/lov/lov_offset.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2005, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 2fb1e97..1985231 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/lov/lov_page.c b/drivers/staging/lustre/lustre/lov/lov_page.c
index 463cadb..037ae91 100644
--- a/drivers/staging/lustre/lustre/lov/lov_page.c
+++ b/drivers/staging/lustre/lustre/lov/lov_page.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index bb1a03f..42deda7 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2005, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_dev.c b/drivers/staging/lustre/lustre/lov/lovsub_dev.c
index 8bc04c8..f1795c3 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_dev.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_dev.c
@@ -26,6 +26,8 @@
 /*
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
+ *
+ * Copyright (c) 2013, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_object.c b/drivers/staging/lustre/lustre/lov/lovsub_object.c
index d775e28..5ba5ee1 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_object.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_object.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015 Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/lov/lproc_lov.c b/drivers/staging/lustre/lustre/lov/lproc_lov.c
index a0be15c..337241d 100644
--- a/drivers/staging/lustre/lustre/lov/lproc_lov.c
+++ b/drivers/staging/lustre/lustre/lov/lproc_lov.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015 Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
index 1c95f87..5a441bb 100644
--- a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
+++ b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index df50bdb..3d2997a 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, Intel Corporation.
+ * Copyright (c) 2011, 2015 Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index 227fc9e..7218532 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index d4bf34b..ef9a1e1 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index c87c7d8..ac7695a 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 294c050..c06a6e1 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2001, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 69b2364..aff0791 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index e67cea7..ab7e110 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index a1a6024..73ea845 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index 2f569ed..61f28eb 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index beb59f0..0975e44 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -27,7 +27,7 @@
  * Copyright (c) 1999, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 26f54f9..228c44c 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -27,7 +27,7 @@
  * Copyright (c) 1999, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
index 518288d..42fc26f 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
@@ -27,7 +27,7 @@
  * Copyright (c) 1999, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index 7cb55ef..f956d7e 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_cat.c b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
index c442cae..0f05e9c 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_cat.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_internal.h b/drivers/staging/lustre/lustre/obdclass/llog_internal.h
index b9fe4b0..7fb48dd 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_internal.h
+++ b/drivers/staging/lustre/lustre/obdclass/llog_internal.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_obd.c b/drivers/staging/lustre/lustre/obdclass/llog_obd.c
index 3900b9d..9bc5199 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_obd.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_swab.c b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
index 9354f75..3aa7393 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_swab.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2005, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index dda5ad1..51fe15f 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 0193608..76ad9dc 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index c231e0d..49cdc64 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 7617c57..b5aa816 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 35a2f59..7dc6e2e 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index c4d44e7..1091536 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index cfb83bc..5a6a305 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015, Intel Corporation.
  *
  */
 /*
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index d2d6845..415c27e 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/osc/osc_dev.c b/drivers/staging/lustre/lustre/osc/osc_dev.c
index 69b523c..7078cc5 100644
--- a/drivers/staging/lustre/lustre/osc/osc_dev.c
+++ b/drivers/staging/lustre/lustre/osc/osc_dev.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index db2ee9c..a4c6146 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index d413496..abd0beb 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 194490d..71f2810 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index ba57f8d..c29a0d4 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 61eaf71..2439d80 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/osc/osc_quota.c b/drivers/staging/lustre/lustre/osc/osc_quota.c
index 1997831..e70e796 100644
--- a/drivers/staging/lustre/lustre/osc/osc_quota.c
+++ b/drivers/staging/lustre/lustre/osc/osc_quota.c
@@ -23,7 +23,7 @@
 /*
  * Copyright (c) 2009, 2010, Oracle and/or its affiliates. All rights reserved.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  *
  * Code originally extracted from quota directory
  */
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index d6c1447..b2642a7 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index a9f1bf5..efdda09 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index 9c2fd34..9901569 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015 Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index bfa410f..f752c78 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index d7c4f47..c0e613c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
index 5122205..e877020 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index 2aecab2..cc55b79 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index 09ddeef..c5d7ff5 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pers.c b/drivers/staging/lustre/lustre/ptlrpc/pers.c
index 2a2a9fb..ec3af10 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pers.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pers.c
@@ -26,6 +26,8 @@
 /*
  * Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
+ *
+ * Copyright (c) 2014, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
index 5c719f1..fb2d523 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pinger.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
index 833ed94..8f67e05 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
@@ -27,7 +27,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index ac87aa1..60fb0ce 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index 7b1d729..db6626c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index cd8a998..6152c1b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
index 7a20670..4b0b81c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
index f448b45..905a414 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index f45898f..8598300 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2010, 2012, Intel Corporation.
+ * Copyright (c) 2010, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 40f720c..61d9ca9 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -27,7 +27,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, Intel Corporation.
+ * Copyright (c) 2011, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
-- 
1.7.1
