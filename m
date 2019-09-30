From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:54 -0400
Subject: [lustre-devel] [PATCH 095/151] lustre: misc: update Intel copyright
 messages for 2017
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-96-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Update copyright messages for files updated in 2016, excluding
trivial patches. This brings use closely to the OpenSFS tree.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10308
Lustre-commit: ccabce23bd9e ("LU-10308 misc: update Intel copyright messages for 2017")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/30341
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: James Nunez <jnunez@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/fid/fid_internal.h               | 2 +-
 fs/lustre/fid/fid_request.c                | 2 +-
 fs/lustre/fid/lproc_fid.c                  | 2 +-
 fs/lustre/include/cl_object.h              | 2 +-
 fs/lustre/include/lprocfs_status.h         | 2 +-
 fs/lustre/include/lu_object.h              | 2 +-
 fs/lustre/include/lu_ref.h                 | 2 +-
 fs/lustre/include/lustre_acl.h             | 2 ++
 fs/lustre/include/lustre_disk.h            | 2 +-
 fs/lustre/include/lustre_dlm.h             | 2 +-
 fs/lustre/include/lustre_export.h          | 2 +-
 fs/lustre/include/lustre_fid.h             | 2 +-
 fs/lustre/include/lustre_handles.h         | 2 +-
 fs/lustre/include/lustre_import.h          | 2 +-
 fs/lustre/include/lustre_kernelcomm.h      | 2 +-
 fs/lustre/include/lustre_lib.h             | 2 +-
 fs/lustre/include/lustre_linkea.h          | 2 +-
 fs/lustre/include/lustre_log.h             | 2 +-
 fs/lustre/include/lustre_mdc.h             | 2 +-
 fs/lustre/include/lustre_mds.h             | 2 +-
 fs/lustre/include/lustre_net.h             | 2 +-
 fs/lustre/include/lustre_osc.h             | 2 +-
 fs/lustre/include/lustre_req_layout.h      | 2 +-
 fs/lustre/include/lustre_sec.h             | 2 +-
 fs/lustre/include/lustre_swab.h            | 2 +-
 fs/lustre/include/obd.h                    | 2 +-
 fs/lustre/include/obd_class.h              | 2 +-
 fs/lustre/include/obd_support.h            | 2 +-
 fs/lustre/ldlm/ldlm_extent.c               | 2 +-
 fs/lustre/ldlm/ldlm_flock.c                | 2 +-
 fs/lustre/ldlm/ldlm_internal.h             | 2 +-
 fs/lustre/ldlm/ldlm_lib.c                  | 2 +-
 fs/lustre/ldlm/ldlm_lock.c                 | 2 +-
 fs/lustre/ldlm/ldlm_lockd.c                | 2 +-
 fs/lustre/ldlm/ldlm_plain.c                | 2 +-
 fs/lustre/ldlm/ldlm_pool.c                 | 2 +-
 fs/lustre/ldlm/ldlm_request.c              | 2 +-
 fs/lustre/ldlm/ldlm_resource.c             | 2 +-
 fs/lustre/llite/dcache.c                   | 2 +-
 fs/lustre/llite/dir.c                      | 2 +-
 fs/lustre/llite/file.c                     | 2 +-
 fs/lustre/llite/glimpse.c                  | 2 +-
 fs/lustre/llite/lcommon_cl.c               | 2 +-
 fs/lustre/llite/lcommon_misc.c             | 2 +-
 fs/lustre/llite/llite_internal.h           | 2 +-
 fs/lustre/llite/llite_lib.c                | 2 +-
 fs/lustre/llite/llite_nfs.c                | 2 +-
 fs/lustre/llite/lproc_llite.c              | 2 +-
 fs/lustre/llite/namei.c                    | 2 +-
 fs/lustre/llite/rw.c                       | 2 +-
 fs/lustre/llite/rw26.c                     | 2 +-
 fs/lustre/llite/statahead.c                | 2 +-
 fs/lustre/llite/vvp_internal.h             | 2 +-
 fs/lustre/llite/vvp_io.c                   | 2 +-
 fs/lustre/llite/vvp_object.c               | 2 +-
 fs/lustre/llite/vvp_page.c                 | 2 +-
 fs/lustre/llite/xattr.c                    | 2 +-
 fs/lustre/llite/xattr_cache.c              | 2 +-
 fs/lustre/lmv/lmv_intent.c                 | 2 +-
 fs/lustre/lmv/lmv_internal.h               | 2 +-
 fs/lustre/lmv/lmv_obd.c                    | 2 +-
 fs/lustre/lmv/lproc_lmv.c                  | 2 +-
 fs/lustre/lov/lov_cl_internal.h            | 2 +-
 fs/lustre/lov/lov_dev.c                    | 2 +-
 fs/lustre/lov/lov_ea.c                     | 2 +-
 fs/lustre/lov/lov_internal.h               | 2 +-
 fs/lustre/lov/lov_io.c                     | 2 +-
 fs/lustre/lov/lov_lock.c                   | 2 +-
 fs/lustre/lov/lov_merge.c                  | 2 +-
 fs/lustre/lov/lov_obd.c                    | 2 +-
 fs/lustre/lov/lov_object.c                 | 2 +-
 fs/lustre/lov/lov_offset.c                 | 2 +-
 fs/lustre/lov/lov_pack.c                   | 2 +-
 fs/lustre/lov/lov_page.c                   | 2 +-
 fs/lustre/lov/lov_pool.c                   | 2 +-
 fs/lustre/lov/lproc_lov.c                  | 2 +-
 fs/lustre/mdc/lproc_mdc.c                  | 2 +-
 fs/lustre/mdc/mdc_changelog.c              | 2 ++
 fs/lustre/mdc/mdc_dev.c                    | 2 +-
 fs/lustre/mdc/mdc_internal.h               | 2 +-
 fs/lustre/mdc/mdc_lib.c                    | 2 +-
 fs/lustre/mdc/mdc_locks.c                  | 2 +-
 fs/lustre/mdc/mdc_reint.c                  | 2 +-
 fs/lustre/mdc/mdc_request.c                | 2 +-
 fs/lustre/mgc/lproc_mgc.c                  | 2 +-
 fs/lustre/mgc/mgc_internal.h               | 2 +-
 fs/lustre/mgc/mgc_request.c                | 2 +-
 fs/lustre/obdclass/cl_internal.h           | 2 +-
 fs/lustre/obdclass/cl_io.c                 | 2 +-
 fs/lustre/obdclass/cl_lock.c               | 2 +-
 fs/lustre/obdclass/cl_object.c             | 2 +-
 fs/lustre/obdclass/cl_page.c               | 2 +-
 fs/lustre/obdclass/class_obd.c             | 2 +-
 fs/lustre/obdclass/genops.c                | 2 +-
 fs/lustre/obdclass/kernelcomm.c            | 2 +-
 fs/lustre/obdclass/linkea.c                | 2 +-
 fs/lustre/obdclass/llog.c                  | 2 +-
 fs/lustre/obdclass/llog_cat.c              | 2 +-
 fs/lustre/obdclass/llog_internal.h         | 2 +-
 fs/lustre/obdclass/llog_swab.c             | 2 +-
 fs/lustre/obdclass/lprocfs_status.c        | 2 +-
 fs/lustre/obdclass/lu_object.c             | 2 +-
 fs/lustre/obdclass/lu_ref.c                | 2 +-
 fs/lustre/obdclass/lustre_handles.c        | 2 +-
 fs/lustre/obdclass/lustre_peer.c           | 2 +-
 fs/lustre/obdclass/obd_config.c            | 2 +-
 fs/lustre/obdclass/obd_mount.c             | 2 +-
 fs/lustre/obdclass/obd_sysfs.c             | 2 +-
 fs/lustre/obdclass/obdo.c                  | 2 +-
 fs/lustre/obdecho/debug.c                  | 2 +-
 fs/lustre/obdecho/echo_client.c            | 2 +-
 fs/lustre/osc/lproc_osc.c                  | 2 +-
 fs/lustre/osc/osc_cache.c                  | 2 +-
 fs/lustre/osc/osc_dev.c                    | 2 +-
 fs/lustre/osc/osc_internal.h               | 2 +-
 fs/lustre/osc/osc_io.c                     | 2 +-
 fs/lustre/osc/osc_lock.c                   | 2 +-
 fs/lustre/osc/osc_object.c                 | 2 +-
 fs/lustre/osc/osc_page.c                   | 2 +-
 fs/lustre/osc/osc_quota.c                  | 2 +-
 fs/lustre/osc/osc_request.c                | 2 +-
 fs/lustre/ptlrpc/client.c                  | 2 +-
 fs/lustre/ptlrpc/events.c                  | 2 +-
 fs/lustre/ptlrpc/import.c                  | 2 +-
 fs/lustre/ptlrpc/layout.c                  | 2 +-
 fs/lustre/ptlrpc/llog_net.c                | 2 +-
 fs/lustre/ptlrpc/lproc_ptlrpc.c            | 2 +-
 fs/lustre/ptlrpc/niobuf.c                  | 2 +-
 fs/lustre/ptlrpc/pack_generic.c            | 2 +-
 fs/lustre/ptlrpc/ptlrpc_internal.h         | 2 +-
 fs/lustre/ptlrpc/ptlrpc_module.c           | 2 +-
 fs/lustre/ptlrpc/ptlrpcd.c                 | 2 +-
 fs/lustre/ptlrpc/recover.c                 | 2 +-
 fs/lustre/ptlrpc/sec.c                     | 2 +-
 fs/lustre/ptlrpc/sec_bulk.c                | 2 +-
 fs/lustre/ptlrpc/sec_config.c              | 2 +-
 fs/lustre/ptlrpc/sec_gc.c                  | 2 +-
 fs/lustre/ptlrpc/sec_null.c                | 2 +-
 fs/lustre/ptlrpc/sec_plain.c               | 2 +-
 fs/lustre/ptlrpc/service.c                 | 2 +-
 include/linux/libcfs/libcfs.h              | 2 +-
 include/linux/libcfs/libcfs_cpu.h          | 2 +-
 include/linux/libcfs/libcfs_debug.h        | 2 +-
 include/linux/libcfs/libcfs_hash.h         | 2 +-
 include/linux/libcfs/libcfs_private.h      | 2 +-
 include/linux/libcfs/libcfs_string.h       | 2 +-
 include/linux/lnet/api.h                   | 2 +-
 include/linux/lnet/lib-lnet.h              | 2 +-
 include/linux/lnet/lib-types.h             | 2 +-
 include/uapi/linux/lnet/libcfs_debug.h     | 2 +-
 include/uapi/linux/lnet/libcfs_ioctl.h     | 2 ++
 include/uapi/linux/lnet/lnet-dlc.h         | 2 +-
 include/uapi/linux/lnet/lnet-types.h       | 2 +-
 include/uapi/linux/lnet/lnetctl.h          | 3 +++
 include/uapi/linux/lnet/nidstr.h           | 2 +-
 include/uapi/linux/lustre/lustre_fid.h     | 2 +-
 include/uapi/linux/lustre/lustre_idl.h     | 2 +-
 include/uapi/linux/lustre/lustre_ioctl.h   | 2 +-
 include/uapi/linux/lustre/lustre_ostid.h   | 2 +-
 include/uapi/linux/lustre/lustre_user.h    | 2 +-
 net/lnet/klnds/o2iblnd/o2iblnd.c           | 2 +-
 net/lnet/klnds/o2iblnd/o2iblnd.h           | 2 +-
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c        | 2 +-
 net/lnet/klnds/o2iblnd/o2iblnd_modparams.c | 2 +-
 net/lnet/klnds/socklnd/socklnd.c           | 2 +-
 net/lnet/klnds/socklnd/socklnd.h           | 2 +-
 net/lnet/klnds/socklnd/socklnd_cb.c        | 2 +-
 net/lnet/klnds/socklnd/socklnd_lib.c       | 2 +-
 net/lnet/klnds/socklnd/socklnd_proto.c     | 2 +-
 net/lnet/libcfs/debug.c                    | 2 +-
 net/lnet/libcfs/libcfs_cpu.c               | 2 +-
 net/lnet/libcfs/libcfs_string.c            | 2 +-
 net/lnet/libcfs/module.c                   | 2 +-
 net/lnet/libcfs/tracefile.c                | 2 +-
 net/lnet/libcfs/tracefile.h                | 2 +-
 net/lnet/lnet/acceptor.c                   | 2 +-
 net/lnet/lnet/api-ni.c                     | 2 +-
 net/lnet/lnet/config.c                     | 2 +-
 net/lnet/lnet/lib-md.c                     | 2 +-
 net/lnet/lnet/lib-move.c                   | 2 +-
 net/lnet/lnet/lib-msg.c                    | 2 +-
 net/lnet/lnet/lib-ptl.c                    | 2 +-
 net/lnet/lnet/lib-socket.c                 | 2 +-
 net/lnet/lnet/lo.c                         | 2 ++
 net/lnet/lnet/module.c                     | 2 +-
 net/lnet/lnet/net_fault.c                  | 2 +-
 net/lnet/lnet/nidstrings.c                 | 2 +-
 net/lnet/lnet/peer.c                       | 2 +-
 net/lnet/lnet/router.c                     | 2 +-
 net/lnet/lnet/router_proc.c                | 2 +-
 net/lnet/selftest/brw_test.c               | 2 +-
 net/lnet/selftest/framework.c              | 2 +-
 net/lnet/selftest/rpc.c                    | 2 +-
 net/lnet/selftest/selftest.h               | 2 +-
 194 files changed, 200 insertions(+), 189 deletions(-)

