From: James Simmons <jsimmons@infradead.org>
Date: Thu, 29 Oct 2015 19:28:21 -0400
Subject: [lustre-devel] [PATCH 1/3] staging: lustre: checkpatch cleanups for
	nidstring.c
In-Reply-To: <1446161303-798-1-git-send-email-jsimmons@infradead.org>
References: <1446161303-798-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1446161303-798-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

With nidstring now having the latest fixes we can
now clean up all the remaining checkpatch errors
for nidstring.c.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/nidstrings.c |   80 ++++++++++++++-----------
 1 files changed, 44 insertions(+), 36 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index 80f585a..ee04c3b 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -162,6 +162,7 @@ struct addrrange {
 static int
 parse_addrange(const struct cfs_lstr *src, struct nidrange *nidrange)
 {
+	struct netstrfns *nf = nidrange->nr_netstrfns;
 	struct addrrange *addrrange;
 
 	if (src->ls_len == 1 && src->ls_str[0] == '*') {
@@ -170,14 +171,13 @@ parse_addrange(const struct cfs_lstr *src, struct nidrange *nidrange)
 	}
 
 	LIBCFS_ALLOC(addrrange, sizeof(struct addrrange));
-	if (addrrange == NULL)
+	if (!addrrange)
 		return -ENOMEM;
 	list_add_tail(&addrrange->ar_link, &nidrange->nr_addrranges);
 	INIT_LIST_HEAD(&addrrange->ar_numaddr_ranges);
 
-	return nidrange->nr_netstrfns->nf_parse_addrlist(src->ls_str,
-						src->ls_len,
-						&addrrange->ar_numaddr_ranges);
+	return nf->nf_parse_addrlist(src->ls_str, src->ls_len,
+				     &addrrange->ar_numaddr_ranges);
 }
 
 /**
@@ -203,16 +203,18 @@ add_nidrange(const struct cfs_lstr *src,
 		return NULL;
 
 	nf = libcfs_namenum2netstrfns(src->ls_str);
-	if (nf == NULL)
+	if (!nf)
 		return NULL;
 	endlen = src->ls_len - strlen(nf->nf_name);
 	if (endlen == 0)
 		/* network name only, e.g. "elan" or "tcp" */
 		netnum = 0;
 	else {
-		/* e.g. "elan25" or "tcp23", refuse to parse if
+		/*
+		 * e.g. "elan25" or "tcp23", refuse to parse if
 		 * network name is not appended with decimal or
-		 * hexadecimal number */
+		 * hexadecimal number
+		 */
 		if (!cfs_str2num_check(src->ls_str + strlen(nf->nf_name),
 				       endlen, &netnum, 0, MAX_NUMERIC_VALUE))
 			return NULL;
@@ -227,7 +229,7 @@ add_nidrange(const struct cfs_lstr *src,
 	}
 
 	LIBCFS_ALLOC(nr, sizeof(struct nidrange));
-	if (nr == NULL)
+	if (!nr)
 		return NULL;
 	list_add_tail(&nr->nr_link, nidlist);
 	INIT_LIST_HEAD(&nr->nr_addrranges);
@@ -256,11 +258,11 @@ parse_nidrange(struct cfs_lstr *src, struct list_head *nidlist)
 	if (cfs_gettok(src, '@', &addrrange) == 0)
 		goto failed;
 
-	if (cfs_gettok(src, '@', &net) == 0 || src->ls_str != NULL)
+	if (cfs_gettok(src, '@', &net) == 0 || src->ls_str)
 		goto failed;
 
 	nr = add_nidrange(&net, nidlist);
-	if (nr == NULL)
+	if (!nr)
 		goto failed;
 
 	if (parse_addrange(&addrrange, nr) != 0)
@@ -370,15 +372,17 @@ int cfs_match_nid(lnet_nid_t nid, struct list_head *nidlist)
 	struct addrrange *ar;
 
 	list_for_each_entry(nr, nidlist, nr_link) {
-		if (nr->nr_netstrfns->nf_type != LNET_NETTYP(LNET_NIDNET(nid)))
+		struct netstrfns *nf = nr->nr_netstrfns;
+
+		if (nf->nf_type != LNET_NETTYP(LNET_NIDNET(nid)))
 			continue;
 		if (nr->nr_netnum != LNET_NETNUM(LNET_NIDNET(nid)))
 			continue;
 		if (nr->nr_all)
 			return 1;
 		list_for_each_entry(ar, &nr->nr_addrranges, ar_link)
-			if (nr->nr_netstrfns->nf_match_addr(LNET_NIDADDR(nid),
-						       &ar->ar_numaddr_ranges))
+			if (nf->nf_match_addr(LNET_NIDADDR(nid),
+					      &ar->ar_numaddr_ranges))
 				return 1;
 	}
 	return 0;
@@ -487,13 +491,13 @@ static void cfs_ip_ar_min_max(struct addrrange *ar, __u32 *min_nid,
 	tmp_ip_addr = ((min_ip[0] << 24) | (min_ip[1] << 16) |
 		       (min_ip[2] << 8) | min_ip[3]);
 
-	if (min_nid != NULL)
+	if (min_nid)
 		*min_nid = tmp_ip_addr;
 
 	tmp_ip_addr = ((max_ip[0] << 24) | (max_ip[1] << 16) |
 		       (max_ip[2] << 8) | max_ip[3]);
 
-	if (max_nid != NULL)
+	if (max_nid)
 		*max_nid = tmp_ip_addr;
 }
 
@@ -522,9 +526,9 @@ static void cfs_num_ar_min_max(struct addrrange *ar, __u32 *min_nid,
 		}
 	}
 
-	if (min_nid != NULL)
+	if (min_nid)
 		*min_nid = min_addr;
-	if (max_nid != NULL)
+	if (max_nid)
 		*max_nid = max_addr;
 }
 
