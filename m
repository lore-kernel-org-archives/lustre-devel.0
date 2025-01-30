Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id B849FC0218A
	for <lustre-devel@archiver.kernel.org>; Thu, 30 Jan 2025 14:34:54 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YkLfZ1fPQz21cn;
	Thu, 30 Jan 2025 06:16:06 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YkLZK5GSDz1xpQ
 for <lustre-devel@lists.lustre.org>; Thu, 30 Jan 2025 06:12:25 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 0E99218236B;
 Thu, 30 Jan 2025 09:11:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 0C4C3106BE18; Thu, 30 Jan 2025 09:11:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 30 Jan 2025 09:11:02 -0500
Message-ID: <20250130141115.950749-13-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250130141115.950749-1-jsimmons@infradead.org>
References: <20250130141115.950749-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 12/25] lnet: move libcfs_nidstr to UAPI
 headers
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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
Cc: Serguei Smirnov <ssmirnov@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

User-space now has functions to convert between strings and
large nids that mirror the kernel. Move those function
prototypes to UAPI since this is the case.

Lustre-commit: b6c702df5d4de8e5a ("LU-10391 libcfs: add large-nid string conversion functions.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50092
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h   | 11 -----------
 include/uapi/linux/lnet/nidstr.h | 11 +++++++++++
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 1ae4530d1bc6..bc9f0020f93a 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -51,17 +51,6 @@
 #include <uapi/linux/lnet/lnet-dlc.h>
 #include <uapi/linux/lnet/nidstr.h>
 
-char *libcfs_nidstr_r(const struct lnet_nid *nid,
-		      char *buf, size_t buf_size);
-
-static inline char *libcfs_nidstr(const struct lnet_nid *nid)
-{
-	return libcfs_nidstr_r(nid, libcfs_next_nidstring(),
-			       LNET_NIDSTR_SIZE);
-}
-
-int libcfs_strnid(struct lnet_nid *nid, const char *str);
-char *libcfs_idstr(struct lnet_processid *id);
 int libcfs_strid(struct lnet_processid *id, const char *str);
 
 int cfs_match_nid_net(struct lnet_nid *nid, u32 net,
diff --git a/include/uapi/linux/lnet/nidstr.h b/include/uapi/linux/lnet/nidstr.h
index 1ccb8fa826b4..87244ce7c698 100644
--- a/include/uapi/linux/lnet/nidstr.h
+++ b/include/uapi/linux/lnet/nidstr.h
@@ -91,6 +91,17 @@ static inline char *libcfs_nid2str(lnet_nid_t nid)
 				LNET_NIDSTR_SIZE);
 }
 
+char *libcfs_nidstr_r(const struct lnet_nid *nid,
+		      char *buf, __kernel_size_t buf_size);
+
+static inline char *libcfs_nidstr(const struct lnet_nid *nid)
+{
+	return libcfs_nidstr_r(nid, libcfs_next_nidstring(),
+			       LNET_NIDSTR_SIZE);
+}
+
+int libcfs_strnid(struct lnet_nid *nid, const char *str);
+char *libcfs_idstr(struct lnet_processid *id);
 __u32 libcfs_str2net(const char *str);
 lnet_nid_t libcfs_str2nid(const char *str);
 int libcfs_str2anynid(lnet_nid_t *nid, const char *str);
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
