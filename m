From: NeilBrown <neilb@suse.com>
Date: Thu, 29 Mar 2018 15:26:48 +1100
Subject: [lustre-devel] [PATCH 15/17] staging: lustre: discard
 cfs_time_before_64()
In-Reply-To: <152229732768.27689.4800156943561963977.stgit@noble>
References: <152229732768.27689.4800156943561963977.stgit@noble>
Message-ID: <152229760881.27689.10658125792259115083.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

cfs_time_before_64 is the same as time_before64()
similarly cfs_time_beforeq_64() matsches time_before_eq64()
So just use the standard interfaces.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/linux/linux-time.h |   14 --------------
 drivers/staging/lustre/lustre/include/obd_class.h  |    4 ++--
 drivers/staging/lustre/lustre/ptlrpc/import.c      |    4 ++--
 3 files changed, 4 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
index 9a353c6cb85a..ecdebccf2b44 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
@@ -56,20 +56,6 @@
 
 #include <linux/jiffies.h>
 
-/*
- * Generic kernel stuff
- */
-
-static inline int cfs_time_before_64(u64 t1, u64 t2)
-{
-	return (__s64)t2 - (__s64)t1 > 0;
-}
-
-static inline int cfs_time_beforeq_64(u64 t1, u64 t2)
-{
-	return (__s64)t2 - (__s64)t1 >= 0;
-}
-
 /*
  * One jiffy
  */
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 7cfc3c8d100c..176b63e2c9a7 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -932,7 +932,7 @@ static inline int obd_statfs_async(struct obd_export *exp,
 
 	CDEBUG(D_SUPER, "%s: osfs %p age %llu, max_age %llu\n",
 	       obd->obd_name, &obd->obd_osfs, obd->obd_osfs_age, max_age);
-	if (cfs_time_before_64(obd->obd_osfs_age, max_age)) {
+	if (time_before64(obd->obd_osfs_age, max_age)) {
 		rc = OBP(obd, statfs_async)(exp, oinfo, max_age, rqset);
 	} else {
 		CDEBUG(D_SUPER,
@@ -992,7 +992,7 @@ static inline int obd_statfs(const struct lu_env *env, struct obd_export *exp,
 
 	CDEBUG(D_SUPER, "osfs %llu, max_age %llu\n",
 	       obd->obd_osfs_age, max_age);
-	if (cfs_time_before_64(obd->obd_osfs_age, max_age)) {
+	if (time_before64(obd->obd_osfs_age, max_age)) {
 		rc = OBP(obd, statfs)(env, exp, osfs, max_age, flags);
 		if (rc == 0) {
 			spin_lock(&obd->obd_osfs_lock);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index dd4fd54128dd..537a9e2ed467 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -463,7 +463,7 @@ static int import_select_connection(struct obd_import *imp)
 		 * the last successful attempt, go with this one
 		 */
 		if ((conn->oic_last_attempt == 0) ||
-		    cfs_time_beforeq_64(conn->oic_last_attempt,
+		    time_before_eq64(conn->oic_last_attempt,
 					imp->imp_last_success_conn)) {
 			imp_conn = conn;
 			tried_all = 0;
@@ -476,7 +476,7 @@ static int import_select_connection(struct obd_import *imp)
 		 */
 		if (!imp_conn)
 			imp_conn = conn;
-		else if (cfs_time_before_64(conn->oic_last_attempt,
+		else if (time_before64(conn->oic_last_attempt,
 					    imp_conn->oic_last_attempt))
 			imp_conn = conn;
 	}
