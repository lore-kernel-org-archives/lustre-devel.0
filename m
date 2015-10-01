From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:40 -0400
Subject: [lustre-devel] [PATCH 30/32] staging/lustre/ldlm: Remove
	ldlm_namespace_inactive_list()
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-31-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

Since there are no server namespaces, just replace it with
ldlm_cli_inactive_namespace_list pointer.
Also make ldlm_cli_inactive_namespace_list static as it's only
used in ldlm_resource.c

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h | 7 -------
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c | 7 +++----
 2 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index e63a1c9..6cf3f9f 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -42,7 +42,6 @@ extern struct mutex ldlm_srv_namespace_lock;
 extern struct list_head ldlm_srv_namespace_list;
 extern struct mutex ldlm_cli_namespace_lock;
 extern struct list_head ldlm_cli_active_namespace_list;
-extern struct list_head ldlm_cli_inactive_namespace_list;
 
 static inline int ldlm_namespace_nr_read(ldlm_side_t client)
 {
@@ -72,12 +71,6 @@ static inline struct list_head *ldlm_namespace_list(ldlm_side_t client)
 		&ldlm_srv_namespace_list : &ldlm_cli_active_namespace_list;
 }
 
-static inline struct list_head *ldlm_namespace_inactive_list(ldlm_side_t client)
-{
-	return client == LDLM_NAMESPACE_SERVER ?
-		&ldlm_srv_namespace_list : &ldlm_cli_inactive_namespace_list;
-}
-
 static inline struct mutex *ldlm_namespace_lock(ldlm_side_t client)
 {
 	return client == LDLM_NAMESPACE_SERVER ?
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index de1b443..9152423 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -59,7 +59,7 @@ struct mutex ldlm_cli_namespace_lock;
  * inactive list */
 LIST_HEAD(ldlm_cli_active_namespace_list);
 /* Client namespaces that don't have any locks in them */
-LIST_HEAD(ldlm_cli_inactive_namespace_list);
+static LIST_HEAD(ldlm_cli_inactive_namespace_list);
 
 static struct dentry *ldlm_debugfs_dir;
 static struct dentry *ldlm_ns_debugfs_dir;
@@ -609,7 +609,7 @@ static void ldlm_namespace_register(struct ldlm_namespace *ns,
 {
 	mutex_lock(ldlm_namespace_lock(client));
 	LASSERT(list_empty(&ns->ns_list_chain));
-	list_add(&ns->ns_list_chain, ldlm_namespace_inactive_list(client));
+	list_add(&ns->ns_list_chain, &ldlm_cli_inactive_namespace_list);
 	ldlm_namespace_nr_inc(client);
 	mutex_unlock(ldlm_namespace_lock(client));
 }
@@ -1011,8 +1011,7 @@ void ldlm_namespace_move_to_inactive_locked(struct ldlm_namespace *ns,
 {
 	LASSERT(!list_empty(&ns->ns_list_chain));
 	LASSERT(mutex_is_locked(ldlm_namespace_lock(client)));
-	list_move_tail(&ns->ns_list_chain,
-		       ldlm_namespace_inactive_list(client));
+	list_move_tail(&ns->ns_list_chain, &ldlm_cli_inactive_namespace_list);
 }
 
 /** Should be called with ldlm_namespace_lock(client) taken. */
-- 
2.1.0
