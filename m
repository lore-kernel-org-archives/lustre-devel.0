From: NeilBrown <neilb@suse.com>
Date: Mon, 04 Mar 2019 17:31:39 +1100
Subject: [lustre-devel] [PATCH 25/28] lustre: ldlm: don't access l_resource
 when not locked.
In-Reply-To: <155168107971.31333.14345309795939467246.stgit@noble.brown>
References: <155168107971.31333.14345309795939467246.stgit@noble.brown>
Message-ID: <155168109899.31333.4089899412651911583.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

lock->l_resource can (sometimes) change when the resource
isn't locked.
So dereferencing lock->l_resource and the locking the
resource looks wrong.
As lock_res_and_lock() returns the locked resource, this
code can easily be more obviously correct by using
that return value.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c |   15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index e62dad14d822..830d089774a3 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -425,13 +425,13 @@ static struct ldlm_lock *ldlm_lock_new(struct ldlm_resource *resource)
 int ldlm_lock_change_resource(struct ldlm_namespace *ns, struct ldlm_lock *lock,
 			      const struct ldlm_res_id *new_resid)
 {
-	struct ldlm_resource *oldres = lock->l_resource;
+	struct ldlm_resource *oldres;
 	struct ldlm_resource *newres;
 	int type;
 
-	lock_res_and_lock(lock);
-	if (memcmp(new_resid, &lock->l_resource->lr_name,
-		   sizeof(lock->l_resource->lr_name)) == 0) {
+	oldres = lock_res_and_lock(lock);
+	if (memcmp(new_resid, &oldres->lr_name,
+		   sizeof(oldres->lr_name)) == 0) {
 		/* Nothing to do */
 		unlock_res_and_lock(lock);
 		return 0;
@@ -1573,9 +1573,9 @@ enum ldlm_error ldlm_lock_enqueue(struct ldlm_namespace *ns,
 				  void *cookie, u64 *flags)
 {
 	struct ldlm_lock *lock = *lockp;
-	struct ldlm_resource *res = lock->l_resource;
+	struct ldlm_resource *res;
 
-	lock_res_and_lock(lock);
+	res = lock_res_and_lock(lock);
 	if (lock->l_req_mode == lock->l_granted_mode) {
 		/* The server returned a blocked lock, but it was granted
 		 * before we got a chance to actually enqueue it.  We don't
@@ -1874,9 +1874,8 @@ void ldlm_lock_cancel(struct ldlm_lock *lock)
 	struct ldlm_resource *res;
 	struct ldlm_namespace *ns;
 
-	lock_res_and_lock(lock);
+	res = lock_res_and_lock(lock);
 
-	res = lock->l_resource;
 	ns  = ldlm_res_to_ns(res);
 
 	/* Please do not, no matter how tempting, remove this LBUG without
