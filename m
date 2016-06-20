From: Oleg Drokin <green@linuxhacker.ru>
Date: Sun, 19 Jun 2016 22:07:31 -0400
Subject: [lustre-devel] [PATCH 16/28] staging/lustre: Inline Lustre intent
	disposition functions
In-Reply-To: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
References: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466388463-1817551-17-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

They are just one-liners, so no point in having them exported
and called through a different module.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_intent.h | 15 +++++++++++++++
 drivers/staging/lustre/lustre/include/lustre_mdc.h    |  3 ---
 drivers/staging/lustre/lustre/mdc/mdc_locks.c         | 18 ------------------
 3 files changed, 15 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_intent.h b/drivers/staging/lustre/lustre/include/lustre_intent.h
index 41c03d7..3aed810 100644
--- a/drivers/staging/lustre/lustre/include/lustre_intent.h
+++ b/drivers/staging/lustre/lustre/include/lustre_intent.h
@@ -50,4 +50,19 @@ struct lookup_intent {
 	unsigned int    it_lock_set:1;
 };
 
+static inline int it_disposition(struct lookup_intent *it, int flag)
+{
+	return it->it_disposition & flag;
+}
+
+static inline void it_set_disposition(struct lookup_intent *it, int flag)
+{
+	it->it_disposition |= flag;
+}
+
+static inline void it_clear_disposition(struct lookup_intent *it, int flag)
+{
+	it->it_disposition &= ~flag;
+}
+
 #endif
diff --git a/drivers/staging/lustre/lustre/include/lustre_mdc.h b/drivers/staging/lustre/lustre/include/lustre_mdc.h
index 0ef4226..fa62b95 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mdc.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mdc.h
@@ -185,9 +185,6 @@ struct mdc_cache_waiter {
 };
 
 /* mdc/mdc_locks.c */
-int it_disposition(struct lookup_intent *it, int flag);
-void it_clear_disposition(struct lookup_intent *it, int flag);
-void it_set_disposition(struct lookup_intent *it, int flag);
 int it_open_error(int phase, struct lookup_intent *it);
 
 static inline bool cl_is_lov_delay_create(unsigned int flags)
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 5da2a1e..c43b3a2 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -50,24 +50,6 @@ struct mdc_getattr_args {
 	struct ldlm_enqueue_info    *ga_einfo;
 };
 
-int it_disposition(struct lookup_intent *it, int flag)
-{
-	return it->it_disposition & flag;
-}
-EXPORT_SYMBOL(it_disposition);
-
-void it_set_disposition(struct lookup_intent *it, int flag)
-{
-	it->it_disposition |= flag;
-}
-EXPORT_SYMBOL(it_set_disposition);
-
-void it_clear_disposition(struct lookup_intent *it, int flag)
-{
-	it->it_disposition &= ~flag;
-}
-EXPORT_SYMBOL(it_clear_disposition);
-
 int it_open_error(int phase, struct lookup_intent *it)
 {
 	if (it_disposition(it, DISP_OPEN_LEASE)) {
-- 
2.7.4