@@ -546,7 +550,7 @@ bool cfs_nidrange_is_contiguous(struct list_head *nidlist)
 
 	list_for_each_entry(nr, nidlist, nr_link) {
 		nf = nr->nr_netstrfns;
-		if (lndname == NULL)
+		if (!lndname)
 			lndname = nf->nf_name;
 		if (netnum == -1)
 			netnum = nr->nr_netnum;
@@ -556,7 +560,7 @@ bool cfs_nidrange_is_contiguous(struct list_head *nidlist)
 			return false;
 	}
 
-	if (nf == NULL)
+	if (!nf)
 		return false;
 
 	if (!nf->nf_is_contiguous(nidlist))
@@ -763,9 +767,9 @@ static void cfs_ip_min_max(struct list_head *nidlist, __u32 *min_nid,
 		}
 	}
 
-	if (min_nid != NULL)
+	if (min_nid)
 		*min_nid = min_ip_addr;
-	if (max_nid != NULL)
+	if (max_nid)
 		*max_nid = max_ip_addr;
 }
 
@@ -784,12 +788,14 @@ libcfs_ip_addr2str(__u32 addr, char *str, size_t size)
 		 (addr >> 8) & 0xff, addr & 0xff);
 }
 
-/* CAVEAT EMPTOR XscanfX
+/*
+ * CAVEAT EMPTOR XscanfX
  * I use "%n" at the end of a sscanf format to detect trailing junk.  However
  * sscanf may return immediately if it sees the terminating '0' in a string, so
  * I initialise the %n variable to the expected length.  If sscanf sets it;
  * fine, if it doesn't, then the scan ended at the end of the string, which is
- * fine too :) */
+ * fine too :)
+ */
 static int
 libcfs_ip_str2addr(const char *str, int nob, __u32 *addr)
 {
@@ -804,7 +810,7 @@ libcfs_ip_str2addr(const char *str, int nob, __u32 *addr)
 	    n == nob &&
 	    (a & ~0xff) == 0 && (b & ~0xff) == 0 &&
 	    (c & ~0xff) == 0 && (d & ~0xff) == 0) {
-		*addr = ((a<<24)|(b<<16)|(c<<8)|d);
+		*addr = ((a << 24) | (b << 16) | (c << 8) | d);
 		return 1;
 	}
 
