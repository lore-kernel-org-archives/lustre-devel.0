From: NeilBrown <neilb@suse.com>
Date: Wed, 13 Dec 2017 14:15:54 +1100
Subject: [lustre-devel] [PATCH 05/12] staging: lustre: ldlm: use
 list_for_each_entry in ldlm_resource.c
In-Reply-To: <151313493380.27582.16490205348451477393.stgit@noble>
References: <151313493380.27582.16490205348451477393.stgit@noble>
Message-ID: <151313495491.27582.1409394419999876978.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

Having a stand-alone "list_entry()" call is often a sign
that something like "list_for_each_entry()" would
make the code clearer.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |   20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 2689ffdf10e3..9958533cc227 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -752,24 +752,22 @@ extern struct ldlm_lock *ldlm_lock_get(struct ldlm_lock *lock);
 static void cleanup_resource(struct ldlm_resource *res, struct list_head *q,
 			     __u64 flags)
 {
-	struct list_head *tmp;
 	int rc = 0;
 	bool local_only = !!(flags & LDLM_FL_LOCAL_ONLY);
 
 	do {
-		struct ldlm_lock *lock = NULL;
+		struct ldlm_lock *lock = NULL, *tmp;
 		struct lustre_handle lockh;
 
 		/* First, we look for non-cleaned-yet lock
 		 * all cleaned locks are marked by CLEANED flag.
 		 */
 		lock_res(res);
-		list_for_each(tmp, q) {
-			lock = list_entry(tmp, struct ldlm_lock, l_res_link);
-			if (ldlm_is_cleaned(lock)) {
-				lock = NULL;
+		list_for_each_entry(tmp, q, l_res_link) {
+			if (ldlm_is_cleaned(tmp))
 				continue;
-			}
+
+			lock = tmp;
 			LDLM_LOCK_GET(lock);
 			ldlm_set_cleaned(lock);
 			break;
@@ -1283,19 +1281,15 @@ void ldlm_res2desc(struct ldlm_resource *res, struct ldlm_resource_desc *desc)
  */
 void ldlm_dump_all_namespaces(enum ldlm_side client, int level)
 {
-	struct list_head *tmp;
+	struct ldlm_namespace *ns;
 
 	if (!((libcfs_debug | D_ERROR) & level))
 		return;
 
 	mutex_lock(ldlm_namespace_lock(client));
 
-	list_for_each(tmp, ldlm_namespace_list(client)) {
-		struct ldlm_namespace *ns;
-
-		ns = list_entry(tmp, struct ldlm_namespace, ns_list_chain);
+	list_for_each_entry(ns, ldlm_namespace_list(client), ns_list_chain)
 		ldlm_namespace_dump(level, ns);
-	}
 
 	mutex_unlock(ldlm_namespace_lock(client));
 }
