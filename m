From: James Simmons <jsimmons@infradead.org>
Date: Wed, 23 Nov 2016 17:59:49 -0500
Subject: [lustre-devel] [PATCH 3/5] staging: lustre: ldlm: remove
	ldlm_wire_policy_data_t typedef usage from code
In-Reply-To: <1479941991-30059-1-git-send-email-jsimmons@infradead.org>
References: <1479941991-30059-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479941991-30059-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Replace usage of ldlm_wire_policy_data_t with named enums
to conform to upstream coding style.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: http://review.whamcloud.com/15300
Reviewed-on: http://review.whamcloud.com/15301
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: frank zago <fzago@cray.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    6 +++---
 drivers/staging/lustre/lustre/include/lustre_dlm.h |    2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |    4 ++--
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |    4 ++--
 .../staging/lustre/lustre/ldlm/ldlm_inodebits.c    |    4 ++--
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |   20 ++++++++++----------
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |    4 ++--
 drivers/staging/lustre/lustre/ldlm/ldlm_plain.c    |    4 ++--
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |    2 +-
 9 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 5c1fb6c..6a4a7d8 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2623,11 +2623,11 @@ struct ldlm_flock_wire {
  * on the resource type.
  */
 
-typedef union {
+union ldlm_wire_policy_data {
 	struct ldlm_extent l_extent;
 	struct ldlm_flock_wire l_flock;
 	struct ldlm_inodebits l_inodebits;
-} ldlm_wire_policy_data_t;
+};
 
 union ldlm_gl_desc {
 	struct ldlm_gl_lquota_desc	lquota_desc;
@@ -2669,7 +2669,7 @@ struct ldlm_lock_desc {
 	struct ldlm_resource_desc l_resource;
 	enum ldlm_mode l_req_mode;
 	enum ldlm_mode l_granted_mode;
-	ldlm_wire_policy_data_t l_policy_data;
+	union ldlm_wire_policy_data l_policy_data;
 };
 
 #define LDLM_LOCKREQ_HANDLES 2
diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 02c90b0..62304ba 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -560,7 +560,7 @@ struct ldlm_flock {
 };
 
 void ldlm_convert_policy_to_local(struct obd_export *exp, enum ldlm_type type,
-				  const ldlm_wire_policy_data_t *wpolicy,
+				  const union ldlm_wire_policy_data *wpolicy,
 				  union ldlm_policy_data *lpolicy);
 
 enum lvb_type {
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index 78cd70d..32b73ee 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
@@ -240,7 +240,7 @@ void ldlm_extent_unlink_lock(struct ldlm_lock *lock)
 	}
 }
 
-void ldlm_extent_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
+void ldlm_extent_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
 				      union ldlm_policy_data *lpolicy)
 {
 	memset(lpolicy, 0, sizeof(*lpolicy));
@@ -250,7 +250,7 @@ void ldlm_extent_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
 }
 
 void ldlm_extent_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
-				      ldlm_wire_policy_data_t *wpolicy)
+				      union ldlm_wire_policy_data *wpolicy)
 {
 	memset(wpolicy, 0, sizeof(*wpolicy));
 	wpolicy->l_extent.start = lpolicy->l_extent.start;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index 2683a7b..7221607 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -612,7 +612,7 @@ struct ldlm_flock_wait_data {
 }
 EXPORT_SYMBOL(ldlm_flock_completion_ast);
 
-void ldlm_flock_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
+void ldlm_flock_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
 				     union ldlm_policy_data *lpolicy)
 {
 	memset(lpolicy, 0, sizeof(*lpolicy));
@@ -623,7 +623,7 @@ void ldlm_flock_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
 }
 
 void ldlm_flock_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
-				     ldlm_wire_policy_data_t *wpolicy)
+				     union ldlm_wire_policy_data *wpolicy)
 {
 	memset(wpolicy, 0, sizeof(*wpolicy));
 	wpolicy->l_flock.lfw_start = lpolicy->l_flock.start;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c b/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c
index 11b45ae..8e1709d 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c
@@ -54,7 +54,7 @@
 #include "../include/lustre_lib.h"
 #include "ldlm_internal.h"
 
-void ldlm_ibits_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
+void ldlm_ibits_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
 				     union ldlm_policy_data *lpolicy)
 {
 	memset(lpolicy, 0, sizeof(*lpolicy));
@@ -62,7 +62,7 @@ void ldlm_ibits_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
 }
 
 void ldlm_ibits_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
