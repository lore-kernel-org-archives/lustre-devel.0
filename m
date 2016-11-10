From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:50 -0500
Subject: [lustre-devel] [PATCH 20/35] staging: lustre: ptlrpc: Move IT_*
	definitions to lustre_idl.h
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Ben Evans <bevans@cray.com>, James Simmons <jsimmons@infradead.org>

From: Ben Evans <bevans@cray.com>

Put IT_* definitions into an enum, as they're sent over the wire,
adjust calls, print statements, etc. to use the new enum.

Signed-off-by: Ben Evans <bevans@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6746
Reviewed-on: http://review.whamcloud.com/16228
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |   18 ++++++++++++++++++
 drivers/staging/lustre/lustre/include/lustre_dlm.h |    2 +-
 drivers/staging/lustre/lustre/include/obd.h        |   16 ----------------
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |    4 ++--
 4 files changed, 21 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 33deee6..c06909a 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2631,6 +2631,24 @@ struct ldlm_flock_wire {
 
 void lustre_swab_gl_desc(union ldlm_gl_desc *);
 
+enum ldlm_intent_flags {
+	IT_OPEN		= BIT(0),
+	IT_CREAT	= BIT(1),
+	IT_OPEN_CREAT	= BIT(1) | BIT(0),
+	IT_READDIR	= BIT(2),
+	IT_GETATTR	= BIT(3),
+	IT_LOOKUP	= BIT(4),
+	IT_UNLINK	= BIT(5),
+	IT_TRUNC	= BIT(6),
+	IT_GETXATTR	= BIT(7),
+	IT_EXEC		= BIT(8),
+	IT_PIN		= BIT(9),
+	IT_LAYOUT	= BIT(10),
+	IT_QUOTA_DQACQ	= BIT(11),
+	IT_QUOTA_CONN	= BIT(12),
+	IT_SETXATTR	= BIT(13),
+};
+
 struct ldlm_intent {
 	__u64 opc;
 };
diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index f770b86..d94237d 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -977,7 +977,7 @@ struct ldlm_enqueue_info {
 extern struct obd_ops ldlm_obd_ops;
 
 extern char *ldlm_lockname[];
-char *ldlm_it2str(int it);
+const char *ldlm_it2str(enum ldlm_intent_flags it);
 
 /**
  * Just a fancy CDEBUG call with log level preset to LDLM_DEBUG.
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index a346312..f74f8bd 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -656,22 +656,6 @@ struct obd_device {
 
 struct lu_context;
 
-/* /!\ must be coherent with include/linux/namei.h on patched kernel */
-#define IT_OPEN     (1 << 0)
-#define IT_CREAT    (1 << 1)
-#define IT_READDIR  (1 << 2)
-#define IT_GETATTR  (1 << 3)
-#define IT_LOOKUP   (1 << 4)
-#define IT_UNLINK   (1 << 5)
-#define IT_TRUNC    (1 << 6)
-#define IT_GETXATTR (1 << 7)
-#define IT_EXEC     (1 << 8)
-#define IT_PIN      (1 << 9)
-#define IT_LAYOUT   (1 << 10)
-#define IT_QUOTA_DQACQ (1 << 11)
-#define IT_QUOTA_CONN  (1 << 12)
-#define IT_SETXATTR (1 << 13)
-
 static inline int it_to_lock_mode(struct lookup_intent *it)
 {
 	/* CREAT needs to be tested before open (both could be set) */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index f2044ec..17d532e 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -105,7 +105,7 @@ void ldlm_convert_policy_to_local(struct obd_export *exp, enum ldlm_type type,
 	convert(wpolicy, lpolicy);
 }
 
-char *ldlm_it2str(int it)
+const char *ldlm_it2str(enum ldlm_intent_flags it)
 {
 	switch (it) {
 	case IT_OPEN:
@@ -127,7 +127,7 @@ void ldlm_convert_policy_to_local(struct obd_export *exp, enum ldlm_type type,
 	case IT_LAYOUT:
 		return "layout";
 	default:
-		CERROR("Unknown intent %d\n", it);
+		CERROR("Unknown intent 0x%08x\n", it);
 		return "UNKNOWN";
 	}
 }
-- 
1.7.1