diff --git a/fs/lustre/fid/fid_internal.h b/fs/lustre/fid/fid_internal.h
index 14569e9..7bb1283 100644
--- a/fs/lustre/fid/fid_internal.h
+++ b/fs/lustre/fid/fid_internal.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2014 Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/fid/fid_request.c b/fs/lustre/fid/fid_request.c
index cdf5402..861ffbe 100644
--- a/fs/lustre/fid/fid_request.c
+++ b/fs/lustre/fid/fid_request.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/fid/lproc_fid.c b/fs/lustre/fid/lproc_fid.c
index e2e47df..19c05ad 100644
--- a/fs/lustre/fid/lproc_fid.c
+++ b/fs/lustre/fid/lproc_fid.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 946e6e1..1088fde 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/include/lprocfs_status.h b/fs/lustre/include/lprocfs_status.h
index 54e4eda..10d541f 100644
--- a/fs/lustre/include/lprocfs_status.h
+++ b/fs/lustre/include/lprocfs_status.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index 9427ad4..a938e64 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/include/lu_ref.h b/fs/lustre/include/lu_ref.h
index ad0c24d..493df95 100644
--- a/fs/lustre/include/lu_ref.h
+++ b/fs/lustre/include/lu_ref.h
@@ -3,7 +3,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2013, Intel Corporation.
  *
  *   Author: Nikita Danilov <nikita.danilov@sun.com>
  *
