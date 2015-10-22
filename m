From: James Simmons <jsimmons@infradead.org>
Date: Wed, 21 Oct 2015 21:52:46 -0400
Subject: [lustre-devel] [PATCH 08/11] staging: lustre: add in NID range
	management for libcfs
In-Reply-To: <1445478769-21203-1-git-send-email-jsimmons@infradead.org>
References: <1445478769-21203-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1445478769-21203-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Joshua Walgenbach <jjw@iu.edu>

This is a partial backport of the NID range management
added in for nodemap. We only backport the libcfs related
parts here.

Signed-off-by: Joshua Walgenbach <jjw@iu.edu>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3527
Reviewed-on: http://review.whamcloud.com/8057
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Andrew Perepechko <andrew_perepechko@xyratex.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Ken Hornstein <kenh@cmf.nrl.navy.mil>
---
 drivers/staging/lustre/include/linux/lnet/nidstr.h |    3 +
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |  365 +++++++++++++++++++-
 2 files changed, 355 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/nidstr.h b/drivers/staging/lustre/include/linux/lnet/nidstr.h
index 1536366..4e7c9a5 100644
--- a/drivers/staging/lustre/include/linux/lnet/nidstr.h
+++ b/drivers/staging/lustre/include/linux/lnet/nidstr.h
@@ -89,6 +89,9 @@ struct netstrfns {
 	int	(*nf_print_addrlist)(char *buffer, int count,
 				     struct list_head *list);
 	int	(*nf_match_addr)(__u32 addr, struct list_head *list);
+	bool	(*nf_is_contiguous)(struct list_head *nidlist);
+	void	(*nf_min_max)(struct list_head *nidlist, __u32 *min_nid,
+			      __u32 *max_nid);
 };
 
 #endif /* _LNET_NIDSTRINGS_H */
diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index 1874dfe..4402b80 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -46,6 +46,8 @@
 /* max value for numeric network address */
 #define MAX_NUMERIC_VALUE 0xffffffff
 
