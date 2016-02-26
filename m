From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Fri, 26 Feb 2016 01:49:56 -0500
Subject: [lustre-devel] [PATCH 08/25] staging/lustre: Remove liblustre
	references from explanations
In-Reply-To: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
References: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456469413-931943-9-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Since liblustre is no longer with us, referencing to it in the
explanations only makes things less clear

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/cl_object.h   | 4 ++--
 drivers/staging/lustre/lustre/include/lustre_lite.h | 2 +-
 drivers/staging/lustre/lustre/include/obd.h         | 2 +-
 drivers/staging/lustre/lustre/obdclass/cl_object.c  | 1 -
 drivers/staging/lustre/lustre/osc/osc_lock.c        | 3 +--
 5 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 4b3055d..fb971de 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -697,7 +697,7 @@ enum cl_page_type {
 
 	/** Transient page, the transient cl_page is used to bind a cl_page
 	 *  to vmpage which is not belonging to the same object of cl_page.
-	 *  it is used in DirectIO, lockless IO and liblustre.
+	 *  it is used in DirectIO and lockless IO.
 	 */
 	CPT_TRANSIENT,
 };
@@ -2282,7 +2282,7 @@ enum cl_io_lock_dmd {
 	CILR_MANDATORY = 0,
 	/** Layers are free to decide between local and global locking. */
 	CILR_MAYBE,
-	/** Never lock: there is no cache (e.g., liblustre). */
+	/** Never lock: there is no cache (e.g., lockless IO). */
 	CILR_NEVER
 };
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_lite.h b/drivers/staging/lustre/lustre/include/lustre_lite.h
index 9852325..fcc5ebb 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lite.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lite.h
@@ -54,7 +54,7 @@
 #define LL_MAX_BLKSIZE	  (1UL<<LL_MAX_BLKSIZE_BITS)
 
 /*
- * This is embedded into liblustre and llite super-blocks to keep track of
+ * This is embedded into llite super-blocks to keep track of
  * connect flags (capabilities) supported by all imports given mount is
  * connected to.
  */
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index abaacc9..4a0f2e8 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -658,7 +658,7 @@ enum obd_notify_event {
 
 /*
  * Data structure used to pass obd_notify()-event to non-obd listeners (llite
- * and liblustre being main examples).
+ * being main example).
  */
 struct obd_notify_upcall {
 	int (*onu_upcall)(struct obd_device *host, struct obd_device *watched,
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index 39b4fd0..b626914 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -483,7 +483,6 @@ EXPORT_SYMBOL(cl_site_stats_print);
  * because Lustre code may call into other fs which has certain assumptions
  * about journal_info. Currently following fields in task_struct are identified
  * can be used for this purpose:
- *  - cl_env: for liblustre.
  *  - tux_info: only on RedHat kernel.
  *  - ...
  * \note As long as we use task_struct to store cl_env, we assume that once
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 87f3522..cc308149 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -223,8 +223,7 @@ static int osc_lock_unuse(const struct lu_env *env,
 		/*
 		 * Move lock into OLS_RELEASED state before calling
 		 * osc_cancel_base() so that possible synchronous cancellation
-		 * (that always happens e.g., for liblustre) sees that lock is
-		 * released.
+		 * sees that lock is released.
 		 */
 		ols->ols_state = OLS_RELEASED;
 		return osc_lock_unhold(ols);
-- 
2.1.0
