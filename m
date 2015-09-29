From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:43:56 -0400
Subject: [lustre-devel] [PATCH 13/29] staging/lustre: Remove unused function
	class_handle_hash_back()
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-14-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

No callers left.

Reported-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_handles.h  |  1 -
 drivers/staging/lustre/lustre/obdclass/lustre_handles.c | 13 -------------
 2 files changed, 14 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_handles.h b/drivers/staging/lustre/lustre/include/lustre_handles.h
index 726bbd3..4d51c8a 100644
--- a/drivers/staging/lustre/lustre/include/lustre_handles.h
+++ b/drivers/staging/lustre/lustre/include/lustre_handles.h
@@ -86,7 +86,6 @@ struct portals_handle {
 void class_handle_hash(struct portals_handle *,
 		       struct portals_handle_ops *ops);
 void class_handle_unhash(struct portals_handle *);
-void class_handle_hash_back(struct portals_handle *);
 void *class_handle2object(__u64 cookie);
 void class_handle_free_cb(struct rcu_head *rcu);
 int class_handle_init(void);
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
index 97d79da..d19ec15 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
@@ -134,19 +134,6 @@ void class_handle_unhash(struct portals_handle *h)
 }
 EXPORT_SYMBOL(class_handle_unhash);
 
-void class_handle_hash_back(struct portals_handle *h)
-{
-	struct handle_bucket *bucket;
-
-	bucket = handle_hash + (h->h_cookie & HANDLE_HASH_MASK);
-
-	spin_lock(&bucket->lock);
-	list_add_rcu(&h->h_link, &bucket->head);
-	h->h_in = 1;
-	spin_unlock(&bucket->lock);
-}
-EXPORT_SYMBOL(class_handle_hash_back);
-
 void *class_handle2object(__u64 cookie)
 {
 	struct handle_bucket *bucket;
-- 
2.1.0