diff --git a/fs/lustre/include/lustre_acl.h b/fs/lustre/include/lustre_acl.h
index aff77b0..067ed3f 100644
--- a/fs/lustre/include/lustre_acl.h
+++ b/fs/lustre/include/lustre_acl.h
@@ -23,6 +23,8 @@
 /*
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
+ *
+ * Copyright (c) 2014, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/include/lustre_disk.h b/fs/lustre/include/lustre_disk.h
index 07c074e..8b4a243 100644
--- a/fs/lustre/include/lustre_disk.h
+++ b/fs/lustre/include/lustre_disk.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index fbcd981..b1a37f0 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2010, 2015, Intel Corporation.
+ * Copyright (c) 2010, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/include/lustre_export.h b/fs/lustre/include/lustre_export.h
index 9e2878e..544166f 100644
--- a/fs/lustre/include/lustre_export.h
+++ b/fs/lustre/include/lustre_export.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/include/lustre_fid.h b/fs/lustre/include/lustre_fid.h
index b469295..e257ad5 100644
--- a/fs/lustre/include/lustre_fid.h
+++ b/fs/lustre/include/lustre_fid.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/include/lustre_handles.h b/fs/lustre/include/lustre_handles.h
index 6836808..d4ec795 100644
--- a/fs/lustre/include/lustre_handles.h
+++ b/fs/lustre/include/lustre_handles.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2012, 2014, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/include/lustre_import.h b/fs/lustre/include/lustre_import.h
index d9a8d9a..6a2d402 100644
--- a/fs/lustre/include/lustre_import.h
+++ b/fs/lustre/include/lustre_import.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2016, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/include/lustre_kernelcomm.h b/fs/lustre/include/lustre_kernelcomm.h
index 2c8ce19..bd5376b 100644
--- a/fs/lustre/include/lustre_kernelcomm.h
+++ b/fs/lustre/include/lustre_kernelcomm.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2009, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2013 Intel Corporation.
+ * Copyright (c) 2013, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/include/lustre_lib.h b/fs/lustre/include/lustre_lib.h
index 64d2e91..fc4b4c5 100644
--- a/fs/lustre/include/lustre_lib.h
+++ b/fs/lustre/include/lustre_lib.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/include/lustre_linkea.h b/fs/lustre/include/lustre_linkea.h
index a028d91..cd0512b 100644
--- a/fs/lustre/include/lustre_linkea.h
+++ b/fs/lustre/include/lustre_linkea.h
@@ -21,7 +21,7 @@
  * GPL HEADER END
  */
 /*
- * Copyright (c) 2013, 2014, Intel Corporation.
+ * Copyright (c) 2013, 2017, Intel Corporation.
  * Use is subject to license terms.
  *
  * Author: di wang <di.wang@intel.com>
diff --git a/fs/lustre/include/lustre_log.h b/fs/lustre/include/lustre_log.h
index ab0262c..99c6305 100644
--- a/fs/lustre/include/lustre_log.h
+++ b/fs/lustre/include/lustre_log.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2015, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/include/lustre_mdc.h b/fs/lustre/include/lustre_mdc.h
index 63a7413..208989f 100644
--- a/fs/lustre/include/lustre_mdc.h
+++ b/fs/lustre/include/lustre_mdc.h
@@ -25,7 +25,7 @@
  * Use is subject to license terms.
  */
 /*
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2014, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/include/lustre_mds.h b/fs/lustre/include/lustre_mds.h
index df178cc..18fe0e3 100644
--- a/fs/lustre/include/lustre_mds.h
+++ b/fs/lustre/include/lustre_mds.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2014, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 200422f..baa1eb8 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2010, 2015, Intel Corporation.
+ * Copyright (c) 2010, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index a81e802..cba9d43 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2015, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/include/lustre_req_layout.h b/fs/lustre/include/lustre_req_layout.h
index 48f454c..2348569 100644
--- a/fs/lustre/include/lustre_req_layout.h
+++ b/fs/lustre/include/lustre_req_layout.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/include/lustre_sec.h b/fs/lustre/include/lustre_sec.h
index dabc663..99702fd 100644
--- a/fs/lustre/include/lustre_sec.h
+++ b/fs/lustre/include/lustre_sec.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/include/lustre_swab.h b/fs/lustre/include/lustre_swab.h
index 79cacf4..7e96640 100644
--- a/fs/lustre/include/lustre_swab.h
+++ b/fs/lustre/include/lustre_swab.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2014, Intel Corporation.
+ * Copyright (c) 2017, Intel Corporation.
  *
  * Copyright 2015 Cray Inc, all rights reserved.
  * Author: Ben Evans.
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index f252ff0..309a168 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 38b69e8..f977b2e 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 6a01af4..3e273f8 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ldlm/ldlm_extent.c b/fs/lustre/ldlm/ldlm_extent.c
index 66616b0..77d3e79 100644
--- a/fs/lustre/ldlm/ldlm_extent.c
+++ b/fs/lustre/ldlm/ldlm_extent.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2010, 2012, Intel Corporation.
+ * Copyright (c) 2010, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ldlm/ldlm_flock.c b/fs/lustre/ldlm/ldlm_flock.c
index d2b4f0d..720362f 100644
--- a/fs/lustre/ldlm/ldlm_flock.c
+++ b/fs/lustre/ldlm/ldlm_flock.c
@@ -28,7 +28,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2010, 2012, Intel Corporation.
+ * Copyright (c) 2010, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ldlm/ldlm_internal.h b/fs/lustre/ldlm/ldlm_internal.h
index b9d2e9a..6e54521 100644
--- a/fs/lustre/ldlm/ldlm_internal.h
+++ b/fs/lustre/ldlm/ldlm_internal.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index 3a7b3fb..45dc70d 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2010, 2015, Intel Corporation.
+ * Copyright (c) 2010, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index ef6c5e8..f0657d9 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2010, 2015, Intel Corporation.
+ * Copyright (c) 2010, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index 2c21e7d..7e1ae0c 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2010, 2015, Intel Corporation.
+ * Copyright (c) 2010, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ldlm/ldlm_plain.c b/fs/lustre/ldlm/ldlm_plain.c
index 33b5a3f..e7357ee 100644
--- a/fs/lustre/ldlm/ldlm_plain.c
+++ b/fs/lustre/ldlm/ldlm_plain.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ldlm/ldlm_pool.c b/fs/lustre/ldlm/ldlm_pool.c
index 3dfbde5..25b1ada 100644
--- a/fs/lustre/ldlm/ldlm_pool.c
+++ b/fs/lustre/ldlm/ldlm_pool.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2010, 2015, Intel Corporation.
+ * Copyright (c) 2010, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index eb99279..4c6db33 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2010, 2015, Intel Corporation.
+ * Copyright (c) 2010, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index de0ae1a..4e3c6e7 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2010, 2015, Intel Corporation.
+ * Copyright (c) 2010, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/llite/dcache.c b/fs/lustre/llite/dcache.c
index 11b82c63..2dfe12a 100644
--- a/fs/lustre/llite/dcache.c
+++ b/fs/lustre/llite/dcache.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 8556fa2..d3ef669 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 47e270d..f1db600 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/llite/glimpse.c b/fs/lustre/llite/glimpse.c
index 13a2621..de1a31f 100644
--- a/fs/lustre/llite/glimpse.c
+++ b/fs/lustre/llite/glimpse.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/llite/lcommon_cl.c b/fs/lustre/llite/lcommon_cl.c
index 24e58c2..988855b 100644
--- a/fs/lustre/llite/lcommon_cl.c
+++ b/fs/lustre/llite/lcommon_cl.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/llite/lcommon_misc.c b/fs/lustre/llite/lcommon_misc.c
index cafcb4d..29daf5b 100644
--- a/fs/lustre/llite/lcommon_misc.c
+++ b/fs/lustre/llite/lcommon_misc.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index bdc90bb..ded310b 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 9e4c797..d4ff2bf 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/llite/llite_nfs.c b/fs/lustre/llite/llite_nfs.c
index 64bff0a..d6643d0 100644
--- a/fs/lustre/llite/llite_nfs.c
+++ b/fs/lustre/llite/llite_nfs.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 69f4f25..81c8fe6 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 355a500..1b5e270 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index e2e47174..02b9a0c 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 35d39fe..4d86c4b 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index 2b7015d..99b3fee 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/llite/vvp_internal.h b/fs/lustre/llite/vvp_internal.h
index 923f866..96f10d2 100644
--- a/fs/lustre/llite/vvp_internal.h
+++ b/fs/lustre/llite/vvp_internal.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2013, 2015, Intel Corporation.
+ * Copyright (c) 2013, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index c8a1ff1..6145064 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/llite/vvp_object.c b/fs/lustre/llite/vvp_object.c
index 6606459..c750a80 100644
--- a/fs/lustre/llite/vvp_object.c
+++ b/fs/lustre/llite/vvp_object.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2015, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/llite/vvp_page.c b/fs/lustre/llite/vvp_page.c
index 7b07eae..beebea8 100644
--- a/fs/lustre/llite/vvp_page.c
+++ b/fs/lustre/llite/vvp_page.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/llite/xattr.c b/fs/lustre/llite/xattr.c
index d604c5b..378c190 100644
--- a/fs/lustre/llite/xattr.c
+++ b/fs/lustre/llite/xattr.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/llite/xattr_cache.c b/fs/lustre/llite/xattr_cache.c
index 001bdba..c642444 100644
--- a/fs/lustre/llite/xattr_cache.c
+++ b/fs/lustre/llite/xattr_cache.c
@@ -2,7 +2,7 @@
 /*
  * Copyright 2012 Xyratex Technology Limited
  *
- * Copyright (c) 2013, 2015, Intel Corporation.
+ * Copyright (c) 2013, 2017, Intel Corporation.
  *
  * Author: Andrew Perepechko <Andrew_Perepechko@xyratex.com>
  *
diff --git a/fs/lustre/lmv/lmv_intent.c b/fs/lustre/lmv/lmv_intent.c
index 818bb72..355a2af 100644
--- a/fs/lustre/lmv/lmv_intent.c
+++ b/fs/lustre/lmv/lmv_intent.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2016, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/lmv/lmv_internal.h b/fs/lustre/lmv/lmv_internal.h
index c0881ff..6794f11 100644
--- a/fs/lustre/lmv/lmv_internal.h
+++ b/fs/lustre/lmv/lmv_internal.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2016, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index b6459f5..9a1064b 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/lmv/lproc_lmv.c b/fs/lustre/lmv/lproc_lmv.c
index e40473c..170ed564 100644
--- a/fs/lustre/lmv/lproc_lmv.c
+++ b/fs/lustre/lmv/lproc_lmv.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/lov/lov_cl_internal.h b/fs/lustre/lov/lov_cl_internal.h
index 4472d6f..4ab8fba 100644
--- a/fs/lustre/lov/lov_cl_internal.h
+++ b/fs/lustre/lov/lov_cl_internal.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2015 Intel Corporation.
+ * Copyright (c) 2012, 2017 Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/lov/lov_dev.c b/fs/lustre/lov/lov_dev.c
index 46d2e1e..a4e6b91 100644
--- a/fs/lustre/lov/lov_dev.c
+++ b/fs/lustre/lov/lov_dev.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2015, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/lov/lov_ea.c b/fs/lustre/lov/lov_ea.c
index 081a04f..41308d3 100644
--- a/fs/lustre/lov/lov_ea.c
+++ b/fs/lustre/lov/lov_ea.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/lov/lov_internal.h b/fs/lustre/lov/lov_internal.h
index b3712d2..5dba8d3 100644
--- a/fs/lustre/lov/lov_internal.h
+++ b/fs/lustre/lov/lov_internal.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 75fa646..54e2d7d 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/lov/lov_lock.c b/fs/lustre/lov/lov_lock.c
index 0c10c3a..7dae13f 100644
--- a/fs/lustre/lov/lov_lock.c
+++ b/fs/lustre/lov/lov_lock.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/lov/lov_merge.c b/fs/lustre/lov/lov_merge.c
index a8c23fe..7728630 100644
--- a/fs/lustre/lov/lov_merge.c
+++ b/fs/lustre/lov/lov_merge.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2005, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2015, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index 4ced5f7..acfee93 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 49facf3..a73f2ac 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/lov/lov_offset.c b/fs/lustre/lov/lov_offset.c
index 56a2d7b..bb67d82 100644
--- a/fs/lustre/lov/lov_offset.c
+++ b/fs/lustre/lov/lov_offset.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2005, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/lov/lov_pack.c b/fs/lustre/lov/lov_pack.c
index aac5048..3dbc6aa 100644
--- a/fs/lustre/lov/lov_pack.c
+++ b/fs/lustre/lov/lov_pack.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/lov/lov_page.c b/fs/lustre/lov/lov_page.c
index 22548f4..3f08da7 100644
--- a/fs/lustre/lov/lov_page.c
+++ b/fs/lustre/lov/lov_page.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/lov/lov_pool.c b/fs/lustre/lov/lov_pool.c
index 78a7dd2..60565b9 100644
--- a/fs/lustre/lov/lov_pool.c
+++ b/fs/lustre/lov/lov_pool.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/lov/lproc_lov.c b/fs/lustre/lov/lproc_lov.c
index 4fecd4e..c528a8b 100644
--- a/fs/lustre/lov/lproc_lov.c
+++ b/fs/lustre/lov/lproc_lov.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2015 Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/mdc/lproc_mdc.c b/fs/lustre/mdc/lproc_mdc.c
index 9092a97..2af2e57 100644
--- a/fs/lustre/mdc/lproc_mdc.c
+++ b/fs/lustre/mdc/lproc_mdc.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/mdc/mdc_changelog.c b/fs/lustre/mdc/mdc_changelog.c
index b6a26db..d9e861e 100644
--- a/fs/lustre/mdc/mdc_changelog.c
+++ b/fs/lustre/mdc/mdc_changelog.c
@@ -24,6 +24,8 @@
  * Copyright (c) 2017, Commissariat a l'Energie Atomique et aux Energies
  *                     Alternatives.
  *
+ * Copyright (c) 2017, Intel Corporation.
+ *
  * Author: Henri Doreau <henri.doreau@cea.fr>
  */
 
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index de21d7d..4ff5cc6 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -21,7 +21,7 @@
  * GPL HEADER END
  */
 /*
- * Copyright (c) 2017 Intel Corporation.
+ * Copyright (c) 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/mdc/mdc_internal.h b/fs/lustre/mdc/mdc_internal.h
index 669cb1c..079539d 100644
--- a/fs/lustre/mdc/mdc_internal.h
+++ b/fs/lustre/mdc/mdc_internal.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015 Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/mdc/mdc_lib.c b/fs/lustre/mdc/mdc_lib.c
index df66ed1..dc5dac4 100644
--- a/fs/lustre/mdc/mdc_lib.c
+++ b/fs/lustre/mdc/mdc_lib.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 9c4dcad..f297a98 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/mdc/mdc_reint.c b/fs/lustre/mdc/mdc_reint.c
index 8e0bd0a..d6216d6 100644
--- a/fs/lustre/mdc/mdc_reint.c
+++ b/fs/lustre/mdc/mdc_reint.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 29a4886..95698c3 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2001, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/mgc/lproc_mgc.c b/fs/lustre/mgc/lproc_mgc.c
index 574233e..d977d51 100644
--- a/fs/lustre/mgc/lproc_mgc.c
+++ b/fs/lustre/mgc/lproc_mgc.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/mgc/mgc_internal.h b/fs/lustre/mgc/mgc_internal.h
index 0a91624..7a6e77b 100644
--- a/fs/lustre/mgc/mgc_internal.h
+++ b/fs/lustre/mgc/mgc_internal.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/mgc/mgc_request.c b/fs/lustre/mgc/mgc_request.c
index ca7f47a..ca4b8a9 100644
--- a/fs/lustre/mgc/mgc_request.c
+++ b/fs/lustre/mgc/mgc_request.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/obdclass/cl_internal.h b/fs/lustre/obdclass/cl_internal.h
index dc6bf10..4fec0f4 100644
--- a/fs/lustre/obdclass/cl_internal.h
+++ b/fs/lustre/obdclass/cl_internal.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index ca94eb3..a98be15 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/obdclass/cl_lock.c b/fs/lustre/obdclass/cl_lock.c
index 07d0dc8..0c02546 100644
--- a/fs/lustre/obdclass/cl_lock.c
+++ b/fs/lustre/obdclass/cl_lock.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2014, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/obdclass/cl_object.c b/fs/lustre/obdclass/cl_object.c
index 4a40121..f0ae34f 100644
--- a/fs/lustre/obdclass/cl_object.c
+++ b/fs/lustre/obdclass/cl_object.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
index 163f4de..8ea63f7 100644
--- a/fs/lustre/obdclass/cl_page.c
+++ b/fs/lustre/obdclass/cl_page.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/obdclass/class_obd.c b/fs/lustre/obdclass/class_obd.c
index 8b6032a..7e436af 100644
--- a/fs/lustre/obdclass/class_obd.c
+++ b/fs/lustre/obdclass/class_obd.c
@@ -24,7 +24,7 @@
  * Copyright (c) 1999, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 1ecceeb..6491032 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -24,7 +24,7 @@
  * Copyright (c) 1999, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/obdclass/kernelcomm.c b/fs/lustre/obdclass/kernelcomm.c
index e92a52c..bc9b0f2 100644
--- a/fs/lustre/obdclass/kernelcomm.c
+++ b/fs/lustre/obdclass/kernelcomm.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/obdclass/linkea.c b/fs/lustre/obdclass/linkea.c
index b1aa80a..11902e1 100644
--- a/fs/lustre/obdclass/linkea.c
+++ b/fs/lustre/obdclass/linkea.c
@@ -21,7 +21,7 @@
  * GPL HEADER END
  */
 /*
- * Copyright (c) 2013, 2014, Intel Corporation.
+ * Copyright (c) 2013, 2017, Intel Corporation.
  * Use is subject to license terms.
  *
  * Author: Di Wang <di.wang@intel.com>
diff --git a/fs/lustre/obdclass/llog.c b/fs/lustre/obdclass/llog.c
index e9a6514..3187a9c 100644
--- a/fs/lustre/obdclass/llog.c
+++ b/fs/lustre/obdclass/llog.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2015, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/obdclass/llog_cat.c b/fs/lustre/obdclass/llog_cat.c
index 4536f54..970f2e9 100644
--- a/fs/lustre/obdclass/llog_cat.c
+++ b/fs/lustre/obdclass/llog_cat.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2015, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/obdclass/llog_internal.h b/fs/lustre/obdclass/llog_internal.h
index 545119e..365bac9 100644
--- a/fs/lustre/obdclass/llog_internal.h
+++ b/fs/lustre/obdclass/llog_internal.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2015, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/obdclass/llog_swab.c b/fs/lustre/obdclass/llog_swab.c
index 49024fd..c18ca95 100644
--- a/fs/lustre/obdclass/llog_swab.c
+++ b/fs/lustre/obdclass/llog_swab.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2005, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2015, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index a9617e5..dbbaa92 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/obdclass/lu_object.c b/fs/lustre/obdclass/lu_object.c
index 4302482..d8dfc721 100644
--- a/fs/lustre/obdclass/lu_object.c
+++ b/fs/lustre/obdclass/lu_object.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/obdclass/lu_ref.c b/fs/lustre/obdclass/lu_ref.c
index f67cb89..9b32c3c 100644
--- a/fs/lustre/obdclass/lu_ref.c
+++ b/fs/lustre/obdclass/lu_ref.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/obdclass/lustre_handles.c b/fs/lustre/obdclass/lustre_handles.c
index 0674afb..7c63d9c 100644
--- a/fs/lustre/obdclass/lustre_handles.c
+++ b/fs/lustre/obdclass/lustre_handles.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/obdclass/lustre_peer.c b/fs/lustre/obdclass/lustre_peer.c
index 69a3b32..58b6e670 100644
--- a/fs/lustre/obdclass/lustre_peer.c
+++ b/fs/lustre/obdclass/lustre_peer.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/obdclass/obd_config.c b/fs/lustre/obdclass/obd_config.c
index 1485cc7..550cee0 100644
--- a/fs/lustre/obdclass/obd_config.c
+++ b/fs/lustre/obdclass/obd_config.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/obdclass/obd_mount.c b/fs/lustre/obdclass/obd_mount.c
index de81baa..5cf404c 100644
--- a/fs/lustre/obdclass/obd_mount.c
+++ b/fs/lustre/obdclass/obd_mount.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/obdclass/obd_sysfs.c b/fs/lustre/obdclass/obd_sysfs.c
index e9e0bcf..bac8e7c5 100644
--- a/fs/lustre/obdclass/obd_sysfs.c
+++ b/fs/lustre/obdclass/obd_sysfs.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/obdclass/obdo.c b/fs/lustre/obdclass/obdo.c
index 7c65d0d..1926896 100644
--- a/fs/lustre/obdclass/obdo.c
+++ b/fs/lustre/obdclass/obdo.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/obdecho/debug.c b/fs/lustre/obdecho/debug.c
index a8f773a..130d3bf 100644
--- a/fs/lustre/obdecho/debug.c
+++ b/fs/lustre/obdecho/debug.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2014, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/obdecho/echo_client.c b/fs/lustre/obdecho/echo_client.c
index baf34c8..4ae21fb 100644
--- a/fs/lustre/obdecho/echo_client.c
+++ b/fs/lustre/obdecho/echo_client.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index 2f122a2..6661092 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index e387b7a..68498af 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2015, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  *
  */
 /*
diff --git a/fs/lustre/osc/osc_dev.c b/fs/lustre/osc/osc_dev.c
index fb1d31c..3d0687a 100644
--- a/fs/lustre/osc/osc_dev.c
+++ b/fs/lustre/osc/osc_dev.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2015, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/osc/osc_internal.h b/fs/lustre/osc/osc_internal.h
index 2e0c521..1194033 100644
--- a/fs/lustre/osc/osc_internal.h
+++ b/fs/lustre/osc/osc_internal.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 0545e23..d8fa8cc 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index 1ede75c..b7b33fb 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/osc/osc_object.c b/fs/lustre/osc/osc_object.c
index 76e7e33..4cd6e15 100644
--- a/fs/lustre/osc/osc_object.c
+++ b/fs/lustre/osc/osc_object.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index 6e49cf4..f5b6f73 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/osc/osc_quota.c b/fs/lustre/osc/osc_quota.c
index 3909e11..cb5ddef 100644
--- a/fs/lustre/osc/osc_quota.c
+++ b/fs/lustre/osc/osc_quota.c
@@ -19,7 +19,7 @@
 /*
  * Copyright (c) 2009, 2010, Oracle and/or its affiliates. All rights reserved.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  *
  * Code originally extracted from quota directory
  */
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 2dce087..0f7ac2d 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 0499368..e3aee32 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ptlrpc/events.c b/fs/lustre/ptlrpc/events.c
index fc3c7f0..93a59b8 100644
--- a/fs/lustre/ptlrpc/events.c
+++ b/fs/lustre/ptlrpc/events.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2015 Intel Corporation.
+ * Copyright (c) 2012, 2017 Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 6e2af7f..3c56798 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 0978329..4909b30 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ptlrpc/llog_net.c b/fs/lustre/ptlrpc/llog_net.c
index b871d9e..1d86fb3 100644
--- a/fs/lustre/ptlrpc/llog_net.c
+++ b/fs/lustre/ptlrpc/llog_net.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2013, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index 02713076..163ee54 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index 7bf78ee..47d4159 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index b9dd3abe..1ba2772 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ptlrpc/ptlrpc_internal.h b/fs/lustre/ptlrpc/ptlrpc_internal.h
index 40cf7b7..f84d278 100644
--- a/fs/lustre/ptlrpc/ptlrpc_internal.h
+++ b/fs/lustre/ptlrpc/ptlrpc_internal.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ptlrpc/ptlrpc_module.c b/fs/lustre/ptlrpc/ptlrpc_module.c
index 6888df9..0c988ae 100644
--- a/fs/lustre/ptlrpc/ptlrpc_module.c
+++ b/fs/lustre/ptlrpc/ptlrpc_module.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2014, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ptlrpc/ptlrpcd.c b/fs/lustre/ptlrpc/ptlrpcd.c
index 0b73d58..c0b091c 100644
--- a/fs/lustre/ptlrpc/ptlrpcd.c
+++ b/fs/lustre/ptlrpc/ptlrpcd.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ptlrpc/recover.c b/fs/lustre/ptlrpc/recover.c
index 5548049..7c09c4e 100644
--- a/fs/lustre/ptlrpc/recover.c
+++ b/fs/lustre/ptlrpc/recover.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ptlrpc/sec.c b/fs/lustre/ptlrpc/sec.c
index a0d6732..21055a3 100644
--- a/fs/lustre/ptlrpc/sec.c
+++ b/fs/lustre/ptlrpc/sec.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ptlrpc/sec_bulk.c b/fs/lustre/ptlrpc/sec_bulk.c
index 755781c..e170da1 100644
--- a/fs/lustre/ptlrpc/sec_bulk.c
+++ b/fs/lustre/ptlrpc/sec_bulk.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ptlrpc/sec_config.c b/fs/lustre/ptlrpc/sec_config.c
index d3c949d..135ce99 100644
--- a/fs/lustre/ptlrpc/sec_config.c
+++ b/fs/lustre/ptlrpc/sec_config.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ptlrpc/sec_gc.c b/fs/lustre/ptlrpc/sec_gc.c
index c4dba67..d5edcec 100644
--- a/fs/lustre/ptlrpc/sec_gc.c
+++ b/fs/lustre/ptlrpc/sec_gc.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2016, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ptlrpc/sec_null.c b/fs/lustre/ptlrpc/sec_null.c
index df6ef4f..726db6e 100644
--- a/fs/lustre/ptlrpc/sec_null.c
+++ b/fs/lustre/ptlrpc/sec_null.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ptlrpc/sec_plain.c b/fs/lustre/ptlrpc/sec_plain.c
index 021bf7f..84ff1fd 100644
--- a/fs/lustre/ptlrpc/sec_plain.c
+++ b/fs/lustre/ptlrpc/sec_plain.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index b2a1b4a..90c7529 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2010, 2015, Intel Corporation.
+ * Copyright (c) 2010, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/include/linux/libcfs/libcfs.h b/include/linux/libcfs/libcfs.h
index cc64039..33f7477 100644
--- a/include/linux/libcfs/libcfs.h
+++ b/include/linux/libcfs/libcfs.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/include/linux/libcfs/libcfs_cpu.h b/include/linux/libcfs/libcfs_cpu.h
index de9ae63..c354dbd 100644
--- a/include/linux/libcfs/libcfs_cpu.h
+++ b/include/linux/libcfs/libcfs_cpu.h
@@ -19,7 +19,7 @@
 /*
  * Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved.
  *
- * Copyright (c) 2012, 2015 Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/include/linux/libcfs/libcfs_debug.h b/include/linux/libcfs/libcfs_debug.h
index 911fd35..89deab4 100644
--- a/include/linux/libcfs/libcfs_debug.h
+++ b/include/linux/libcfs/libcfs_debug.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/include/linux/libcfs/libcfs_hash.h b/include/linux/libcfs/libcfs_hash.h
index 89d25ca..7f62379 100644
--- a/include/linux/libcfs/libcfs_hash.h
+++ b/include/linux/libcfs/libcfs_hash.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2015 Intel Corporation.
+ * Copyright (c) 2012, 2015, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/include/linux/libcfs/libcfs_private.h b/include/linux/libcfs/libcfs_private.h
index 2e8cff6..cf13fe0 100644
--- a/include/linux/libcfs/libcfs_private.h
+++ b/include/linux/libcfs/libcfs_private.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2014, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/include/linux/libcfs/libcfs_string.h b/include/linux/libcfs/libcfs_string.h
index f2ac9dc..34b5521 100644
--- a/include/linux/libcfs/libcfs_string.h
+++ b/include/linux/libcfs/libcfs_string.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/include/linux/lnet/api.h b/include/linux/lnet/api.h
index 8d37509..7cc1d04 100644
--- a/include/linux/lnet/api.h
+++ b/include/linux/lnet/api.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011 - 2015, Intel Corporation.
+ * Copyright (c) 2016, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 538d457..3d7867f 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2015, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index a5cbf07..15968ba 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2015, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/include/uapi/linux/lnet/libcfs_debug.h b/include/uapi/linux/lnet/libcfs_debug.h
index 91d80ab..1a68667 100644
--- a/include/uapi/linux/lnet/libcfs_debug.h
+++ b/include/uapi/linux/lnet/libcfs_debug.h
@@ -23,7 +23,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2014, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/include/uapi/linux/lnet/libcfs_ioctl.h b/include/uapi/linux/lnet/libcfs_ioctl.h
index 765466f..4396d26 100644
--- a/include/uapi/linux/lnet/libcfs_ioctl.h
+++ b/include/uapi/linux/lnet/libcfs_ioctl.h
@@ -22,6 +22,8 @@
 /*
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
+ *
+ * Copyright (c) 2013, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/include/uapi/linux/lnet/lnet-dlc.h b/include/uapi/linux/lnet/lnet-dlc.h
index 706892c..484435d 100644
--- a/include/uapi/linux/lnet/lnet-dlc.h
+++ b/include/uapi/linux/lnet/lnet-dlc.h
@@ -20,7 +20,7 @@
  *
  */
 /*
- * Copyright (c) 2014, Intel Corporation.
+ * Copyright (c) 2014, 2017, Intel Corporation.
  */
 /*
  * Author: Amir Shehata <amir.shehata@intel.com>
diff --git a/include/uapi/linux/lnet/lnet-types.h b/include/uapi/linux/lnet/lnet-types.h
index 956af3c5..2afdd83 100644
--- a/include/uapi/linux/lnet/lnet-types.h
+++ b/include/uapi/linux/lnet/lnet-types.h
@@ -23,7 +23,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012 - 2015, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/include/uapi/linux/lnet/lnetctl.h b/include/uapi/linux/lnet/lnetctl.h
index e9fc57c..191689c 100644
--- a/include/uapi/linux/lnet/lnetctl.h
+++ b/include/uapi/linux/lnet/lnetctl.h
@@ -12,6 +12,9 @@
  *
  * header for lnet ioctl
  */
