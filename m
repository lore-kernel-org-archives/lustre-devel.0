From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:28 -0400
Subject: [lustre-devel] [PATCH 129/151] lnet: fix contiguous range support
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-130-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Kit Westneat <kit.westneat@gmail.com>

This patch fixes the contiguous range check to allow the addition of
multiple "full" ([0-255]) ranges. As part of this change,
is_contiguous and find_min_max are combined as they were always
called together and the logic is fairly similar. This also removes
the multiple range expression support, since it was broken.

WC-bug-id: https://jira.whamcloud.com/browse/LU-LU-8912
Lustre-commit: eac95a6587af ("LU-8912 nodemap: fix contiguous range support")
Signed-off-by: Kit Westneat <kit.westneat@gmail.com>
Signed-off-by: Emoly Liu <emoly@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/24397
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lnet/nidstr.h |   8 +-
 net/lnet/lnet/nidstrings.c       | 324 ++++++++++++++++-----------------------
 2 files changed, 133 insertions(+), 199 deletions(-)

diff --git a/include/uapi/linux/lnet/nidstr.h b/include/uapi/linux/lnet/nidstr.h
index 8bff1fd..43ec232 100644
--- a/include/uapi/linux/lnet/nidstr.h
+++ b/include/uapi/linux/lnet/nidstr.h
@@ -97,9 +97,8 @@ static inline char *libcfs_nid2str(lnet_nid_t nid)
 
 int cfs_ip_addr_parse(char *str, int len, struct list_head *list);
 int cfs_ip_addr_match(__u32 addr, struct list_head *list);
