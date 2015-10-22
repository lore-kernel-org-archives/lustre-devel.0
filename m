From: James Simmons <jsimmons@infradead.org>
Date: Wed, 21 Oct 2015 21:52:39 -0400
Subject: [lustre-devel] [PATCH 01/11] staging: lustre: add a service that
	prints a nidlist
In-Reply-To: <1445478769-21203-1-git-send-email-jsimmons@infradead.org>
References: <1445478769-21203-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1445478769-21203-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Gregoire Pichon <gregoire.pichon@bull.net>

The libcfs already provides services to parse a string into a nidlist
and to match a nid into a nidlist. This patch implements a service
that prints a nidlist into a buffer.

This is required for instance to print the nosquash_nids parameter
of the MDT procfs component.

Additionally, this patch fixes a bug in return code of
parse_addrange() routine, so that parsing of nids including
a * character works fine ('*@elan' for instance).

Signed-off-by: Gregoire Pichon <gregoire.pichon@bull.net>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-1778
Reviewed-on: http://review.whamcloud.com/9221
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
---
 .../lustre/include/linux/libcfs/libcfs_string.h    |    2 +
 drivers/staging/lustre/include/linux/lnet/nidstr.h |    2 +
 .../staging/lustre/lustre/libcfs/libcfs_string.c   |   71 +++++++++++-
 drivers/staging/lustre/lustre/libcfs/nidstrings.c  |  124 +++++++++++++++++++-
 4 files changed, 193 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
index 478e958..d178e43 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
@@ -83,6 +83,8 @@ int cfs_gettok(struct cfs_lstr *next, char delim, struct cfs_lstr *res);
 int cfs_str2num_check(char *str, int nob, unsigned *num,
 		      unsigned min, unsigned max);
 int cfs_expr_list_match(__u32 value, struct cfs_expr_list *expr_list);
+int cfs_expr_list_print(char *buffer, int count,
+			struct cfs_expr_list *expr_list);
 int cfs_expr_list_values(struct cfs_expr_list *expr_list,
 			 int max, __u32 **values);
 static inline void
diff --git a/drivers/staging/lustre/include/linux/lnet/nidstr.h b/drivers/staging/lustre/include/linux/lnet/nidstr.h
index a627be9..082782b 100644
--- a/drivers/staging/lustre/include/linux/lnet/nidstr.h
+++ b/drivers/staging/lustre/include/linux/lnet/nidstr.h
@@ -69,7 +69,9 @@ int libcfs_str2anynid(lnet_nid_t *nid, const char *str);
 char *libcfs_id2str(lnet_process_id_t id);
 void cfs_free_nidlist(struct list_head *list);
 int cfs_parse_nidlist(char *str, int len, struct list_head *list);
+int cfs_print_nidlist(char *buffer, int count, struct list_head *list);
 int cfs_match_nid(lnet_nid_t nid, struct list_head *list);
+
 bool cfs_nidrange_is_contiguous(struct list_head *nidlist);
 void cfs_nidrange_find_min_max(struct list_head *nidlist, char *min_nid,
 			       char *max_nid, size_t nidstr_length);
diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
index efe5e66..bbfef98 100644
--- a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
@@ -321,6 +321,73 @@ cfs_range_expr_parse(struct cfs_lstr *src, unsigned min, unsigned max,
 }
 
 /**
+ * Print the range expression \a re into specified \a buffer.
+ * If \a bracketed is true, expression does not need additional
+ * brackets.
+ *
+ * \retval number of characters written
+ */
+static int
+cfs_range_expr_print(char *buffer, int count, struct cfs_range_expr *expr,
+		     bool bracketed)
+{
+	int i;
+	char s[] = "[";
+	char e[] = "]";
+
+	if (bracketed)
+		s[0] = e[0] = '\0';
+
+	if (expr->re_lo == expr->re_hi)
+		i = scnprintf(buffer, count, "%u", expr->re_lo);
+	else if (expr->re_stride == 1)
+		i = scnprintf(buffer, count, "%s%u-%u%s",
+				s, expr->re_lo, expr->re_hi, e);
+	else
+		i = scnprintf(buffer, count, "%s%u-%u/%u%s",
+				s, expr->re_lo, expr->re_hi,
+				expr->re_stride, e);
+	return i;
+}
+
+/**
+ * Print a list of range expressions (\a expr_list) into specified \a buffer.
+ * If the list contains several expressions, separate them with comma
+ * and surround the list with brackets.
+ *
+ * \retval number of characters written
+ */
+int
+cfs_expr_list_print(char *buffer, int count, struct cfs_expr_list *expr_list)
+{
+	struct cfs_range_expr *expr;
+	int i = 0, j = 0;
+	int numexprs = 0;
+
+	if (count <= 0)
+		return 0;
+
+	list_for_each_entry(expr, &expr_list->el_exprs, re_link)
+		numexprs++;
+
+	if (numexprs > 1)
+		i += scnprintf(buffer + i, count - i, "[");
+
+	list_for_each_entry(expr, &expr_list->el_exprs, re_link) {
+		if (j++ != 0)
+			i += scnprintf(buffer + i, count - i, ",");
+		i += cfs_range_expr_print(buffer + i, count - i, expr,
+					  numexprs > 1);
+	}
+
+	if (numexprs > 1)
+		i += scnprintf(buffer + i, count - i, "]");
+
+	return i;
+}
+EXPORT_SYMBOL(cfs_expr_list_print);
+
+/**
  * Matches value (\a value) against ranges expression list \a expr_list.
  *
  * \retval 1 if \a value matches
@@ -412,8 +479,8 @@ EXPORT_SYMBOL(cfs_expr_list_free);
 /**
  * Parses \<cfs_expr_list\> token of the syntax.
  *
- * \retval 1 if \a str parses to \<number\> | \<expr_list\>
- * \retval 0 otherwise
+ * \retval 0 if \a str parses to \<number\> | \<expr_list\>
+ * \retval -errno otherwise
  */
 int
 cfs_expr_list_parse(char *str, int len, unsigned min, unsigned max,
diff --git a/drivers/staging/lustre/lustre/libcfs/nidstrings.c b/drivers/staging/lustre/lustre/libcfs/nidstrings.c
index 087449f..a54594a 100644
--- a/drivers/staging/lustre/lustre/libcfs/nidstrings.c
+++ b/drivers/staging/lustre/lustre/libcfs/nidstrings.c
@@ -114,6 +114,21 @@ static int libcfs_ip_str2addr(const char *str, int nob, __u32 *addr)
 	return 0;
 }
 
+static int
+libcfs_ip_addr_range_print(char *buffer, int count, struct list_head *list)
+{
+	int i = 0, j = 0;
+	struct cfs_expr_list *el;
+
+	list_for_each_entry(el, list, el_link) {
+		LASSERT(j++ < 4);
+		if (i != 0)
+			i += scnprintf(buffer + i, count - i, ".");
+		i += cfs_expr_list_print(buffer + i, count - i, el);
+	}
+	return i;
+}
+
 static void libcfs_decnum_addr2str(__u32 addr, char *str)
 {
 	snprintf(str, LNET_NIDSTR_SIZE, "%u", addr);
@@ -164,6 +179,19 @@ libcfs_num_parse(char *str, int len, struct list_head *list)
 	return rc;
 }
 
+static int
+libcfs_num_addr_range_print(char *buffer, int count, struct list_head *list)
+{
+	int i = 0, j = 0;
+	struct cfs_expr_list *el;
+
+	list_for_each_entry(el, list, el_link) {
+		LASSERT(j++ < 1);
+		i += cfs_expr_list_print(buffer + i, count - i, el);
+	}
+	return i;
+}
+
 /*
  * Nf_match_addr method for networks using numeric addresses
  *
@@ -189,6 +217,8 @@ struct netstrfns {
 	int	(*nf_str2addr)(const char *str, int nob, __u32 *addr);
 	int	(*nf_parse_addrlist)(char *str, int len,
 					struct list_head *list);
+	int	(*nf_print_addrlist)(char *buffer, int count,
+				     struct list_head *list);
 	int	(*nf_match_addr)(__u32 addr, struct list_head *list);
 };
 
@@ -199,6 +229,7 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_addr2str  */  libcfs_decnum_addr2str,
 	 /* .nf_str2addr  */  libcfs_lo_str2addr,
 	 /* .nf_parse_addr*/  libcfs_num_parse,
