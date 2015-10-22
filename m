From: James Simmons <jsimmons@infradead.org>
Date: Wed, 21 Oct 2015 21:52:43 -0400
Subject: [lustre-devel] [PATCH 05/11] staging: lustre: move struct netstrfns
	to nidstr.h
In-Reply-To: <1445478769-21203-1-git-send-email-jsimmons@infradead.org>
References: <1445478769-21203-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1445478769-21203-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The reason struct netstrfns exist in nidstrings.c
was to avoid forward decleration errors. The best
way to handle this instead is to move this structure
to a header file. Since this structure is used in
the userland utilities as well so we place it in
nidstr.h which is exposed to userland.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/15083
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/include/linux/lnet/nidstr.h |   13 +++++++++++++
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |   13 -------------
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/nidstr.h b/drivers/staging/lustre/include/linux/lnet/nidstr.h
index 082782b..b32f8cd 100644
--- a/drivers/staging/lustre/include/linux/lnet/nidstr.h
+++ b/drivers/staging/lustre/include/linux/lnet/nidstr.h
@@ -76,4 +76,17 @@ bool cfs_nidrange_is_contiguous(struct list_head *nidlist);
 void cfs_nidrange_find_min_max(struct list_head *nidlist, char *min_nid,
 			       char *max_nid, size_t nidstr_length);
 
+struct netstrfns {
+	int	nf_type;
+	char	*nf_name;
+	char	*nf_modname;
+	void	(*nf_addr2str)(__u32 addr, char *str);
+	int	(*nf_str2addr)(const char *str, int nob, __u32 *addr);
+	int	(*nf_parse_addrlist)(char *str, int len,
+				     struct list_head *list);
+	int	(*nf_print_addrlist)(char *buffer, int count,
+				     struct list_head *list);
+	int	(*nf_match_addr)(__u32 addr, struct list_head *list);
+};
+
 #endif /* _LNET_NIDSTRINGS_H */
diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index fdbdf06..6a778b9 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -208,19 +208,6 @@ libcfs_num_match(__u32 addr, struct list_head *numaddr)
 	return cfs_expr_list_match(addr, el);
 }
 
-struct netstrfns {
-	int	  nf_type;
-	char	*nf_name;
-	char	*nf_modname;
-	void       (*nf_addr2str)(__u32 addr, char *str);
-	int	(*nf_str2addr)(const char *str, int nob, __u32 *addr);
-	int	(*nf_parse_addrlist)(char *str, int len,
-					struct list_head *list);
-	int	(*nf_print_addrlist)(char *buffer, int count,
-				     struct list_head *list);
-	int	(*nf_match_addr)(__u32 addr, struct list_head *list);
-};
-
 static struct netstrfns  libcfs_netstrfns[] = {
 	{/* .nf_type      */  LOLND,
 	 /* .nf_name      */  "lo",
-- 
1.7.1
