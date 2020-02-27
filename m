From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:45 -0500
Subject: [lustre-devel] [PATCH 117/622] lustre: obdclass: Add
 lbug_on_eviction option
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-118-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Ryan Haasken <haasken@cray.com>

Add an lbug_on_eviction sysfs interface.  When it is set to a non-zero
value on a client, it will cause the client to LBUG whenever it is
evicted by the server. Note, an MDS is a client to OSTs, and every
server is a client of MGS. Thus, it is probably desireable to leave
this set to zero on servers.

Cray-bug-id: LUS-2591
WC-bug-id: https://jira.whamcloud.com/browse/LU-5026
Lustre-commit: 97381ffc9231 ("LU-5026 obdclass: Add lbug_on_eviction option")
Signed-off-by: Ryan Haasken <haasken@cray.com>
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/10257
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h | 1 +
 fs/lustre/obdclass/class_obd.c  | 2 ++
 fs/lustre/obdclass/obd_sysfs.c  | 2 ++
 fs/lustre/ptlrpc/import.c       | 1 +
 4 files changed, 6 insertions(+)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 3d14723..04ef76f 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -43,6 +43,7 @@
 extern unsigned int obd_debug_peer_on_timeout;
 extern unsigned int obd_dump_on_timeout;
 extern unsigned int obd_dump_on_eviction;
+extern unsigned int obd_lbug_on_eviction;
 /* obd_timeout should only be used for recovery, not for
  * networking / disk / timings affected by load (use Adaptive Timeouts)
  */
diff --git a/fs/lustre/obdclass/class_obd.c b/fs/lustre/obdclass/class_obd.c
index 7e436af..4ef9cca 100644
--- a/fs/lustre/obdclass/class_obd.c
+++ b/fs/lustre/obdclass/class_obd.c
@@ -56,6 +56,8 @@
 EXPORT_SYMBOL(obd_dump_on_timeout);
 unsigned int obd_dump_on_eviction;
 EXPORT_SYMBOL(obd_dump_on_eviction);
+unsigned int obd_lbug_on_eviction;
+EXPORT_SYMBOL(obd_lbug_on_eviction);
 unsigned long obd_max_dirty_pages;
 EXPORT_SYMBOL(obd_max_dirty_pages);
 atomic_long_t obd_dirty_pages;
diff --git a/fs/lustre/obdclass/obd_sysfs.c b/fs/lustre/obdclass/obd_sysfs.c
index cd2917e..73e44e7 100644
--- a/fs/lustre/obdclass/obd_sysfs.c
+++ b/fs/lustre/obdclass/obd_sysfs.c
@@ -118,6 +118,7 @@ static ssize_t static_uintvalue_store(struct kobject *kobj,
 LUSTRE_STATIC_UINT_ATTR(at_extra, &at_extra);
 LUSTRE_STATIC_UINT_ATTR(at_early_margin, &at_early_margin);
 LUSTRE_STATIC_UINT_ATTR(at_history, &at_history);
+LUSTRE_STATIC_UINT_ATTR(lbug_on_eviction, &obd_lbug_on_eviction);
 
 static ssize_t max_dirty_mb_show(struct kobject *kobj, struct attribute *attr,
 				 char *buf)
@@ -280,6 +281,7 @@ static ssize_t jobid_name_store(struct kobject *kobj, struct attribute *attr,
 	&lustre_sattr_at_extra.u.attr,
 	&lustre_sattr_at_early_margin.u.attr,
 	&lustre_sattr_at_history.u.attr,
+	&lustre_sattr_lbug_on_eviction.u.attr,
 	NULL,
 };
 
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index b11bb2f..73a345f 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -1385,6 +1385,7 @@ int ptlrpc_import_recovery_state_machine(struct obd_import *imp)
 					   "%s: This client was evicted by %.*s; in progress operations using this service will fail.\n",
 					   imp->imp_obd->obd_name, target_len,
 					   target_start);
+			LASSERTF(!obd_lbug_on_eviction, "LBUG upon eviction");
 		}
 		CDEBUG(D_HA, "evicted from %s@%s; invalidating\n",
 		       obd2cli_tgt(imp->imp_obd),
-- 
1.8.3.1
