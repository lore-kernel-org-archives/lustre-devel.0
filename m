Return-Path: <SRS0=2ypu=OM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20BC0C433EF
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:21:11 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id DAA6F6112F
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:21:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org DAA6F6112F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5BE2521C8F2;
	Tue, 21 Sep 2021 19:21:09 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id BAA7021E02E
 for <lustre-devel@lists.lustre.org>; Tue, 21 Sep 2021 19:20:06 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 0AAEE351;
 Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id F2F37FF4BF; Tue, 21 Sep 2021 22:20:03 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Tue, 21 Sep 2021 22:19:41 -0400
Message-Id: <1632277201-6920-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
References: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 04/24] lnet: add string formating/parsing for
 IPv6 nids
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

New entries for struct netstrfns:
  nf_addr2str_size
  nf_str2addr_size
which accept or report the size of the address in bytes.
New matching functions that can report or parse IPv4 and IPv6
addresses.

New interface - currently unused - libcfs_strnid() which takes a str
and provides a 'struct lnet_nid' with appropriate nid_size.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 7224b21156639a63 ("LU-10391 lnet: add string formating/parsing for IPv6 nids")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/43942
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h   |   4 ++
 include/uapi/linux/lnet/nidstr.h |   1 +
 net/lnet/lnet/nidstrings.c       | 109 +++++++++++++++++++++++++++++++++++++--
 3 files changed, 110 insertions(+), 4 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 80cf4f3..5b517cc 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -248,7 +248,11 @@ struct netstrfns {
 	char	*nf_name;
 	char	*nf_modname;
 	void	(*nf_addr2str)(u32 addr, char *str, size_t size);
+	void	(*nf_addr2str_size)(const __be32 *addr, size_t asize,
+				    char *str, size_t size);
 	int	(*nf_str2addr)(const char *str, int nob, u32 *addr);
+	int	(*nf_str2addr_size)(const char *str, int nob,
+				    __be32 *addr, size_t *asize);
 	int	(*nf_parse_addrlist)(char *str, int len,
 				     struct list_head *list);
 	int	(*nf_print_addrlist)(char *buffer, int count,
diff --git a/include/uapi/linux/lnet/nidstr.h b/include/uapi/linux/lnet/nidstr.h
index d5b9d69..13a0d10 100644
--- a/include/uapi/linux/lnet/nidstr.h
+++ b/include/uapi/linux/lnet/nidstr.h
@@ -100,6 +100,7 @@ static inline char *libcfs_nidstr(const struct lnet_nid *nid)
 
 __u32 libcfs_str2net(const char *str);
 lnet_nid_t libcfs_str2nid(const char *str);
+int libcfs_strnid(struct lnet_nid *nid, const char *str);
 int libcfs_str2anynid(lnet_nid_t *nid, const char *str);
 char *libcfs_id2str(struct lnet_process_id id);
 void cfs_free_nidlist(struct list_head *list);
diff --git a/net/lnet/lnet/nidstrings.c b/net/lnet/lnet/nidstrings.c
index 6da43d5..08f828b 100644
--- a/net/lnet/lnet/nidstrings.c
+++ b/net/lnet/lnet/nidstrings.c
@@ -38,6 +38,7 @@
 
 #include <linux/spinlock.h>
 #include <linux/slab.h>
+#include <linux/sunrpc/addr.h>
 #include <linux/libcfs/libcfs.h>
 #include <linux/libcfs/libcfs_string.h>
 #include <uapi/linux/lnet/nidstr.h>
@@ -466,8 +467,31 @@ int cfs_print_nidlist(char *buffer, int count, struct list_head *nidlist)
 		 (addr >> 8) & 0xff, addr & 0xff);
 }
 
