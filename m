From: James Simmons <jsimmons@infradead.org>
Date: Wed, 21 Oct 2015 21:52:42 -0400
Subject: [lustre-devel] [PATCH 04/11] staging: lustre: remove
	cfs_ip_addr_free wrapper
In-Reply-To: <1445478769-21203-1-git-send-email-jsimmons@infradead.org>
References: <1445478769-21203-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1445478769-21203-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

No need to have a one line wrapper in libcfs that only
is used to delete a list which is only done once in the
LNet layer.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_string.h    |    1 -
 drivers/staging/lustre/lnet/lnet/config.c          |    2 +-
 .../staging/lustre/lustre/libcfs/libcfs_string.c   |    7 -------
 3 files changed, 1 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
index d178e43..908efaa 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
@@ -102,6 +102,5 @@ int cfs_expr_list_parse(char *str, int len, unsigned min, unsigned max,
 void cfs_expr_list_free_list(struct list_head *list);
 int cfs_ip_addr_parse(char *str, int len, struct list_head *list);
 int cfs_ip_addr_match(__u32 addr, struct list_head *list);
-void cfs_ip_addr_free(struct list_head *list);
 
 #endif
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index b09a438..1b3bc83 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -824,7 +824,7 @@ lnet_match_network_token(char *token, int len, __u32 *ipaddrs, int nip)
 	for (rc = i = 0; !rc && i < nip; i++)
 		rc = cfs_ip_addr_match(ipaddrs[i], &list);
 
-	cfs_ip_addr_free(&list);
+	cfs_expr_list_free_list(&list);
 
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
index 896185f..5166961 100644
--- a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
@@ -624,10 +624,3 @@ cfs_ip_addr_match(__u32 addr, struct list_head *list)
 	return i == 4;
 }
 EXPORT_SYMBOL(cfs_ip_addr_match);
-
-void
-cfs_ip_addr_free(struct list_head *list)
-{
-	cfs_expr_list_free_list(list);
-}
-EXPORT_SYMBOL(cfs_ip_addr_free);
-- 
1.7.1