+/*
+ * Copyright (c) 2014, 2017, Intel Corporation.
+ */
 #ifndef _LNETCTL_H_
 #define _LNETCTL_H_
 
diff --git a/include/uapi/linux/lnet/nidstr.h b/include/uapi/linux/lnet/nidstr.h
index 6c49d59..8bff1fd 100644
--- a/include/uapi/linux/lnet/nidstr.h
+++ b/include/uapi/linux/lnet/nidstr.h
@@ -23,7 +23,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2015, 2017, Intel Corporation.
  */
 #ifndef _LNET_NIDSTRINGS_H
 #define _LNET_NIDSTRINGS_H
diff --git a/include/uapi/linux/lustre/lustre_fid.h b/include/uapi/linux/lustre/lustre_fid.h
index 9f7959c..79574c0 100644
--- a/include/uapi/linux/lustre/lustre_fid.h
+++ b/include/uapi/linux/lustre/lustre_fid.h
@@ -23,7 +23,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2014, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  *
  * Copyright 2016 Cray Inc, all rights reserved.
  * Author: Ben Evans.
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 41d0abb..cd4e0e9 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -23,7 +23,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/include/uapi/linux/lustre/lustre_ioctl.h b/include/uapi/linux/lustre/lustre_ioctl.h
index 098b6451..8289d43 100644
--- a/include/uapi/linux/lustre/lustre_ioctl.h
+++ b/include/uapi/linux/lustre/lustre_ioctl.h
@@ -23,7 +23,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 #ifndef _UAPI_LUSTRE_IOCTL_H_
 #define _UAPI_LUSTRE_IOCTL_H_