+#define IPSTRING_LENGTH 16
+
 /* CAVEAT VENDITOR! Keep the canonical string representation of nets/nids
  * consistent in all conversion functions.  Some code fragments are copied
  * around for the sake of clarity...
@@ -456,6 +458,317 @@ int cfs_print_nidlist(char *buffer, int count, struct list_head *nidlist)
 }
 EXPORT_SYMBOL(cfs_print_nidlist);
 
+/**
+ * Determines minimum and maximum addresses for a single
+ * numeric address range
+ *
+ * \param	ar
+ * \param	min_nid
+ * \param	max_nid
+ */
+static void cfs_ip_ar_min_max(struct addrrange *ar, __u32 *min_nid,
+			      __u32 *max_nid)
+{
+	struct cfs_expr_list *el;
+	struct cfs_range_expr *re;
+	__u32 tmp_ip_addr = 0;
+	unsigned int min_ip[4] = {0};
+	unsigned int max_ip[4] = {0};
+	int re_count = 0;
+
+	list_for_each_entry(el, &ar->ar_numaddr_ranges, el_link) {
+		list_for_each_entry(re, &el->el_exprs, re_link) {
+			min_ip[re_count] = re->re_lo;
+			max_ip[re_count] = re->re_hi;
+			re_count++;
+		}
+	}
+
+	tmp_ip_addr = ((min_ip[0] << 24) | (min_ip[1] << 16) |
+		       (min_ip[2] << 8) | min_ip[3]);
+
+	if (min_nid != NULL)
+		*min_nid = tmp_ip_addr;
+
+	tmp_ip_addr = ((max_ip[0] << 24) | (max_ip[1] << 16) |
+		       (max_ip[2] << 8) | max_ip[3]);
+
+	if (max_nid != NULL)
+		*max_nid = tmp_ip_addr;
+}
+
+/**
+ * Determines minimum and maximum addresses for a single
+ * numeric address range
+ *
+ * \param	ar
+ * \param	min_nid
+ * \param	max_nid
+ */
+static void cfs_num_ar_min_max(struct addrrange *ar, __u32 *min_nid,
+			       __u32 *max_nid)
+{
+	struct cfs_expr_list *el;
+	struct cfs_range_expr *re;
+	unsigned int min_addr = 0;
+	unsigned int max_addr = 0;
+
+	list_for_each_entry(el, &ar->ar_numaddr_ranges, el_link) {
+		list_for_each_entry(re, &el->el_exprs, re_link) {
+			if (re->re_lo < min_addr || min_addr == 0)
+				min_addr = re->re_lo;
+			if (re->re_hi > max_addr)
+				max_addr = re->re_hi;
+		}
+	}
+
+	if (min_nid != NULL)
+		*min_nid = min_addr;
+	if (max_nid != NULL)
+		*max_nid = max_addr;
+}
+
+/**
+ * Determines whether an expression list in an nidrange contains exactly
+ * one contiguous address range. Calls the correct netstrfns for the LND
+ *
+ * \param	*nidlist
+ *
+ * \retval	true if contiguous
+ * \retval	false if not contiguous
+ */
+bool cfs_nidrange_is_contiguous(struct list_head *nidlist)
+{
+	struct nidrange *nr;
+	struct netstrfns *nf = NULL;
+	char *lndname = NULL;
+	int netnum = -1;
+
+	list_for_each_entry(nr, nidlist, nr_link) {
+		nf = nr->nr_netstrfns;
+		if (lndname == NULL)
+			lndname = nf->nf_name;
+		if (netnum == -1)
+			netnum = nr->nr_netnum;
+
+		if (strcmp(lndname, nf->nf_name) != 0 ||
+		    netnum != nr->nr_netnum)
+			return false;
+	}
+
+	if (nf == NULL)
+		return false;
+
+	if (!nf->nf_is_contiguous(nidlist))
+		return false;
+
+	return true;
+}
+EXPORT_SYMBOL(cfs_nidrange_is_contiguous);
+
+/**
+ * Determines whether an expression list in an num nidrange contains exactly
+ * one contiguous address range.
+ *
+ * \param	*nidlist
+ *
+ * \retval	true if contiguous
+ * \retval	false if not contiguous
+ */
+static bool cfs_num_is_contiguous(struct list_head *nidlist)
+{
+	struct nidrange *nr;
+	struct addrrange *ar;
+	struct cfs_expr_list *el;
+	struct cfs_range_expr *re;
+	int last_hi = 0;
+	__u32 last_end_nid = 0;
+	__u32 current_start_nid = 0;
+	__u32 current_end_nid = 0;
+
+	list_for_each_entry(nr, nidlist, nr_link) {
+		list_for_each_entry(ar, &nr->nr_addrranges, ar_link) {
+			cfs_num_ar_min_max(ar, &current_start_nid,
+					   &current_end_nid);
+			if (last_end_nid != 0 &&
+			    (current_start_nid - last_end_nid != 1))
+				return false;
+			last_end_nid = current_end_nid;
+			list_for_each_entry(el, &ar->ar_numaddr_ranges,
+					    el_link) {
+				list_for_each_entry(re, &el->el_exprs,
+						    re_link) {
+					if (re->re_stride > 1)
+						return false;
+					else if (last_hi != 0 &&
+						 re->re_hi - last_hi != 1)
+						return false;
+					last_hi = re->re_hi;
+				}
+			}
+		}
+	}
+
+	return true;
+}
+
+/**
+ * Determines whether an expression list in an ip nidrange contains exactly
+ * one contiguous address range.
+ *
+ * \param	*nidlist
+ *
+ * \retval	true if contiguous
+ * \retval	false if not contiguous
+ */
+static bool cfs_ip_is_contiguous(struct list_head *nidlist)
+{
+	struct nidrange *nr;
+	struct addrrange *ar;
+	struct cfs_expr_list *el;
+	struct cfs_range_expr *re;
+	int expr_count;
+	int last_hi = 255;
+	int last_diff = 0;
+	__u32 last_end_nid = 0;
+	__u32 current_start_nid = 0;
+	__u32 current_end_nid = 0;
+
+	list_for_each_entry(nr, nidlist, nr_link) {
+		list_for_each_entry(ar, &nr->nr_addrranges, ar_link) {
+			last_hi = 255;
+			last_diff = 0;
+			cfs_ip_ar_min_max(ar, &current_start_nid,
+					  &current_end_nid);
+			if (last_end_nid != 0 &&
+			    (current_start_nid - last_end_nid != 1))
+				return false;
+			last_end_nid = current_end_nid;
+			list_for_each_entry(el, &ar->ar_numaddr_ranges,
+					    el_link) {
+				expr_count = 0;
+				list_for_each_entry(re, &el->el_exprs,
+						    re_link) {
+					expr_count++;
+					if (re->re_stride > 1 ||
+					    (last_diff > 0 && last_hi != 255) ||
+					    (last_diff > 0 && last_hi == 255 &&
+					     re->re_lo > 0))
+						return false;
+					last_hi = re->re_hi;
+					last_diff = re->re_hi - re->re_lo;
+				}
+			}
+		}
+	}
+
+	return true;
+}
+
+/**
+ * Takes a linked list of nidrange expressions, determines the minimum
+ * and maximum nid and creates appropriate nid structures
+ *
+ * \param	*nidlist
+ * \param	*min_nid
+ * \param	*max_nid
+ */
+void cfs_nidrange_find_min_max(struct list_head *nidlist, char *min_nid,
+			       char *max_nid, size_t nidstr_length)
+{
+	struct nidrange *nr;
+	struct netstrfns *nf = NULL;
+	int netnum = -1;
+	__u32 min_addr;
+	__u32 max_addr;
+	char *lndname = NULL;
+	char min_addr_str[IPSTRING_LENGTH];
+	char max_addr_str[IPSTRING_LENGTH];
+
+	list_for_each_entry(nr, nidlist, nr_link) {
+		nf = nr->nr_netstrfns;
+		lndname = nf->nf_name;
+		if (netnum == -1)
+			netnum = nr->nr_netnum;
+
+		nf->nf_min_max(nidlist, &min_addr, &max_addr);
+	}
+	nf->nf_addr2str(min_addr, min_addr_str);
+	nf->nf_addr2str(max_addr, max_addr_str);
+
+	snprintf(min_nid, nidstr_length, "%s@%s%d", min_addr_str, lndname,
+		 netnum);
+	snprintf(max_nid, nidstr_length, "%s@%s%d", max_addr_str, lndname,
+		 netnum);
+}
+EXPORT_SYMBOL(cfs_nidrange_find_min_max);
+
+/**
+ * Determines the min and max NID values for num LNDs
+ *
+ * \param	*nidlist
+ * \param	*min_nid
+ * \param	*max_nid
+ */
+static void cfs_num_min_max(struct list_head *nidlist, __u32 *min_nid,
+			    __u32 *max_nid)
+{
+	struct nidrange	*nr;
+	struct addrrange *ar;
+	unsigned int tmp_min_addr = 0;
+	unsigned int tmp_max_addr = 0;
+	unsigned int min_addr = 0;
+	unsigned int max_addr = 0;
+
+	list_for_each_entry(nr, nidlist, nr_link) {
+		list_for_each_entry(ar, &nr->nr_addrranges, ar_link) {
+			cfs_num_ar_min_max(ar, &tmp_min_addr,
+					   &tmp_max_addr);
+			if (tmp_min_addr < min_addr || min_addr == 0)
+				min_addr = tmp_min_addr;
+			if (tmp_max_addr > max_addr)
+				max_addr = tmp_min_addr;
+		}
+	}
+	*max_nid = max_addr;
+	*min_nid = min_addr;
+}
+
+/**
+ * Takes an nidlist and determines the minimum and maximum
+ * ip addresses.
+ *
+ * \param	*nidlist
+ * \param	*min_nid
+ * \param	*max_nid
+ */
+static void cfs_ip_min_max(struct list_head *nidlist, __u32 *min_nid,
+			   __u32 *max_nid)
+{
+	struct nidrange *nr;
+	struct addrrange *ar;
+	__u32 tmp_min_ip_addr = 0;
+	__u32 tmp_max_ip_addr = 0;
+	__u32 min_ip_addr = 0;
+	__u32 max_ip_addr = 0;
+
+	list_for_each_entry(nr, nidlist, nr_link) {
+		list_for_each_entry(ar, &nr->nr_addrranges, ar_link) {
+			cfs_ip_ar_min_max(ar, &tmp_min_ip_addr,
+					  &tmp_max_ip_addr);
+			if (tmp_min_ip_addr < min_ip_addr || min_ip_addr == 0)
+				min_ip_addr = tmp_min_ip_addr;
+			if (tmp_max_ip_addr > max_ip_addr)
+				max_ip_addr = tmp_max_ip_addr;
+		}
+	}
+
+	if (min_nid != NULL)
+		*min_nid = min_ip_addr;
+	if (max_nid != NULL)
+		*max_nid = max_ip_addr;
+}
+
 static int
 libcfs_lo_str2addr(const char *str, int nob, __u32 *addr)
 {
@@ -665,7 +978,9 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_str2addr  */  libcfs_lo_str2addr,
 	 /* .nf_parse_addr*/  libcfs_num_parse,
 	 /* .nf_print_addrlist*/  libcfs_num_addr_range_print,
-	 /* .nf_match_addr*/  libcfs_num_match},
+	 /* .nf_match_addr*/  libcfs_num_match,
+	 /* .nf_is_contiguous */  cfs_num_is_contiguous,
+	 /* .nf_min_max   */      cfs_num_min_max},
 	{/* .nf_type      */  SOCKLND,
 	 /* .nf_name      */  "tcp",
 	 /* .nf_modname   */  "ksocklnd",
@@ -673,7 +988,9 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_str2addr  */  libcfs_ip_str2addr,
 	 /* .nf_parse_addrlist*/  cfs_ip_addr_parse,
 	 /* .nf_print_addrlist*/  libcfs_ip_addr_range_print,
-	 /* .nf_match_addr*/  cfs_ip_addr_match},
+	 /* .nf_match_addr*/  cfs_ip_addr_match,
+	 /* .nf_is_contiguous */  cfs_ip_is_contiguous,
+         /* .nf_min_max   */      cfs_ip_min_max},
 	{/* .nf_type      */  O2IBLND,
 	 /* .nf_name      */  "o2ib",
 	 /* .nf_modname   */  "ko2iblnd",
@@ -681,7 +998,9 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_str2addr  */  libcfs_ip_str2addr,
 	 /* .nf_parse_addrlist*/  cfs_ip_addr_parse,
 	 /* .nf_print_addrlist*/  libcfs_ip_addr_range_print,
-	 /* .nf_match_addr*/  cfs_ip_addr_match},
+	 /* .nf_match_addr*/  cfs_ip_addr_match,
+	 /* .nf_is_contiguous */  cfs_ip_is_contiguous,
+         /* .nf_min_max   */      cfs_ip_min_max},
 	{/* .nf_type      */  CIBLND,
 	 /* .nf_name      */  "cib",
 	 /* .nf_modname   */  "kciblnd",
@@ -689,7 +1008,9 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_str2addr  */  libcfs_ip_str2addr,
 	 /* .nf_parse_addrlist*/  cfs_ip_addr_parse,
 	 /* .nf_print_addrlist*/  libcfs_ip_addr_range_print,
-	 /* .nf_match_addr*/  cfs_ip_addr_match},
+	 /* .nf_match_addr*/  cfs_ip_addr_match,
+	 /* .nf_is_contiguous */  cfs_ip_is_contiguous,
+         /* .nf_min_max   */      cfs_ip_min_max},
 	{/* .nf_type      */  OPENIBLND,
 	 /* .nf_name      */  "openib",
 	 /* .nf_modname   */  "kopeniblnd",
@@ -697,7 +1018,9 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_str2addr  */  libcfs_ip_str2addr,
 	 /* .nf_parse_addrlist*/  cfs_ip_addr_parse,
 	 /* .nf_print_addrlist*/  libcfs_ip_addr_range_print,
-	 /* .nf_match_addr*/  cfs_ip_addr_match},
+	 /* .nf_match_addr*/  cfs_ip_addr_match,
+	 /* .nf_is_contiguous */  cfs_ip_is_contiguous,
+         /* .nf_min_max   */      cfs_ip_min_max},
 	{/* .nf_type      */  IIBLND,
 	 /* .nf_name      */  "iib",
 	 /* .nf_modname   */  "kiiblnd",
@@ -705,7 +1028,9 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_str2addr  */  libcfs_ip_str2addr,
 	 /* .nf_parse_addrlist*/  cfs_ip_addr_parse,
 	 /* .nf_print_addrlist*/  libcfs_ip_addr_range_print,
-	 /* .nf_match_addr*/  cfs_ip_addr_match},
+	 /* .nf_match_addr*/  cfs_ip_addr_match,
+	 /* .nf_is_contiguous */  cfs_ip_is_contiguous,
+         /* .nf_min_max   */      cfs_ip_min_max},
 	{/* .nf_type      */  VIBLND,
 	 /* .nf_name      */  "vib",
 	 /* .nf_modname   */  "kviblnd",
@@ -713,7 +1038,9 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_str2addr  */  libcfs_ip_str2addr,
 	 /* .nf_parse_addrlist*/  cfs_ip_addr_parse,
 	 /* .nf_print_addrlist*/  libcfs_ip_addr_range_print,
-	 /* .nf_match_addr*/  cfs_ip_addr_match},
+	 /* .nf_match_addr*/  cfs_ip_addr_match,
+	 /* .nf_is_contiguous */  cfs_ip_is_contiguous,
+         /* .nf_min_max   */      cfs_ip_min_max},
 	{/* .nf_type      */  RALND,
 	 /* .nf_name      */  "ra",
 	 /* .nf_modname   */  "kralnd",
@@ -721,7 +1048,9 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_str2addr  */  libcfs_ip_str2addr,
 	 /* .nf_parse_addrlist*/  cfs_ip_addr_parse,
 	 /* .nf_print_addrlist*/  libcfs_ip_addr_range_print,
-	 /* .nf_match_addr*/  cfs_ip_addr_match},
+	 /* .nf_match_addr*/  cfs_ip_addr_match,
+	 /* .nf_is_contiguous */  cfs_ip_is_contiguous,
+         /* .nf_min_max   */      cfs_ip_min_max},
 	{/* .nf_type      */  QSWLND,
 	 /* .nf_name      */  "elan",
 	 /* .nf_modname   */  "kqswlnd",
@@ -729,7 +1058,9 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_str2addr  */  libcfs_num_str2addr,
 	 /* .nf_parse_addrlist*/  libcfs_num_parse,
 	 /* .nf_print_addrlist*/  libcfs_num_addr_range_print,
-	 /* .nf_match_addr*/  libcfs_num_match},
+	 /* .nf_match_addr*/  libcfs_num_match,
+	 /* .nf_is_contiguous */  cfs_num_is_contiguous,
+	 /* .nf_min_max   */      cfs_num_min_max},
 	{/* .nf_type      */  GMLND,
 	 /* .nf_name      */  "gm",
 	 /* .nf_modname   */  "kgmlnd",
@@ -737,7 +1068,9 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_str2addr  */  libcfs_num_str2addr,
 	 /* .nf_parse_addrlist*/  libcfs_num_parse,
 	 /* .nf_print_addrlist*/  libcfs_num_addr_range_print,
-	 /* .nf_match_addr*/  libcfs_num_match},
+	 /* .nf_match_addr*/  libcfs_num_match,
+	 /* .nf_is_contiguous */  cfs_num_is_contiguous,
+	 /* .nf_min_max   */      cfs_num_min_max},
 	{/* .nf_type      */  MXLND,
 	 /* .nf_name      */  "mx",
 	 /* .nf_modname   */  "kmxlnd",
@@ -745,7 +1078,9 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_str2addr  */  libcfs_ip_str2addr,
 	 /* .nf_parse_addrlist*/  cfs_ip_addr_parse,
 	 /* .nf_print_addrlist*/  libcfs_ip_addr_range_print,
-	 /* .nf_match_addr*/  cfs_ip_addr_match},
+	 /* .nf_match_addr*/  cfs_ip_addr_match,
+	 /* .nf_is_contiguous */  cfs_ip_is_contiguous,
+         /* .nf_min_max   */      cfs_ip_min_max},
 	{/* .nf_type      */  PTLLND,
 	 /* .nf_name      */  "ptl",
 	 /* .nf_modname   */  "kptllnd",
@@ -753,7 +1088,9 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_str2addr  */  libcfs_num_str2addr,
 	 /* .nf_parse_addrlist*/  libcfs_num_parse,
 	 /* .nf_print_addrlist*/  libcfs_num_addr_range_print,
-	 /* .nf_match_addr*/  libcfs_num_match},
+	 /* .nf_match_addr*/  libcfs_num_match,
+	 /* .nf_is_contiguous */  cfs_num_is_contiguous,
+	 /* .nf_min_max   */      cfs_num_min_max},
 	{/* .nf_type      */  GNILND,
 	 /* .nf_name      */  "gni",
 	 /* .nf_modname   */  "kgnilnd",
@@ -761,7 +1098,9 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_str2addr  */  libcfs_num_str2addr,
 	 /* .nf_parse_addrlist*/  libcfs_num_parse,
 	 /* .nf_print_addrlist*/  libcfs_num_addr_range_print,
-	 /* .nf_match_addr*/  libcfs_num_match},
+	 /* .nf_match_addr*/  libcfs_num_match,
+	 /* .nf_is_contiguous */  cfs_num_is_contiguous,
+	 /* .nf_min_max   */      cfs_num_min_max},
 	/* placeholder for net0 alias.  It MUST BE THE LAST ENTRY */
 	{/* .nf_type      */  -1},
 };
-- 
1.7.1
