From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:23 -0400
Subject: [lustre-devel] [PATCH 024/124] staging: lustre: remove RCU2HANDLE
	macro
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-25-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Remove RCU2HANDLE macro from lustre_handles.h.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/11498
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/include/lustre_handles.h |    2 --
 .../lustre/lustre/obdclass/lustre_handles.c        |    7 +++++--
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_handles.h b/drivers/staging/lustre/lustre/include/lustre_handles.h
index bc1dd46..e071bac 100644
--- a/drivers/staging/lustre/lustre/include/lustre_handles.h
+++ b/drivers/staging/lustre/lustre/include/lustre_handles.h
@@ -76,8 +76,6 @@ struct portals_handle {
 	unsigned int			h_in:1;
 };
 
-#define RCU2HANDLE(rcu)    container_of(rcu, struct portals_handle, h_rcu)
-
 /* handles.c */
 
 /* Add a handle to the hash table */
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
index 8faa318..c9445e5 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
@@ -164,8 +164,11 @@ EXPORT_SYMBOL(class_handle2object);
 
 void class_handle_free_cb(struct rcu_head *rcu)
 {
-	struct portals_handle *h = RCU2HANDLE(rcu);
-	void *ptr = (void *)(unsigned long)h->h_cookie;
+	struct portals_handle *h;
+	void *ptr;
+
+	h = container_of(rcu, struct portals_handle, h_rcu);
+	ptr = (void *)(unsigned long)h->h_cookie;
 
 	if (h->h_ops->hop_free)
 		h->h_ops->hop_free(ptr, h->h_size);
-- 
1.7.1
