Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 6B58DC25B50
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:37:54 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15SS5pYCz22Yk;
	Mon, 23 Jan 2023 15:11:04 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15QL1mkMz22VD
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:09:14 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id A5D1DE14;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A1DFD58987; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:48 -0500
Message-Id: <1674514855-15399-36-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 35/42] lnet: libcfs: cfs_hash_for_each_empty
 optimization
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
Cc: Alexander Zarochentsev <alexander.zarochentsev@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Alexander Zarochentsev <alexander.zarochentsev@hpe.com>

Restarts from bucket 0 in cfs_hash_for_each_empty()
cause excessive cpu consumption while checking first empty
buckets.

HPE-bug-id: LUS-11311
WC-bug-id: https://jira.whamcloud.com/browse/LU-16272
Lustre-commit: 306a9b666e5ea2882 ("LU-16272 libcfs: cfs_hash_for_each_empty optimization")
Signed-off-by: Alexander Zarochentsev <alexander.zarochentsev@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48972
Reviewed-by: Andrew Perepechko <andrew.perepechko@hpe.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/libcfs/hash.c | 19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/net/lnet/libcfs/hash.c b/net/lnet/libcfs/hash.c
index c9ff92dbfec7..6d5cd6d800b7 100644
--- a/net/lnet/libcfs/hash.c
+++ b/net/lnet/libcfs/hash.c
@@ -1541,7 +1541,7 @@ EXPORT_SYMBOL(cfs_hash_size_get);
  */
 static int
 cfs_hash_for_each_relax(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
-			void *data, int start)
+			void *data, int *pstart)
 {
 	struct hlist_node *next = NULL;
 	struct hlist_node *hnode;
@@ -1564,7 +1564,7 @@ cfs_hash_for_each_relax(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
 	cfs_hash_for_each_bucket(hs, &bd, i) {
 		struct hlist_head *hhead;
 
-		if (i < start)
+		if (pstart && i < *pstart)
 			continue;
 		else if (end > 0 && i >= end)
 			break;
@@ -1622,13 +1622,16 @@ cfs_hash_for_each_relax(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
 		if (rc) /* callback wants to break iteration */
 			break;
 	}
-	if (start > 0 && !rc) {
-		end = start;
-		start = 0;
+
+	if (pstart && *pstart > 0 && rc == 0) {
+		end = *pstart;
+		*pstart = 0;
 		goto again;
 	}
 
 	cfs_hash_unlock(hs, 0);
+	if (pstart)
+		*pstart = i;
 	return count;
 }
 
@@ -1646,7 +1649,7 @@ cfs_hash_for_each_nolock(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
 		return -EOPNOTSUPP;
 
 	cfs_hash_for_each_enter(hs);
-	cfs_hash_for_each_relax(hs, func, data, start);
+	cfs_hash_for_each_relax(hs, func, data, &start);
 	cfs_hash_for_each_exit(hs);
 
 	return 0;
@@ -1669,6 +1672,7 @@ cfs_hash_for_each_empty(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
 			void *data)
 {
 	unsigned int i = 0;
+	int start = 0;
 
 	if (cfs_hash_with_no_lock(hs))
 		return -EOPNOTSUPP;
@@ -1678,11 +1682,12 @@ cfs_hash_for_each_empty(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
 		return -EOPNOTSUPP;
 
 	cfs_hash_for_each_enter(hs);
-	while (cfs_hash_for_each_relax(hs, func, data, 0)) {
+	while (cfs_hash_for_each_relax(hs, func, data, &start)) {
 		CDEBUG(D_INFO, "Try to empty hash: %s, loop: %u\n",
 		       hs->hs_name, i++);
 	}
 	cfs_hash_for_each_exit(hs);
+	LASSERT(atomic_read(&hs->hs_count) == 0);
 	return 0;
 }
 EXPORT_SYMBOL(cfs_hash_for_each_empty);
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
