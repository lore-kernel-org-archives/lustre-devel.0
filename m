From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:08 -0500
Subject: [lustre-devel] [PATCH 200/622] lnet: remove .nf_min_max handling
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-201-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Kit Westneat <kit.westneat@gmail.com>

The .nf_min_max handling was only used for server side debugging.
This has been removed in the OpenSFS tree as well so lets remove
it here since the code related to nf_min_max handling is not
used.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8939
Lustre-commit: a9b830da51bd ("LU-8939 nodemap: remove deprecated lproc files")
Signed-off-by: Kit Westneat <kit.westneat@gmail.com>
Reviewed-on: https://review.whamcloud.com/24352
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/nidstrings.c | 278 ++-------------------------------------------
 1 file changed, 10 insertions(+), 268 deletions(-)

diff --git a/net/lnet/lnet/nidstrings.c b/net/lnet/lnet/nidstrings.c
index 13338d0..eca5092 100644
--- a/net/lnet/lnet/nidstrings.c
+++ b/net/lnet/lnet/nidstrings.c
@@ -451,264 +451,6 @@ int cfs_print_nidlist(char *buffer, int count, struct list_head *nidlist)
 }
 EXPORT_SYMBOL(cfs_print_nidlist);
 
-/**
- * Determines minimum and maximum addresses for a single
- * numeric address range
- *
- * @ar
- * @min_nid	*min_nid __u32 representation of min NID
- * @max_nid	*max_nid __u32 representation of max NID
- *
- * Return:	-EINVAL unsupported LNET range
- *		-ERANGE non-contiguous LNET range
- */
-static int cfs_ip_ar_min_max(struct addrrange *ar, u32 *min_nid,
-			     u32 *max_nid)
-{
-	struct cfs_expr_list *expr_list;
-	struct cfs_range_expr *range;
-	unsigned int min_ip[4] = { 0 };
-	unsigned int max_ip[4] = { 0 };
-	int cur_octet = 0;
-	bool expect_full_octet = false;
-
-	list_for_each_entry(expr_list, &ar->ar_numaddr_ranges, el_link) {
-		int re_count = 0;
-
-		list_for_each_entry(range, &expr_list->el_exprs, re_link) {
-		/* XXX: add support for multiple & non-contig. re's */
-			if (re_count > 0)
-				return -EINVAL;
-
-			/* if a previous octet was ranged, then all remaining
-			 * octets must be full for contiguous range
-			 */
-			if (expect_full_octet && (range->re_lo != 0 ||
-						  range->re_hi != 255))
-				return -ERANGE;
-
-			if (range->re_stride != 1)
-				return -ERANGE;
-
-			if (range->re_lo > range->re_hi)
-				return -EINVAL;
-
-			if (range->re_lo != range->re_hi)
-				expect_full_octet = true;
-
-			min_ip[cur_octet] = range->re_lo;
-			max_ip[cur_octet] = range->re_hi;
-
-			re_count++;
-		}
-
-		cur_octet++;
-	}
-
-	if (min_nid)
-		*min_nid = ((min_ip[0] << 24) | (min_ip[1] << 16) |
-			    (min_ip[2] << 8) | min_ip[3]);
-
-	if (max_nid)
-		*max_nid = ((max_ip[0] << 24) | (max_ip[1] << 16) |
-			    (max_ip[2] << 8) | max_ip[3]);
-
-	return 0;
-}
-
-/**
- * Determines minimum and maximum addresses for a single
- * numeric address range
- *
- * @ar
- * @min_nid	*min_nid __u32 representation of min NID
- * @max_nid	*max_nid __u32 representation of max NID
- *
- * Return:	-EINVAL unsupported LNET range
- */
-static int cfs_num_ar_min_max(struct addrrange *ar, u32 *min_nid,
-			      u32 *max_nid)
-{
-	struct cfs_expr_list *el;
-	struct cfs_range_expr *re;
-	unsigned int min_addr = 0;
-	unsigned int max_addr = 0;
-
-	list_for_each_entry(el, &ar->ar_numaddr_ranges, el_link) {
-		int re_count = 0;
-
-		list_for_each_entry(re, &el->el_exprs, re_link) {
-			if (re_count > 0)
-				return -EINVAL;
-			if (re->re_lo > re->re_hi)
-				return -EINVAL;
-
-			if (re->re_lo < min_addr || !min_addr)
-				min_addr = re->re_lo;
-			if (re->re_hi > max_addr)
-				max_addr = re->re_hi;
-
-			re_count++;
-		}
-	}
-
-	if (min_nid)
-		*min_nid = min_addr;
-	if (max_nid)
-		*max_nid = max_addr;
-
-	return 0;
-}
-
-/**
- * Takes a linked list of nidrange expressions, determines the minimum
- * and maximum nid and creates appropriate nid structures
- *
- * @nidlist
- * @min_nid	*min_nid string representation of min NID
- * @max_nid	*max_nid string representation of max NID
- *
- * Return:	-EINVAL unsupported LNET range
- *		-ERANGE non-contiguous LNET range
- */
-int cfs_nidrange_find_min_max(struct list_head *nidlist, char *min_nid,
-			      char *max_nid, size_t nidstr_length)
-{
-	struct nidrange *first_nidrange;
-	int netnum;
-	struct netstrfns *nf;
-	char *lndname;
-	u32 min_addr;
-	u32 max_addr;
-	char min_addr_str[IPSTRING_LENGTH];
-	char max_addr_str[IPSTRING_LENGTH];
-	int rc;
-
-	first_nidrange = list_entry(nidlist->next, struct nidrange, nr_link);
-
-	netnum = first_nidrange->nr_netnum;
-	nf = first_nidrange->nr_netstrfns;
-	lndname = nf->nf_name;
-
-	rc = nf->nf_min_max(nidlist, &min_addr, &max_addr);
-	if (rc < 0)
-		return rc;
-
-	nf->nf_addr2str(min_addr, min_addr_str, sizeof(min_addr_str));
-	nf->nf_addr2str(max_addr, max_addr_str, sizeof(max_addr_str));
-
-	snprintf(min_nid, nidstr_length, "%s@%s%d", min_addr_str, lndname,
-		 netnum);
-	snprintf(max_nid, nidstr_length, "%s@%s%d", max_addr_str, lndname,
-		 netnum);
-
-	return 0;
-}
-EXPORT_SYMBOL(cfs_nidrange_find_min_max);
-
-/**
- * Determines the min and max NID values for num LNDs
- *
- * @nidlist
- * @min_nid	*min_nid if provided, returns string representation of min NID
- * @max_nid	*max_nid if provided, returns string representation of max NID
- *
- * Return:	-EINVAL unsupported LNET range
- *		-ERANGE non-contiguous LNET range
- */
-static int cfs_num_min_max(struct list_head *nidlist, u32 *min_nid,
-			   u32 *max_nid)
-{
-	struct nidrange	*nr;
-	struct addrrange *ar;
-	unsigned int tmp_min_addr = 0;
-	unsigned int tmp_max_addr = 0;
-	unsigned int min_addr = 0;
-	unsigned int max_addr = 0;
-	int nidlist_count = 0;
-	int rc;
-
-	list_for_each_entry(nr, nidlist, nr_link) {
-		if (nidlist_count > 0)
-			return -EINVAL;
-
-		list_for_each_entry(ar, &nr->nr_addrranges, ar_link) {
-			rc = cfs_num_ar_min_max(ar, &tmp_min_addr,
-						&tmp_max_addr);
-			if (rc)
-				return rc;
-
-			if (tmp_min_addr < min_addr || !min_addr)
-				min_addr = tmp_min_addr;
-			if (tmp_max_addr > max_addr)
-				max_addr = tmp_min_addr;
-		}
-	}
-
-	if (max_nid)
-		*max_nid = max_addr;
-	if (min_nid)
-		*min_nid = min_addr;
-
-	return 0;
-}
-
-/**
- * Takes an nidlist and determines the minimum and maximum
- * ip addresses.
- *
- * @nidlist
- * @min_nid	*min_nid if provided, returns string representation of min NID
- * @max_nid	*max_nid if provided, returns string representation of max NID
- *
- * Return:	-EINVAL unsupported LNET range
- *		-ERANGE non-contiguous LNET range
- */
-static int cfs_ip_min_max(struct list_head *nidlist, u32 *min_nid,
-			  u32 *max_nid)
-{
-	struct nidrange *nr;
-	struct addrrange *ar;
-	u32 tmp_min_ip_addr = 0;
-	u32 tmp_max_ip_addr = 0;
-	u32 min_ip_addr = 0;
-	u32 max_ip_addr = 0;
-	int nidlist_count = 0;
-	int rc;
-
-	list_for_each_entry(nr, nidlist, nr_link) {
-		if (nidlist_count > 0)
-			return -EINVAL;
-
-		if (nr->nr_all) {
-			min_ip_addr = 0;
-			max_ip_addr = 0xffffffff;
-			break;
-		}
-
-		list_for_each_entry(ar, &nr->nr_addrranges, ar_link) {
-			rc = cfs_ip_ar_min_max(ar, &tmp_min_ip_addr,
-					       &tmp_max_ip_addr);
-			if (rc)
-				return rc;
-
-			if (tmp_min_ip_addr < min_ip_addr || !min_ip_addr)
-				min_ip_addr = tmp_min_ip_addr;
-			if (tmp_max_ip_addr > max_ip_addr)
-				max_ip_addr = tmp_max_ip_addr;
-		}
-
-		nidlist_count++;
-	}
-
-	if (min_nid)
-		*min_nid = min_ip_addr;
-	if (max_nid)
-		*max_nid = max_ip_addr;
-
-	return 0;
-}
-
 static int
 libcfs_lo_str2addr(const char *str, int nob, u32 *addr)
 {
@@ -912,8 +654,8 @@ static int cfs_ip_min_max(struct list_head *nidlist, u32 *min_nid,
 	  .nf_str2addr		= libcfs_lo_str2addr,
 	  .nf_parse_addrlist	= libcfs_num_parse,
 	  .nf_print_addrlist	= libcfs_num_addr_range_print,
-	  .nf_match_addr	= libcfs_num_match,
-	  .nf_min_max		= cfs_num_min_max },
+	  .nf_match_addr	= libcfs_num_match
+	},
 	{ .nf_type		= SOCKLND,
 	  .nf_name		= "tcp",
 	  .nf_modname		= "ksocklnd",
@@ -921,8 +663,8 @@ static int cfs_ip_min_max(struct list_head *nidlist, u32 *min_nid,
 	  .nf_str2addr		= libcfs_ip_str2addr,
 	  .nf_parse_addrlist	= cfs_ip_addr_parse,
 	  .nf_print_addrlist	= libcfs_ip_addr_range_print,
-	  .nf_match_addr	= cfs_ip_addr_match,
-	  .nf_min_max		= cfs_ip_min_max },
+	  .nf_match_addr	= cfs_ip_addr_match
+	},
 	{ .nf_type		= O2IBLND,
 	  .nf_name		= "o2ib",
 	  .nf_modname		= "ko2iblnd",
@@ -930,8 +672,8 @@ static int cfs_ip_min_max(struct list_head *nidlist, u32 *min_nid,
 	  .nf_str2addr		= libcfs_ip_str2addr,
 	  .nf_parse_addrlist	= cfs_ip_addr_parse,
 	  .nf_print_addrlist	= libcfs_ip_addr_range_print,
-	  .nf_match_addr	= cfs_ip_addr_match,
-	  .nf_min_max		= cfs_ip_min_max },
+	  .nf_match_addr	= cfs_ip_addr_match
+	},
 	{ .nf_type		= GNILND,
 	  .nf_name		= "gni",
 	  .nf_modname		= "kgnilnd",
@@ -939,8 +681,8 @@ static int cfs_ip_min_max(struct list_head *nidlist, u32 *min_nid,
 	  .nf_str2addr		= libcfs_num_str2addr,
 	  .nf_parse_addrlist	= libcfs_num_parse,
 	  .nf_print_addrlist	= libcfs_num_addr_range_print,
-	  .nf_match_addr	= libcfs_num_match,
-	  .nf_min_max		= cfs_num_min_max },
+	  .nf_match_addr	= libcfs_num_match
+	},
 	{ .nf_type		= GNIIPLND,
 	  .nf_name		= "gip",
 	  .nf_modname		= "kgnilnd",
@@ -948,8 +690,8 @@ static int cfs_ip_min_max(struct list_head *nidlist, u32 *min_nid,
 	  .nf_str2addr		= libcfs_ip_str2addr,
 	  .nf_parse_addrlist	= cfs_ip_addr_parse,
 	  .nf_print_addrlist	= libcfs_ip_addr_range_print,
-	  .nf_match_addr	= cfs_ip_addr_match,
-	  .nf_min_max		= cfs_ip_min_max },
+	  .nf_match_addr	= cfs_ip_addr_match
+	},
 };
 
 static const size_t libcfs_nnetstrfns = ARRAY_SIZE(libcfs_netstrfns);
-- 
1.8.3.1
