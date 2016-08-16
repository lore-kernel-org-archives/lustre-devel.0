From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:19:25 -0400
Subject: [lustre-devel] [PATCH 72/80] staging: lustre: obd: validate open
	handle cookies
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-73-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Add a const void *h_owner member to struct portals_handle. Add a const
void *owner parameter to class_handle2object() which must be matched
by the h_owner member of the handle in addition to the cookie.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3233
Reviewed-on: http://review.whamcloud.com/6938
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/include/lustre_handles.h |    3 ++-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |    2 +-
 drivers/staging/lustre/lustre/obdclass/genops.c    |    2 +-
 .../lustre/lustre/obdclass/lustre_handles.c        |    4 ++--
 4 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_handles.h b/drivers/staging/lustre/lustre/include/lustre_handles.h
index 1a63a6b..bc1dd46 100644
--- a/drivers/staging/lustre/lustre/include/lustre_handles.h
+++ b/drivers/staging/lustre/lustre/include/lustre_handles.h
@@ -66,6 +66,7 @@ struct portals_handle_ops {
 struct portals_handle {
 	struct list_head			h_link;
 	__u64				h_cookie;
+	const void			*h_owner;
 	struct portals_handle_ops	*h_ops;
 
 	/* newly added fields to handle the RCU issue. -jxiong */
@@ -83,7 +84,7 @@ struct portals_handle {
 void class_handle_hash(struct portals_handle *,
 		       struct portals_handle_ops *ops);
 void class_handle_unhash(struct portals_handle *);
-void *class_handle2object(__u64 cookie);
+void *class_handle2object(__u64 cookie, const void *owner);
 void class_handle_free_cb(struct rcu_head *rcu);
 int class_handle_init(void);
 void class_handle_cleanup(void);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index a91cdb4..7a34caf 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -542,7 +542,7 @@ struct ldlm_lock *__ldlm_handle2lock(const struct lustre_handle *handle,
 
 	LASSERT(handle);
 
-	lock = class_handle2object(handle->cookie);
+	lock = class_handle2object(handle->cookie, NULL);
 	if (!lock)
 		return NULL;
 
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index be25434..a739eb1 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -618,7 +618,7 @@ struct obd_export *class_conn2export(struct lustre_handle *conn)
 	}
 
 	CDEBUG(D_INFO, "looking for export cookie %#llx\n", conn->cookie);
-	export = class_handle2object(conn->cookie);
+	export = class_handle2object(conn->cookie, NULL);
 	return export;
 }
 EXPORT_SYMBOL(class_conn2export);
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
index 082f530..7ca68ae 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
@@ -130,7 +130,7 @@ void class_handle_unhash(struct portals_handle *h)
 }
 EXPORT_SYMBOL(class_handle_unhash);
 
-void *class_handle2object(__u64 cookie)
+void *class_handle2object(__u64 cookie, const void *owner)
 {
 	struct handle_bucket *bucket;
 	struct portals_handle *h;
@@ -145,7 +145,7 @@ void *class_handle2object(__u64 cookie)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(h, &bucket->head, h_link) {
-		if (h->h_cookie != cookie)
+		if (h->h_cookie != cookie || h->h_owner != owner)
 			continue;
 
 		spin_lock(&h->h_lock);
-- 
1.7.1
