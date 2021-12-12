Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 1D73FC433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 12 Dec 2021 15:08:14 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8241321F4A2;
	Sun, 12 Dec 2021 07:08:11 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3566721CBC4
 for <lustre-devel@lists.lustre.org>; Sun, 12 Dec 2021 07:08:07 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id B524710084BE;
 Sun, 12 Dec 2021 10:08:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A44C7E07E5; Sun, 12 Dec 2021 10:08:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 12 Dec 2021 10:07:53 -0500
Message-Id: <1639321683-22909-3-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1639321683-22909-1-git-send-email-jsimmons@infradead.org>
References: <1639321683-22909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 02/12] lnet: uapi: move out kernel only code.
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

Userland doesn't use the new IPv6 function in the UAPI nidstr.h.
So move this to the kernel header lib-types.h. Normally this
wouldn't matter but the python wrappers break with the LUTF
project. With the move to Netlink in the future for the user land
API we shouldn't need these functions anyways.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 0631caae7d804720d ("LU-10391 uapi: move out kernel only code.")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/44844
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 include/linux/lnet/lib-types.h   | 16 ++++++++++++++++
 include/uapi/linux/lnet/nidstr.h | 13 -------------
 2 files changed, 16 insertions(+), 13 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 7631044..eb736a5 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -51,6 +51,22 @@
 #include <uapi/linux/lnet/lnet-dlc.h>
 #include <uapi/linux/lnet/nidstr.h>
 
+char *libcfs_nidstr_r(const struct lnet_nid *nid,
+		      char *buf, size_t buf_size);
+
+static inline char *libcfs_nidstr(const struct lnet_nid *nid)
+{
+	return libcfs_nidstr_r(nid, libcfs_next_nidstring(),
+			       LNET_NIDSTR_SIZE);
+}
+
+int libcfs_strnid(struct lnet_nid *nid, const char *str);
+char *libcfs_idstr(struct lnet_processid *id);
+
+int cfs_match_nid_net(struct lnet_nid *nid, u32 net,
+		      struct list_head *net_num_list,
+		      struct list_head *addr);
+
 /* Max payload size */
 #define LNET_MAX_PAYLOAD	LNET_MTU
 
diff --git a/include/uapi/linux/lnet/nidstr.h b/include/uapi/linux/lnet/nidstr.h
index 482cfb2..80be2eb 100644
--- a/include/uapi/linux/lnet/nidstr.h
+++ b/include/uapi/linux/lnet/nidstr.h
@@ -90,27 +90,14 @@ static inline char *libcfs_nid2str(lnet_nid_t nid)
 				LNET_NIDSTR_SIZE);
 }
 
-char *libcfs_nidstr_r(const struct lnet_nid *nid,
-		      char *buf, __kernel_size_t buf_size);
-static inline char *libcfs_nidstr(const struct lnet_nid *nid)
-{
-	return libcfs_nidstr_r(nid, libcfs_next_nidstring(),
-			       LNET_NIDSTR_SIZE);
-}
-
 __u32 libcfs_str2net(const char *str);
 lnet_nid_t libcfs_str2nid(const char *str);
-int libcfs_strnid(struct lnet_nid *nid, const char *str);
 int libcfs_str2anynid(lnet_nid_t *nid, const char *str);
 char *libcfs_id2str(struct lnet_process_id id);
-char *libcfs_idstr(struct lnet_processid *id);
 void cfs_free_nidlist(struct list_head *list);
 int cfs_parse_nidlist(char *str, int len, struct list_head *list);
 int cfs_print_nidlist(char *buffer, int count, struct list_head *list);
 int cfs_match_nid(lnet_nid_t nid, struct list_head *list);
-int cfs_match_nid_net(struct lnet_nid *nid, __u32 net,
-		       struct list_head *net_num_list,
-		      struct list_head *addr);
 int cfs_match_net(__u32 net_id, __u32 net_type,
 		  struct list_head *net_num_list);
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