@@ -824,7 +830,7 @@ cfs_ip_addr_parse(char *str, int len, struct list_head *list)
 	src.ls_len = len;
 	i = 0;
 
-	while (src.ls_str != NULL) {
+	while (src.ls_str) {
 		struct cfs_lstr res;
 
 		if (!cfs_gettok(&src, '.', &res)) {
@@ -1060,7 +1066,9 @@ libcfs_name2netstrfns(const char *name)
 int
 libcfs_isknown_lnd(__u32 lnd)
 {
-	return libcfs_lnd2netstrfns(lnd) != NULL;
+	struct netstrfns *nf = libcfs_lnd2netstrfns(lnd);
+
+	return nf ? 1 : 0;
 }
 EXPORT_SYMBOL(libcfs_isknown_lnd);
 
@@ -1069,7 +1077,7 @@ libcfs_lnd2modname(__u32 lnd)
 {
 	struct netstrfns *nf = libcfs_lnd2netstrfns(lnd);
 
-	return (nf == NULL) ? NULL : nf->nf_modname;
+	return !nf ? NULL : nf->nf_modname;
 }
 EXPORT_SYMBOL(libcfs_lnd2modname);
 
@@ -1078,7 +1086,7 @@ libcfs_str2lnd(const char *str)
 {
 	struct netstrfns *nf = libcfs_name2netstrfns(str);
 
-	if (nf != NULL)
+	if (nf)
 		return nf->nf_type;
 
 	return -1;
@@ -1091,7 +1099,7 @@ libcfs_lnd2str_r(__u32 lnd, char *buf, size_t buf_size)
 	struct netstrfns *nf;
 
 	nf = libcfs_lnd2netstrfns(lnd);
-	if (nf == NULL)
+	if (!nf)
 		snprintf(buf, buf_size, "?%u?", lnd);
 	else
 		snprintf(buf, buf_size, "%s", nf->nf_name);
@@ -1108,7 +1116,7 @@ libcfs_net2str_r(__u32 net, char *buf, size_t buf_size)
 	struct netstrfns *nf;
 
 	nf = libcfs_lnd2netstrfns(lnd);
-	if (nf == NULL)
+	if (!nf)
 		snprintf(buf, buf_size, "<%u:%u>", lnd, nnum);
 	else if (nnum == 0)
 		snprintf(buf, buf_size, "%s", nf->nf_name);
@@ -1135,9 +1143,9 @@ libcfs_nid2str_r(lnet_nid_t nid, char *buf, size_t buf_size)
 	}
 
 	nf = libcfs_lnd2netstrfns(lnd);
-	if (nf == NULL)
+	if (!nf) {
 		snprintf(buf, buf_size, "%x@<%u:%u>", addr, lnd, nnum);
-	else {
+	} else {
 		size_t addr_len;
 
 		nf->nf_addr2str(addr, buf, buf_size);
@@ -1195,7 +1203,7 @@ libcfs_str2net(const char *str)
 {
 	__u32  net;
 
-	if (libcfs_str2net_internal(str, &net) != NULL)
+	if (libcfs_str2net_internal(str, &net))
 		return net;
 
 	return LNET_NIDNET(LNET_NID_ANY);
@@ -1210,15 +1218,15 @@ libcfs_str2nid(const char *str)
 	__u32 net;
 	__u32 addr;
 
-	if (sep != NULL) {
+	if (sep) {
 		nf = libcfs_str2net_internal(sep + 1, &net);
-		if (nf == NULL)
+		if (!nf)
 			return LNET_NID_ANY;
 	} else {
 		sep = str + strlen(str);
 		net = LNET_MKNET(SOCKLND, 0);
 		nf = libcfs_lnd2netstrfns(SOCKLND);
-		LASSERT(nf != NULL);
+		LASSERT(nf);
 	}
 
 	if (!nf->nf_str2addr(str, (int)(sep - str), &addr))
-- 
1.7.1
