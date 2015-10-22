From: James Simmons <jsimmons@infradead.org>
Date: Wed, 21 Oct 2015 21:52:44 -0400
Subject: [lustre-devel] [PATCH 06/11] staging: lustre: move cfs_ip_addr_*
	function from kernel libcfs to LNet
In-Reply-To: <1445478769-21203-1-git-send-email-jsimmons@infradead.org>
References: <1445478769-21203-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1445478769-21203-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Both of cfs_ip_addr_parse and cfs_ip_addr_match which are located in
libcfs kernel module are used only for LNet so move this into the
nidstring handling code where it belongs. Also create user land
versions of these functions in the libcfs user land library.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/15085
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: frank zago <fzago@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_string.h    |    2 -
 drivers/staging/lustre/include/linux/lnet/nidstr.h |    2 +
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |   60 +++++++++++++++++++
 .../staging/lustre/lustre/libcfs/libcfs_string.c   |   62 --------------------
 4 files changed, 62 insertions(+), 64 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
index 908efaa..d8d2e7d 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
@@ -100,7 +100,5 @@ void cfs_expr_list_free(struct cfs_expr_list *expr_list);
 int cfs_expr_list_parse(char *str, int len, unsigned min, unsigned max,
 			struct cfs_expr_list **elpp);
 void cfs_expr_list_free_list(struct list_head *list);
-int cfs_ip_addr_parse(char *str, int len, struct list_head *list);
-int cfs_ip_addr_match(__u32 addr, struct list_head *list);
 
 #endif
diff --git a/drivers/staging/lustre/include/linux/lnet/nidstr.h b/drivers/staging/lustre/include/linux/lnet/nidstr.h
index b32f8cd..1536366 100644
--- a/drivers/staging/lustre/include/linux/lnet/nidstr.h
+++ b/drivers/staging/lustre/include/linux/lnet/nidstr.h
@@ -72,6 +72,8 @@ int cfs_parse_nidlist(char *str, int len, struct list_head *list);
 int cfs_print_nidlist(char *buffer, int count, struct list_head *list);
 int cfs_match_nid(lnet_nid_t nid, struct list_head *list);
 
+int cfs_ip_addr_parse(char *str, int len, struct list_head *list);
+int cfs_ip_addr_match(__u32 addr, struct list_head *list);
 bool cfs_nidrange_is_contiguous(struct list_head *nidlist);
 void cfs_nidrange_find_min_max(struct list_head *nidlist, char *min_nid,
 			       char *max_nid, size_t nidstr_length);
diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index 6a778b9..a02c1f6 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -113,6 +113,44 @@ static int libcfs_ip_str2addr(const char *str, int nob, __u32 *addr)
 	return 0;
 }
 
+int
+cfs_ip_addr_parse(char *str, int len, struct list_head *list)
+{
+	struct cfs_expr_list *el;
+	struct cfs_lstr src;
+	int rc;
+	int i;
+
+	src.ls_str = str;
+	src.ls_len = len;
+	i = 0;
+
+	while (src.ls_str != NULL) {
+		struct cfs_lstr res;
+
+		if (!cfs_gettok(&src, '.', &res)) {
+			rc = -EINVAL;
+			goto out;
+		}
+
+		rc = cfs_expr_list_parse(res.ls_str, res.ls_len, 0, 255, &el);
+		if (rc != 0)
+			goto out;
+
+		list_add_tail(&el->el_link, list);
+		i++;
+	}
+
+	if (i == 4)
+		return 0;
+
+	rc = -EINVAL;
+out:
+	cfs_expr_list_free_list(list);
+
+	return rc;
+}
+
 static int
 libcfs_ip_addr_range_print(char *buffer, int count, struct list_head *list)
 {
@@ -128,6 +166,28 @@ libcfs_ip_addr_range_print(char *buffer, int count, struct list_head *list)
 	return i;
 }
 
+/**
+ * Matches address (\a addr) against address set encoded in \a list.
+ *
+ * \retval 1 if \a addr matches
+ * \retval 0 otherwise
+ */
+int
+cfs_ip_addr_match(__u32 addr, struct list_head *list)
+{
+	struct cfs_expr_list *el;
+	int i = 0;
+
+	list_for_each_entry_reverse(el, list, el_link) {
+		if (!cfs_expr_list_match(addr & 0xff, el))
+			return 0;
+		addr >>= 8;
+		i++;
+	}
+
+	return i == 4;
+}
+
 static void libcfs_decnum_addr2str(__u32 addr, char *str)
 {
 	snprintf(str, LNET_NIDSTR_SIZE, "%u", addr);
diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
index 5166961..d40be53 100644
--- a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
@@ -562,65 +562,3 @@ cfs_expr_list_free_list(struct list_head *list)
 	}
 }
 EXPORT_SYMBOL(cfs_expr_list_free_list);
-
-int
-cfs_ip_addr_parse(char *str, int len, struct list_head *list)
-{
-	struct cfs_expr_list	*el;
-	struct cfs_lstr		src;
-	int			rc;
-	int			i;
-
-	src.ls_str = str;
-	src.ls_len = len;
-	i = 0;
-
-	while (src.ls_str != NULL) {
-		struct cfs_lstr res;
-
-		if (!cfs_gettok(&src, '.', &res)) {
-			rc = -EINVAL;
-			goto out;
-		}
-
-		rc = cfs_expr_list_parse(res.ls_str, res.ls_len, 0, 255, &el);
-		if (rc != 0)
-			goto out;
-
-		list_add_tail(&el->el_link, list);
-		i++;
-	}
-
-	if (i == 4)
-		return 0;
-
-	rc = -EINVAL;
- out:
-	cfs_expr_list_free_list(list);
-
-	return rc;
-}
-EXPORT_SYMBOL(cfs_ip_addr_parse);
-
-/**
- * Matches address (\a addr) against address set encoded in \a list.
- *
- * \retval 1 if \a addr matches
- * \retval 0 otherwise
- */
-int
-cfs_ip_addr_match(__u32 addr, struct list_head *list)
-{
-	struct cfs_expr_list *el;
-	int i = 0;
-
-	list_for_each_entry_reverse(el, list, el_link) {
-		if (!cfs_expr_list_match(addr & 0xff, el))
-			return 0;
-		addr >>= 8;
-		i++;
-	}
-
-	return i == 4;
-}
-EXPORT_SYMBOL(cfs_ip_addr_match);
-- 
1.7.1