-				     ldlm_wire_policy_data_t *wpolicy)
+				     union ldlm_wire_policy_data *wpolicy)
 {
 	memset(wpolicy, 0, sizeof(*wpolicy));
 	wpolicy->l_inodebits.bits = lpolicy->l_inodebits.bits;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index e2c3c6e..9085ee5 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -312,25 +312,25 @@ static inline int is_granted_or_cancelled(struct ldlm_lock *lock)
 	return ret;
 }
 
-typedef void (*ldlm_policy_wire_to_local_t)(const ldlm_wire_policy_data_t *,
+typedef void (*ldlm_policy_wire_to_local_t)(const union ldlm_wire_policy_data *,
 					    union ldlm_policy_data *);
 
 typedef void (*ldlm_policy_local_to_wire_t)(const union ldlm_policy_data *,
-					    ldlm_wire_policy_data_t *);
+					    union ldlm_wire_policy_data *);
 
-void ldlm_plain_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
+void ldlm_plain_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
 				     union ldlm_policy_data *lpolicy);
 void ldlm_plain_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
-				     ldlm_wire_policy_data_t *wpolicy);
-void ldlm_ibits_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
+				     union ldlm_wire_policy_data *wpolicy);
+void ldlm_ibits_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
 				     union ldlm_policy_data *lpolicy);
 void ldlm_ibits_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
-				     ldlm_wire_policy_data_t *wpolicy);
-void ldlm_extent_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
+				     union ldlm_wire_policy_data *wpolicy);
+void ldlm_extent_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
 				      union ldlm_policy_data *lpolicy);
 void ldlm_extent_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
-				      ldlm_wire_policy_data_t *wpolicy);
-void ldlm_flock_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
+				      union ldlm_wire_policy_data *wpolicy);
+void ldlm_flock_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
 				     union ldlm_policy_data *lpolicy);
 void ldlm_flock_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
-				     ldlm_wire_policy_data_t *wpolicy);
+				     union ldlm_wire_policy_data *wpolicy);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 3dc0a06..15eeb2b 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -82,7 +82,7 @@
  */
 static void ldlm_convert_policy_to_wire(enum ldlm_type type,
 					const union ldlm_policy_data *lpolicy,
-					ldlm_wire_policy_data_t *wpolicy)
+					union ldlm_wire_policy_data *wpolicy)
 {
 	ldlm_policy_local_to_wire_t convert;
 
@@ -95,7 +95,7 @@ static void ldlm_convert_policy_to_wire(enum ldlm_type type,
  * Converts lock policy from on the wire lock_desc format to local format
  */
 void ldlm_convert_policy_to_local(struct obd_export *exp, enum ldlm_type type,
-				  const ldlm_wire_policy_data_t *wpolicy,
+				  const union ldlm_wire_policy_data *wpolicy,
 				  union ldlm_policy_data *lpolicy)
 {
 	ldlm_policy_wire_to_local_t convert;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_plain.c b/drivers/staging/lustre/lustre/ldlm/ldlm_plain.c
index 2603293..862ea0a 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_plain.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_plain.c
@@ -54,14 +54,14 @@
 
 #include "ldlm_internal.h"
 
-void ldlm_plain_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
+void ldlm_plain_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
 				     union ldlm_policy_data *lpolicy)
 {
 	/* No policy for plain locks */
 }
 
 void ldlm_plain_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
-				     ldlm_wire_policy_data_t *wpolicy)
+				     union ldlm_wire_policy_data *wpolicy)
 {
 	/* No policy for plain locks */
 }
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 39c4e18..2c9debb 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -2012,7 +2012,7 @@ static void lustre_swab_ldlm_res_id(struct ldlm_res_id *id)
 		__swab64s(&id->name[i]);
 }
 
-static void lustre_swab_ldlm_policy_data(ldlm_wire_policy_data_t *d)
+static void lustre_swab_ldlm_policy_data(union ldlm_wire_policy_data *d)
 {
 	/* the lock data is a union and the first two fields are always an
 	 * extent so it's ok to process an LDLM_EXTENT and LDLM_FLOCK lock
-- 
1.7.1
