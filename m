From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:53:58 -0500
Subject: [lustre-devel] [PATCH 20/56] staging/lustre: Remove ldlm_appetite_t
	typedef
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-21-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Replace it with enum ldlm_appetite

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h | 8 ++++----
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c | 2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 924e68f..0f229b9 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -296,10 +296,10 @@ struct ldlm_valblock_ops {
  * LDLM pools related, type of lock pool in the namespace.
  * Greedy means release cached locks aggressively
  */
-typedef enum {
+enum ldlm_appetite {
 	LDLM_NAMESPACE_GREEDY = 1 << 0,
 	LDLM_NAMESPACE_MODEST = 1 << 1
-} ldlm_appetite_t;
+};
 
 struct ldlm_ns_bucket {
 	/** back pointer to namespace */
@@ -440,7 +440,7 @@ struct ldlm_namespace {
 	/** LDLM pool structure for this namespace */
 	struct ldlm_pool	ns_pool;
 	/** Definition of how eagerly unused locks will be released from LRU */
-	ldlm_appetite_t		ns_appetite;
+	enum ldlm_appetite	ns_appetite;
 
 	/** Limit of parallel AST RPC count. */
 	unsigned		ns_max_parallel_ast;
@@ -1176,7 +1176,7 @@ void ldlm_unlink_lock_skiplist(struct ldlm_lock *req);
 /* resource.c */
 struct ldlm_namespace *
 ldlm_namespace_new(struct obd_device *obd, char *name,
-		   ldlm_side_t client, ldlm_appetite_t apt,
+		   ldlm_side_t client, enum ldlm_appetite apt,
 		   ldlm_ns_type_t ns_type);
 int ldlm_namespace_cleanup(struct ldlm_namespace *ns, __u64 flags);
 void ldlm_namespace_get(struct ldlm_namespace *ns);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index f9d0383..582cb21 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -621,7 +621,7 @@ static void ldlm_namespace_register(struct ldlm_namespace *ns,
  */
 struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 					  ldlm_side_t client,
-					  ldlm_appetite_t apt,
+					  enum ldlm_appetite apt,
 					  ldlm_ns_type_t ns_type)
 {
 	struct ldlm_namespace *ns = NULL;
-- 
2.1.0