diff --git a/include/uapi/linux/lustre/lustre_ostid.h b/include/uapi/linux/lustre/lustre_ostid.h
index 4b5f110..0f1a0a9 100644
--- a/include/uapi/linux/lustre/lustre_ostid.h
+++ b/include/uapi/linux/lustre/lustre_ostid.h
@@ -23,7 +23,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2014, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  *
  * Copyright 2015 Cray Inc, all rights reserved.
  * Author: Ben Evans.
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 7a44038..3f29093 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -23,7 +23,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2010, 2015, Intel Corporation.
+ * Copyright (c) 2010, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index d780108..4b3018e 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index 3f28c5b..541f95a 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 871d4fb..a702654 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2015, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index 9fb1357..b5df7fe 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index d2c72b0..d55b00f 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index add2744..04381a0 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -2,7 +2,7 @@
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  *
  *   Author: Zach Brown <zab@zabbo.net>
  *   Author: Peter J. Braam <braam@clusterfs.com>
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index 208b8d3..4861dcf 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -2,7 +2,7 @@
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  *
  *   Author: Zach Brown <zab@zabbo.net>
  *   Author: Peter J. Braam <braam@clusterfs.com>
diff --git a/net/lnet/klnds/socklnd/socklnd_lib.c b/net/lnet/klnds/socklnd/socklnd_lib.c
index a190869..3ac5f2e 100644
--- a/net/lnet/klnds/socklnd/socklnd_lib.c
+++ b/net/lnet/klnds/socklnd/socklnd_lib.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2005, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/klnds/socklnd/socklnd_proto.c b/net/lnet/klnds/socklnd/socklnd_proto.c
index e8b95af..64c0c74 100644
--- a/net/lnet/klnds/socklnd/socklnd_proto.c
+++ b/net/lnet/klnds/socklnd/socklnd_proto.c
@@ -2,7 +2,7 @@
 /*
  * Copyright (c) 2009, 2010, Oracle and/or its affiliates. All rights reserved.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  *
  *   Author: Zach Brown <zab@zabbo.net>
  *   Author: Peter J. Braam <braam@clusterfs.com>
diff --git a/net/lnet/libcfs/debug.c b/net/lnet/libcfs/debug.c
index 552e728..fd8ed81 100644
--- a/net/lnet/libcfs/debug.c
+++ b/net/lnet/libcfs/debug.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/libcfs/libcfs_cpu.c b/net/lnet/libcfs/libcfs_cpu.c
index 5f0d7a2..3e566ac 100644
--- a/net/lnet/libcfs/libcfs_cpu.c
+++ b/net/lnet/libcfs/libcfs_cpu.c
@@ -18,7 +18,7 @@
  */
 /*
  * Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved.
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/libcfs/libcfs_string.c b/net/lnet/libcfs/libcfs_string.c
index 02814d3..cefe6fee 100644
--- a/net/lnet/libcfs/libcfs_string.c
+++ b/net/lnet/libcfs/libcfs_string.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2015 Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/libcfs/module.c b/net/lnet/libcfs/module.c
index 89f0783..49731bd 100644
--- a/net/lnet/libcfs/module.c
+++ b/net/lnet/libcfs/module.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2015 Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/libcfs/tracefile.c b/net/lnet/libcfs/tracefile.c
index d634e22..5f51ec7 100644
--- a/net/lnet/libcfs/tracefile.c
+++ b/net/lnet/libcfs/tracefile.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/libcfs/tracefile.h b/net/lnet/libcfs/tracefile.h
index 3a00a6c..88ff0d1 100644
--- a/net/lnet/libcfs/tracefile.h
+++ b/net/lnet/libcfs/tracefile.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/lnet/acceptor.c b/net/lnet/lnet/acceptor.c
index 83ab3b1..d91a38c 100644
--- a/net/lnet/lnet/acceptor.c
+++ b/net/lnet/lnet/acceptor.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index b038010..6e29714 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index 6dda6e5..ef1faa0 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2015, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/lnet/lib-md.c b/net/lnet/lnet/lib-md.c
index 8fe3564..7ea0f5e 100644
--- a/net/lnet/lnet/lib-md.c
+++ b/net/lnet/lnet/lib-md.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 6f3e941..202372d 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 02620fe..a7062f6 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/lnet/lib-ptl.c b/net/lnet/lnet/lib-ptl.c
index 83548f5..bb92f37 100644
--- a/net/lnet/lnet/lib-ptl.c
+++ b/net/lnet/lnet/lib-ptl.c
@@ -17,7 +17,7 @@
  * GPL HEADER END
  */
 /*
- * Copyright (c) 2012, 2015, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/lnet/lib-socket.c b/net/lnet/lnet/lib-socket.c
index 6ea8f3f..d430d6f 100644
--- a/net/lnet/lnet/lib-socket.c
+++ b/net/lnet/lnet/lib-socket.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2015, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/lnet/lo.c b/net/lnet/lnet/lo.c
index c8a1eb62..2563243 100644
--- a/net/lnet/lnet/lo.c
+++ b/net/lnet/lnet/lo.c
@@ -23,6 +23,8 @@
 /*
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
+ *
+ * Copyright (c) 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/lnet/module.c b/net/lnet/lnet/module.c
index 78fc96e..95e1bae 100644
--- a/net/lnet/lnet/module.c
+++ b/net/lnet/lnet/module.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2015, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/lnet/net_fault.c b/net/lnet/lnet/net_fault.c
index 76fb61d4..4589b17 100644
--- a/net/lnet/lnet/net_fault.c
+++ b/net/lnet/lnet/net_fault.c
@@ -21,7 +21,7 @@
  * GPL HEADER END
  */
 /*
- * Copyright (c) 2014, Intel Corporation.
+ * Copyright (c) 2014, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/lnet/nidstrings.c b/net/lnet/lnet/nidstrings.c
index 0a63b0c..b84708d 100644
--- a/net/lnet/lnet/nidstrings.c
+++ b/net/lnet/lnet/nidstrings.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 68c6eb7..52d4ec0 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index bcde61d..4b0c57a 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -2,7 +2,7 @@
 /*
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  *
  *   This file is part of Portals
  *   http://sourceforge.net/projects/sandiaportals/
diff --git a/net/lnet/lnet/router_proc.c b/net/lnet/lnet/router_proc.c
index 94ef441..ebe7993 100644
--- a/net/lnet/lnet/router_proc.c
+++ b/net/lnet/lnet/router_proc.c
@@ -2,7 +2,7 @@
 /*
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  *
- * Copyright (c) 2011, 2012, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  *
  *   This file is part of Portals
  *   http://sourceforge.net/projects/sandiaportals/
diff --git a/net/lnet/selftest/brw_test.c b/net/lnet/selftest/brw_test.c
index eb8b1e9..560bcc7 100644
--- a/net/lnet/selftest/brw_test.c
+++ b/net/lnet/selftest/brw_test.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/selftest/framework.c b/net/lnet/selftest/framework.c
index 72892c1..714ceec 100644
--- a/net/lnet/selftest/framework.c
+++ b/net/lnet/selftest/framework.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/selftest/rpc.c b/net/lnet/selftest/rpc.c
index abb6f8f..295d704 100644
--- a/net/lnet/selftest/rpc.c
+++ b/net/lnet/selftest/rpc.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, 2015, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/net/lnet/selftest/selftest.h b/net/lnet/selftest/selftest.h
index edf783a..fb16143 100644
--- a/net/lnet/selftest/selftest.h
+++ b/net/lnet/selftest/selftest.h
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2012, Intel Corporation.
+ * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
-- 
1.8.3.1