+	 /* .nf_print_addrlist*/  libcfs_num_addr_range_print,
 	 /* .nf_match_addr*/  libcfs_num_match},
 	{/* .nf_type      */  SOCKLND,
 	 /* .nf_name      */  "tcp",
@@ -206,6 +237,7 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_addr2str  */  libcfs_ip_addr2str,
 	 /* .nf_str2addr  */  libcfs_ip_str2addr,
 	 /* .nf_parse_addrlist*/  cfs_ip_addr_parse,
+	 /* .nf_print_addrlist*/  libcfs_ip_addr_range_print,
 	 /* .nf_match_addr*/  cfs_ip_addr_match},
 	{/* .nf_type      */  O2IBLND,
 	 /* .nf_name      */  "o2ib",
@@ -213,6 +245,7 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_addr2str  */  libcfs_ip_addr2str,
 	 /* .nf_str2addr  */  libcfs_ip_str2addr,
 	 /* .nf_parse_addrlist*/  cfs_ip_addr_parse,
+	 /* .nf_print_addrlist*/  libcfs_ip_addr_range_print,
 	 /* .nf_match_addr*/  cfs_ip_addr_match},
 	{/* .nf_type      */  CIBLND,
 	 /* .nf_name      */  "cib",
@@ -220,6 +253,7 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_addr2str  */  libcfs_ip_addr2str,
 	 /* .nf_str2addr  */  libcfs_ip_str2addr,
 	 /* .nf_parse_addrlist*/  cfs_ip_addr_parse,
+	 /* .nf_print_addrlist*/  libcfs_ip_addr_range_print,
 	 /* .nf_match_addr*/  cfs_ip_addr_match},
 	{/* .nf_type      */  OPENIBLND,
 	 /* .nf_name      */  "openib",
@@ -227,6 +261,7 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_addr2str  */  libcfs_ip_addr2str,
 	 /* .nf_str2addr  */  libcfs_ip_str2addr,
 	 /* .nf_parse_addrlist*/  cfs_ip_addr_parse,
+	 /* .nf_print_addrlist*/  libcfs_ip_addr_range_print,
 	 /* .nf_match_addr*/  cfs_ip_addr_match},
 	{/* .nf_type      */  IIBLND,
 	 /* .nf_name      */  "iib",
@@ -234,6 +269,7 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_addr2str  */  libcfs_ip_addr2str,
 	 /* .nf_str2addr  */  libcfs_ip_str2addr,
 	 /* .nf_parse_addrlist*/  cfs_ip_addr_parse,
+	 /* .nf_print_addrlist*/  libcfs_ip_addr_range_print,
 	 /* .nf_match_addr*/  cfs_ip_addr_match},
 	{/* .nf_type      */  VIBLND,
 	 /* .nf_name      */  "vib",
@@ -241,6 +277,7 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_addr2str  */  libcfs_ip_addr2str,
 	 /* .nf_str2addr  */  libcfs_ip_str2addr,
 	 /* .nf_parse_addrlist*/  cfs_ip_addr_parse,
+	 /* .nf_print_addrlist*/  libcfs_ip_addr_range_print,
 	 /* .nf_match_addr*/  cfs_ip_addr_match},
 	{/* .nf_type      */  RALND,
 	 /* .nf_name      */  "ra",
@@ -248,6 +285,7 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_addr2str  */  libcfs_ip_addr2str,
 	 /* .nf_str2addr  */  libcfs_ip_str2addr,
 	 /* .nf_parse_addrlist*/  cfs_ip_addr_parse,
+	 /* .nf_print_addrlist*/  libcfs_ip_addr_range_print,
 	 /* .nf_match_addr*/  cfs_ip_addr_match},
 	{/* .nf_type      */  QSWLND,
 	 /* .nf_name      */  "elan",
@@ -255,6 +293,7 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_addr2str  */  libcfs_decnum_addr2str,
 	 /* .nf_str2addr  */  libcfs_num_str2addr,
 	 /* .nf_parse_addrlist*/  libcfs_num_parse,
+	 /* .nf_print_addrlist*/  libcfs_num_addr_range_print,
 	 /* .nf_match_addr*/  libcfs_num_match},
 	{/* .nf_type      */  GMLND,
 	 /* .nf_name      */  "gm",
@@ -262,6 +301,7 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_addr2str  */  libcfs_hexnum_addr2str,
 	 /* .nf_str2addr  */  libcfs_num_str2addr,
 	 /* .nf_parse_addrlist*/  libcfs_num_parse,
+	 /* .nf_print_addrlist*/  libcfs_num_addr_range_print,
 	 /* .nf_match_addr*/  libcfs_num_match},
 	{/* .nf_type      */  MXLND,
 	 /* .nf_name      */  "mx",
@@ -269,6 +309,7 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_addr2str  */  libcfs_ip_addr2str,
 	 /* .nf_str2addr  */  libcfs_ip_str2addr,
 	 /* .nf_parse_addrlist*/  cfs_ip_addr_parse,
+	 /* .nf_print_addrlist*/  libcfs_ip_addr_range_print,
 	 /* .nf_match_addr*/  cfs_ip_addr_match},
 	{/* .nf_type      */  PTLLND,
 	 /* .nf_name      */  "ptl",
@@ -276,6 +317,7 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_addr2str  */  libcfs_decnum_addr2str,
 	 /* .nf_str2addr  */  libcfs_num_str2addr,
 	 /* .nf_parse_addrlist*/  libcfs_num_parse,
+	 /* .nf_print_addrlist*/  libcfs_num_addr_range_print,
 	 /* .nf_match_addr*/  libcfs_num_match},
 	{/* .nf_type      */  GNILND,
 	 /* .nf_name      */  "gni",
@@ -283,6 +325,7 @@ static struct netstrfns  libcfs_netstrfns[] = {
 	 /* .nf_addr2str  */  libcfs_decnum_addr2str,
 	 /* .nf_str2addr  */  libcfs_num_str2addr,
 	 /* .nf_parse_addrlist*/  libcfs_num_parse,
+	 /* .nf_print_addrlist*/  libcfs_num_addr_range_print,
 	 /* .nf_match_addr*/  libcfs_num_match},
 	/* placeholder for net0 alias.  It MUST BE THE LAST ENTRY */
 	{/* .nf_type      */  -1},
@@ -612,8 +655,8 @@ struct addrrange {
  * Allocates struct addrrange and links to \a nidrange via
  * (nidrange::nr_addrranges)
  *
- * \retval 1 if \a src parses to '*' | \<ipaddr_range\> | \<cfs_expr_list\>
- * \retval 0 otherwise
+ * \retval 0 if \a src parses to '*' | \<ipaddr_range\> | \<cfs_expr_list\>
+ * \retval -errno otherwise
  */
 static int
 parse_addrange(const struct cfs_lstr *src, struct nidrange *nidrange)
@@ -622,12 +665,12 @@ parse_addrange(const struct cfs_lstr *src, struct nidrange *nidrange)
 
 	if (src->ls_len == 1 && src->ls_str[0] == '*') {
 		nidrange->nr_all = 1;
-		return 1;
+		return 0;
 	}
 
 	LIBCFS_ALLOC(addrrange, sizeof(struct addrrange));
 	if (addrrange == NULL)
-		return 0;
+		return -ENOMEM;
 	list_add_tail(&addrrange->ar_link, &nidrange->nr_addrranges);
 	INIT_LIST_HEAD(&addrrange->ar_numaddr_ranges);
 
@@ -840,3 +883,76 @@ int cfs_match_nid(lnet_nid_t nid, struct list_head *nidlist)
 	return 0;
 }
 EXPORT_SYMBOL(cfs_match_nid);
+
+/**
+ * Print the network part of the nidrange \a nr into the specified \a buffer.
+ *
+ * \retval number of characters written
+ */
+static int
+cfs_print_network(char *buffer, int count, struct nidrange *nr)
+{
+	struct netstrfns *nf = nr->nr_netstrfns;
+
+	if (nr->nr_netnum == 0)
+		return scnprintf(buffer, count, "@%s", nf->nf_name);
+	else
+		return scnprintf(buffer, count, "@%s%u",
+				 nf->nf_name, nr->nr_netnum);
+}
+
+/**
+ * Print a list of addrrange (\a addrranges) into the specified \a buffer.
+ * At max \a count characters can be printed into \a buffer.
+ *
+ * \retval number of characters written
+ */
+static int
+cfs_print_addrranges(char *buffer, int count, struct list_head *addrranges,
+		     struct nidrange *nr)
+{
+	int i = 0;
+	struct addrrange *ar;
+	struct netstrfns *nf = nr->nr_netstrfns;
+
+	list_for_each_entry(ar, addrranges, ar_link) {
+		if (i != 0)
+			i += scnprintf(buffer + i, count - i, " ");
+		i += nf->nf_print_addrlist(buffer + i, count - i,
+					   &ar->ar_numaddr_ranges);
+		i += cfs_print_network(buffer + i, count - i, nr);
+	}
+	return i;
+}
+
+/**
+ * Print a list of nidranges (\a nidlist) into the specified \a buffer.
+ * At max \a count characters can be printed into \a buffer.
+ * Nidranges are separated by a space character.
+ *
+ * \retval number of characters written
+ */
+int cfs_print_nidlist(char *buffer, int count, struct list_head *nidlist)
+{
+	int i = 0;
+	struct nidrange *nr;
+
+	if (count <= 0)
+		return 0;
+
+	list_for_each_entry(nr, nidlist, nr_link) {
+		if (i != 0)
+			i += scnprintf(buffer + i, count - i, " ");
+
+		if (nr->nr_all != 0) {
+			LASSERT(list_empty(&nr->nr_addrranges));
+			i += scnprintf(buffer + i, count - i, "*");
+			i += cfs_print_network(buffer + i, count - i, nr);
+		} else {
+			i += cfs_print_addrranges(buffer + i, count - i,
+						  &nr->nr_addrranges, nr);
+		}
+	}
+	return i;
+}
+EXPORT_SYMBOL(cfs_print_nidlist);
-- 
1.7.1