-bool cfs_nidrange_is_contiguous(struct list_head *nidlist);
-void cfs_nidrange_find_min_max(struct list_head *nidlist, char *min_nid,
-			       char *max_nid, size_t nidstr_length);
+int cfs_nidrange_find_min_max(struct list_head *nidlist, char *min_nid,
+			      char *max_nid, size_t nidstr_length);
 
 struct netstrfns {
 	__u32	nf_type;
@@ -112,8 +111,7 @@ struct netstrfns {
 	int	(*nf_print_addrlist)(char *buffer, int count,
 				     struct list_head *list);
 	int	(*nf_match_addr)(__u32 addr, struct list_head *list);
-	bool	(*nf_is_contiguous)(struct list_head *nidlist);
-	void	(*nf_min_max)(struct list_head *nidlist, __u32 *min_nid,
+	int	(*nf_min_max)(struct list_head *nidlist, __u32 *min_nid,
 			      __u32 *max_nid);
 };
 
diff --git a/net/lnet/lnet/nidstrings.c b/net/lnet/lnet/nidstrings.c
index b84708d..b4e38e5 100644
--- a/net/lnet/lnet/nidstrings.c
+++ b/net/lnet/lnet/nidstrings.c
@@ -456,38 +456,64 @@ int cfs_print_nidlist(char *buffer, int count, struct list_head *nidlist)
  * numeric address range
  *
  * @ar
- * @min_nid
- * @max_nid
+ * @min_nid	*min_nid __u32 representation of min NID
+ * @max_nid	*max_nid __u32 representation of max NID
+ *
+ * Return:	-EINVAL unsupported LNET range
+ *		-ERANGE non-contiguous LNET range
  */
-static void cfs_ip_ar_min_max(struct addrrange *ar, u32 *min_nid,
-			      u32 *max_nid)
+static int cfs_ip_ar_min_max(struct addrrange *ar, u32 *min_nid,
+			     u32 *max_nid)
 {
-	struct cfs_expr_list *el;
-	struct cfs_range_expr *re;
-	u32 tmp_ip_addr = 0;
+	struct cfs_expr_list *expr_list;
+	struct cfs_range_expr *range;
 	unsigned int min_ip[4] = { 0 };
 	unsigned int max_ip[4] = { 0 };
-	int re_count = 0;
+	int cur_octet = 0;
+	bool expect_full_octet = false;
+
+	list_for_each_entry(expr_list, &ar->ar_numaddr_ranges, el_link) {
+		int re_count = 0;
+
+		list_for_each_entry(range, &expr_list->el_exprs, re_link) {
+		/* XXX: add support for multiple & non-contig. re's */
+			if (re_count > 0)
+				return -EINVAL;
+
+			/* if a previous octet was ranged, then all remaining
+			 * octets must be full for contiguous range
+			 */
+			if (expect_full_octet && (range->re_lo != 0 ||
+						  range->re_hi != 255))
+				return -ERANGE;
+
+			if (range->re_stride != 1)
+				return -ERANGE;
+
+			if (range->re_lo > range->re_hi)
+				return -EINVAL;
+
+			if (range->re_lo != range->re_hi)
+				expect_full_octet = true;
+
+			min_ip[cur_octet] = range->re_lo;
+			max_ip[cur_octet] = range->re_hi;
 
-	list_for_each_entry(el, &ar->ar_numaddr_ranges, el_link) {
-		list_for_each_entry(re, &el->el_exprs, re_link) {
-			min_ip[re_count] = re->re_lo;
-			max_ip[re_count] = re->re_hi;
 			re_count++;
 		}
-	}
 
-	tmp_ip_addr = ((min_ip[0] << 24) | (min_ip[1] << 16) |
-		       (min_ip[2] << 8) | min_ip[3]);
+		cur_octet++;
+	}
 
 	if (min_nid)
-		*min_nid = tmp_ip_addr;
-
-	tmp_ip_addr = ((max_ip[0] << 24) | (max_ip[1] << 16) |
-		       (max_ip[2] << 8) | max_ip[3]);
+		*min_nid = ((min_ip[0] << 24) | (min_ip[1] << 16) |
+			    (min_ip[2] << 8) | min_ip[3]);
 
 	if (max_nid)
-		*max_nid = tmp_ip_addr;
+		*max_nid = ((max_ip[0] << 24) | (max_ip[1] << 16) |
+			    (max_ip[2] << 8) | max_ip[3]);
+
+	return 0;
 }
 
 /**
@@ -495,11 +521,13 @@ static void cfs_ip_ar_min_max(struct addrrange *ar, u32 *min_nid,
  * numeric address range
  *
  * @ar
- * @min_nid
- * @max_nid
+ * @min_nid	*min_nid __u32 representation of min NID
+ * @max_nid	*max_nid __u32 representation of max NID
+ *
+ * Return:	-EINVAL unsupported LNET range
  */
-static void cfs_num_ar_min_max(struct addrrange *ar, u32 *min_nid,
-			       u32 *max_nid)
+static int cfs_num_ar_min_max(struct addrrange *ar, u32 *min_nid,
+			      u32 *max_nid)
 {
 	struct cfs_expr_list *el;
 	struct cfs_range_expr *re;
@@ -507,11 +535,20 @@ static void cfs_num_ar_min_max(struct addrrange *ar, u32 *min_nid,
 	unsigned int max_addr = 0;
 
 	list_for_each_entry(el, &ar->ar_numaddr_ranges, el_link) {
+		int re_count = 0;
+
 		list_for_each_entry(re, &el->el_exprs, re_link) {
+			if (re_count > 0)
+				return -EINVAL;
+			if (re->re_lo > re->re_hi)
+				return -EINVAL;
+
 			if (re->re_lo < min_addr || !min_addr)
 				min_addr = re->re_lo;
 			if (re->re_hi > max_addr)
 				max_addr = re->re_hi;
+
+			re_count++;
 		}
 	}
 
@@ -519,143 +556,8 @@ static void cfs_num_ar_min_max(struct addrrange *ar, u32 *min_nid,
 		*min_nid = min_addr;
 	if (max_nid)
 		*max_nid = max_addr;
-}
-
-/**
- * Determines whether an expression list in an nidrange contains exactly
- * one contiguous address range. Calls the correct netstrfns for the LND
- *
- * @nidlist
- *
- * Return:	true if contiguous
- *		false if not contiguous
- */
-bool cfs_nidrange_is_contiguous(struct list_head *nidlist)
-{
-	struct nidrange *nr;
-	struct netstrfns *nf = NULL;
-	char *lndname = NULL;
-	int netnum = -1;
-
-	list_for_each_entry(nr, nidlist, nr_link) {
-		nf = nr->nr_netstrfns;
-		if (!lndname)
-			lndname = nf->nf_name;
-		if (netnum == -1)
-			netnum = nr->nr_netnum;
-
-		if (strcmp(lndname, nf->nf_name) ||
-		    netnum != nr->nr_netnum)
-			return false;
-	}
-
-	if (!nf)
-		return false;
-
-	if (!nf->nf_is_contiguous(nidlist))
-		return false;
-
-	return true;
-}
-EXPORT_SYMBOL(cfs_nidrange_is_contiguous);
-
-/**
- * Determines whether an expression list in an num nidrange contains exactly
- * one contiguous address range.
- *
- * @nidlist
- *
- * Return:	true if contiguous
- *		false if not contiguous
- */
-static bool cfs_num_is_contiguous(struct list_head *nidlist)
-{
-	struct nidrange *nr;
-	struct addrrange *ar;
-	struct cfs_expr_list *el;
-	struct cfs_range_expr *re;
-	int last_hi = 0;
-	u32 last_end_nid = 0;
-	u32 current_start_nid = 0;
-	u32 current_end_nid = 0;
-
-	list_for_each_entry(nr, nidlist, nr_link) {
-		list_for_each_entry(ar, &nr->nr_addrranges, ar_link) {
-			cfs_num_ar_min_max(ar, &current_start_nid,
-					   &current_end_nid);
-			if (last_end_nid &&
-			    (current_start_nid - last_end_nid != 1))
-				return false;
-			last_end_nid = current_end_nid;
-			list_for_each_entry(el, &ar->ar_numaddr_ranges,
-					    el_link) {
-				list_for_each_entry(re, &el->el_exprs,
-						    re_link) {
-					if (re->re_stride > 1)
-						return false;
-					else if (last_hi &&
-						 re->re_hi - last_hi != 1)
-						return false;
-					last_hi = re->re_hi;
-				}
-			}
-		}
-	}
 
-	return true;
-}
-
-/**
- * Determines whether an expression list in an ip nidrange contains exactly
- * one contiguous address range.
- *
- * @nidlist
- *
- * Return:	true if contiguous
- *		false if not contiguous
- */
-static bool cfs_ip_is_contiguous(struct list_head *nidlist)
-{
-	struct nidrange *nr;
-	struct addrrange *ar;
-	struct cfs_expr_list *el;
-	struct cfs_range_expr *re;
-	int expr_count;
-	int last_hi = 255;
-	int last_diff = 0;
-	u32 last_end_nid = 0;
-	u32 current_start_nid = 0;
-	u32 current_end_nid = 0;
-
-	list_for_each_entry(nr, nidlist, nr_link) {
-		list_for_each_entry(ar, &nr->nr_addrranges, ar_link) {
-			last_hi = 255;
-			last_diff = 0;
-			cfs_ip_ar_min_max(ar, &current_start_nid,
-					  &current_end_nid);
-			if (last_end_nid &&
-			    (current_start_nid - last_end_nid != 1))
-				return false;
-			last_end_nid = current_end_nid;
-			list_for_each_entry(el, &ar->ar_numaddr_ranges,
-					    el_link) {
-				expr_count = 0;
-				list_for_each_entry(re, &el->el_exprs,
-						    re_link) {
-					expr_count++;
-					if (re->re_stride > 1 ||
-					    (last_diff > 0 && last_hi != 255) ||
-					    (last_diff > 0 && last_hi == 255 &&
-					     re->re_lo > 0))
-						return false;
-					last_hi = re->re_hi;
-					last_diff = re->re_hi - re->re_lo;
-				}
-			}
-		}
-	}
-
-	return true;
+	return 0;
 }
 
 /**
@@ -663,29 +565,35 @@ static bool cfs_ip_is_contiguous(struct list_head *nidlist)
  * and maximum nid and creates appropriate nid structures
  *
  * @nidlist
- * @min_nid
- * @max_nid
+ * @min_nid	*min_nid string representation of min NID
+ * @max_nid	*max_nid string representation of max NID
+ *
+ * Return:	-EINVAL unsupported LNET range
+ *		-ERANGE non-contiguous LNET range
  */
-void cfs_nidrange_find_min_max(struct list_head *nidlist, char *min_nid,
-			       char *max_nid, size_t nidstr_length)
+int cfs_nidrange_find_min_max(struct list_head *nidlist, char *min_nid,
+			      char *max_nid, size_t nidstr_length)
 {
-	struct nidrange *nr;
-	struct netstrfns *nf = NULL;
-	int netnum = -1;
+	struct nidrange *first_nidrange;
+	int netnum;
+	struct netstrfns *nf;
+	char *lndname;
 	u32 min_addr;
 	u32 max_addr;
-	char *lndname = NULL;
 	char min_addr_str[IPSTRING_LENGTH];
 	char max_addr_str[IPSTRING_LENGTH];
+	int rc;
 
-	list_for_each_entry(nr, nidlist, nr_link) {
-		nf = nr->nr_netstrfns;
-		lndname = nf->nf_name;
-		if (netnum == -1)
-			netnum = nr->nr_netnum;
+	first_nidrange = list_entry(nidlist->next, struct nidrange, nr_link);
+
+	netnum = first_nidrange->nr_netnum;
+	nf = first_nidrange->nr_netstrfns;
+	lndname = nf->nf_name;
+
+	rc = nf->nf_min_max(nidlist, &min_addr, &max_addr);
+	if (rc < 0)
+		return rc;
 
-		nf->nf_min_max(nidlist, &min_addr, &max_addr);
-	}
 	nf->nf_addr2str(min_addr, min_addr_str, sizeof(min_addr_str));
 	nf->nf_addr2str(max_addr, max_addr_str, sizeof(max_addr_str));
 
@@ -693,6 +601,8 @@ void cfs_nidrange_find_min_max(struct list_head *nidlist, char *min_nid,
 		 netnum);
 	snprintf(max_nid, nidstr_length, "%s@%s%d", max_addr_str, lndname,
 		 netnum);
+
+	return 0;
 }
 EXPORT_SYMBOL(cfs_nidrange_find_min_max);
 
@@ -700,11 +610,14 @@ void cfs_nidrange_find_min_max(struct list_head *nidlist, char *min_nid,
  * Determines the min and max NID values for num LNDs
  *
  * @nidlist
- * @min_nid
- * @max_nid
+ * @min_nid	*min_nid if provided, returns string representation of min NID
+ * @max_nid	*max_nid if provided, returns string representation of max NID
+ *
+ * Return:	-EINVAL unsupported LNET range
+ *		-ERANGE non-contiguous LNET range
  */
-static void cfs_num_min_max(struct list_head *nidlist, u32 *min_nid,
-			    u32 *max_nid)
+static int cfs_num_min_max(struct list_head *nidlist, u32 *min_nid,
+			   u32 *max_nid)
 {
 	struct nidrange	*nr;
 	struct addrrange *ar;
@@ -712,19 +625,32 @@ static void cfs_num_min_max(struct list_head *nidlist, u32 *min_nid,
 	unsigned int tmp_max_addr = 0;
 	unsigned int min_addr = 0;
 	unsigned int max_addr = 0;
+	int nidlist_count = 0;
+	int rc;
 
 	list_for_each_entry(nr, nidlist, nr_link) {
+		if (nidlist_count > 0)
+			return -EINVAL;
+
 		list_for_each_entry(ar, &nr->nr_addrranges, ar_link) {
-			cfs_num_ar_min_max(ar, &tmp_min_addr,
-					   &tmp_max_addr);
+			rc = cfs_num_ar_min_max(ar, &tmp_min_addr,
+						&tmp_max_addr);
+			if (rc)
+				return rc;
+
 			if (tmp_min_addr < min_addr || !min_addr)
 				min_addr = tmp_min_addr;
 			if (tmp_max_addr > max_addr)
 				max_addr = tmp_min_addr;
 		}
 	}
-	*max_nid = max_addr;
-	*min_nid = min_addr;
+
+	if (max_nid)
+		*max_nid = max_addr;
+	if (min_nid)
+		*min_nid = min_addr;
+
+	return 0;
 }
 
 /**
@@ -732,11 +658,14 @@ static void cfs_num_min_max(struct list_head *nidlist, u32 *min_nid,
  * ip addresses.
  *
  * @nidlist
- * @min_nid
- * @max_nid
+ * @min_nid	*min_nid if provided, returns string representation of min NID
+ * @max_nid	*max_nid if provided, returns string representation of max NID
+ *
+ * Return:	-EINVAL unsupported LNET range
+ *		-ERANGE non-contiguous LNET range
  */
-static void cfs_ip_min_max(struct list_head *nidlist, u32 *min_nid,
-			   u32 *max_nid)
+static int cfs_ip_min_max(struct list_head *nidlist, u32 *min_nid,
+			  u32 *max_nid)
 {
 	struct nidrange *nr;
 	struct addrrange *ar;
@@ -744,22 +673,34 @@ static void cfs_ip_min_max(struct list_head *nidlist, u32 *min_nid,
 	u32 tmp_max_ip_addr = 0;
 	u32 min_ip_addr = 0;
 	u32 max_ip_addr = 0;
+	int nidlist_count = 0;
+	int rc;
 
 	list_for_each_entry(nr, nidlist, nr_link) {
+		if (nidlist_count > 0)
+			return -EINVAL;
+
 		list_for_each_entry(ar, &nr->nr_addrranges, ar_link) {
-			cfs_ip_ar_min_max(ar, &tmp_min_ip_addr,
-					  &tmp_max_ip_addr);
+			rc = cfs_ip_ar_min_max(ar, &tmp_min_ip_addr,
+					       &tmp_max_ip_addr);
+			if (rc)
+				return rc;
+
 			if (tmp_min_ip_addr < min_ip_addr || !min_ip_addr)
 				min_ip_addr = tmp_min_ip_addr;
 			if (tmp_max_ip_addr > max_ip_addr)
 				max_ip_addr = tmp_max_ip_addr;
 		}
+
+		nidlist_count++;
 	}
 
 	if (min_nid)
 		*min_nid = min_ip_addr;
 	if (max_nid)
 		*max_nid = max_ip_addr;
+
+	return 0;
 }
 
 static int
@@ -966,7 +907,6 @@ static void cfs_ip_min_max(struct list_head *nidlist, u32 *min_nid,
 	  .nf_parse_addrlist	= libcfs_num_parse,
 	  .nf_print_addrlist	= libcfs_num_addr_range_print,
 	  .nf_match_addr	= libcfs_num_match,
-	  .nf_is_contiguous	= cfs_num_is_contiguous,
 	  .nf_min_max		= cfs_num_min_max },
 	{ .nf_type		= SOCKLND,
 	  .nf_name		= "tcp",
@@ -976,7 +916,6 @@ static void cfs_ip_min_max(struct list_head *nidlist, u32 *min_nid,
 	  .nf_parse_addrlist	= cfs_ip_addr_parse,
 	  .nf_print_addrlist	= libcfs_ip_addr_range_print,
 	  .nf_match_addr	= cfs_ip_addr_match,
-	  .nf_is_contiguous	= cfs_ip_is_contiguous,
 	  .nf_min_max		= cfs_ip_min_max },
 	{ .nf_type		= O2IBLND,
 	  .nf_name		= "o2ib",
@@ -986,7 +925,6 @@ static void cfs_ip_min_max(struct list_head *nidlist, u32 *min_nid,
 	  .nf_parse_addrlist	= cfs_ip_addr_parse,
 	  .nf_print_addrlist	= libcfs_ip_addr_range_print,
 	  .nf_match_addr	= cfs_ip_addr_match,
-	  .nf_is_contiguous	= cfs_ip_is_contiguous,
 	  .nf_min_max		= cfs_ip_min_max },
 	{ .nf_type		= GNILND,
 	  .nf_name		= "gni",
@@ -996,7 +934,6 @@ static void cfs_ip_min_max(struct list_head *nidlist, u32 *min_nid,
 	  .nf_parse_addrlist	= libcfs_num_parse,
 	  .nf_print_addrlist	= libcfs_num_addr_range_print,
 	  .nf_match_addr	= libcfs_num_match,
-	  .nf_is_contiguous	= cfs_num_is_contiguous,
 	  .nf_min_max		= cfs_num_min_max },
 	{ .nf_type		= GNIIPLND,
 	  .nf_name		= "gip",
@@ -1006,7 +943,6 @@ static void cfs_ip_min_max(struct list_head *nidlist, u32 *min_nid,
 	  .nf_parse_addrlist	= cfs_ip_addr_parse,
 	  .nf_print_addrlist	= libcfs_ip_addr_range_print,
 	  .nf_match_addr	= cfs_ip_addr_match,
-	  .nf_is_contiguous	= cfs_ip_is_contiguous,
 	  .nf_min_max		= cfs_ip_min_max },
 };
 
-- 
1.8.3.1