-/*
- * CAVEAT EMPTOR XscanfX
+static void
+libcfs_ip_addr2str_size(const __be32 *addr, size_t asize,
+			char *str, size_t size)
+{
+	struct sockaddr_storage sa = {};
+
+	switch (asize) {
+	case 4:
+		sa.ss_family = AF_INET;
+		memcpy(&((struct sockaddr_in *)(&sa))->sin_addr.s_addr,
+		       addr, asize);
+		break;
+	case 16:
+		sa.ss_family = AF_INET6;
+		memcpy(&((struct sockaddr_in6 *)(&sa))->sin6_addr.s6_addr,
+		       addr, asize);
+		break;
+	default:
+		return;
+	}
+
+	rpc_ntop((struct sockaddr *)&sa, str, size);
+}
+
+/* CAVEAT EMPTOR XscanfX
  * I use "%n" at the end of a sscanf format to detect trailing junk.  However
  * sscanf may return immediately if it sees the terminating '0' in a string, so
  * I initialise the %n variable to the expected length.  If sscanf sets it;
@@ -495,6 +519,37 @@ int cfs_print_nidlist(char *buffer, int count, struct list_head *nidlist)
 	return 0;
 }
 
+static int
+libcfs_ip_str2addr_size(const char *str, int nob,
+			__be32 *addr, size_t *alen)
+{
+	struct sockaddr_storage sa;
+
+	/* Note: 'net' arg to rpc_pton is only needed for link-local
+	 * addresses.  Such addresses would not work with LNet routing,
+	 * so we can assume they aren't used.  So it doesn't matter
+	 * which net namespace is passed.
+	 */
+	if (rpc_pton(&init_net, str, nob,
+		     (struct sockaddr *)&sa, sizeof(sa)) == 0)
+		return 0;
+	if (sa.ss_family == AF_INET6) {
+		memcpy(addr,
+		       &((struct sockaddr_in6 *)(&sa))->sin6_addr.s6_addr,
+		       16);
+		*alen = 16;
+		return 1;
+	}
+	if (sa.ss_family == AF_INET) {
+		memcpy(addr,
+		       &((struct sockaddr_in *)(&sa))->sin_addr.s_addr,
+		       4);
+		*alen = 4;
+		return 1;
+	}
+	return 0;
+}
+
 /* Used by lnet/config.c so it can't be static */
 int
 cfs_ip_addr_parse(char *str, int len, struct list_head *list)
@@ -660,7 +715,9 @@ int cfs_print_nidlist(char *buffer, int count, struct list_head *nidlist)
 	  .nf_name		= "tcp",
 	  .nf_modname		= "ksocklnd",
 	  .nf_addr2str		= libcfs_ip_addr2str,
+	  .nf_addr2str_size	= libcfs_ip_addr2str_size,
 	  .nf_str2addr		= libcfs_ip_str2addr,
+	  .nf_str2addr_size	= libcfs_ip_str2addr_size,
 	  .nf_parse_addrlist	= cfs_ip_addr_parse,
 	  .nf_print_addrlist	= libcfs_ip_addr_range_print,
 	  .nf_match_addr	= cfs_ip_addr_match
@@ -920,10 +977,14 @@ int cfs_print_nidlist(char *buffer, int count, struct list_head *nidlist)
 	}
 
 	nf = libcfs_lnd2netstrfns(lnd);
-	if (nf && nid_is_nid4(nid)) {
+	if (nf) {
 		size_t addr_len;
 
-		nf->nf_addr2str(ntohl(nid->nid_addr[0]), buf, buf_size);
+		if (nf->nf_addr2str_size)
+			nf->nf_addr2str_size(nid->nid_addr, NID_ADDR_BYTES(nid),
+					     buf, buf_size);
+		else
+			nf->nf_addr2str(ntohl(nid->nid_addr[0]), buf, buf_size);
 		addr_len = strlen(buf);
 		if (nnum == 0)
 			snprintf(buf + addr_len, buf_size - addr_len, "@%s",
@@ -1020,6 +1081,46 @@ int cfs_print_nidlist(char *buffer, int count, struct list_head *nidlist)
 }
 EXPORT_SYMBOL(libcfs_str2nid);
 
+int
+libcfs_strnid(struct lnet_nid *nid, const char *str)
+{
+	const char *sep = strchr(str, '@');
+	struct netstrfns *nf;
+	u32 net;
+
+	if (sep) {
+		nf = libcfs_str2net_internal(sep + 1, &net);
+		if (!nf)
+			return -EINVAL;
+	} else {
+		sep = str + strlen(str);
+		net = LNET_MKNET(SOCKLND, 0);
+		nf = libcfs_lnd2netstrfns(SOCKLND);
+		LASSERT(nf);
+	}
+
+	memset(nid, 0, sizeof(*nid));
+	nid->nid_type = LNET_NETTYP(net);
+	nid->nid_num = htons(LNET_NETNUM(net));
+	if (nf->nf_str2addr_size) {
+		size_t asize = 0;
+
+		if (!nf->nf_str2addr_size(str, (int)(sep - str),
+					  nid->nid_addr, &asize))
+			return -EINVAL;
+		nid->nid_size = asize - 4;
+	} else {
+		u32 addr;
+
+		if (!nf->nf_str2addr(str, (int)(sep - str), &addr))
+			return -EINVAL;
+		nid->nid_addr[0] = htonl(addr);
+		nid->nid_size = 0;
+	}
+	return 0;
+}
+EXPORT_SYMBOL(libcfs_strnid);
+
 char *
 libcfs_id2str(struct lnet_process_id id)
 {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
