Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A72D5ECAAA1
	for <lustre-devel@archiver.kernel.org>; Tue,  6 Sep 2022 01:56:05 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MM7lT2Xp9z1y2N;
	Mon,  5 Sep 2022 18:56:05 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MM7l91K1Dz1y7Z
 for <lustre-devel@lists.lustre.org>; Mon,  5 Sep 2022 18:55:49 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C2005100B005;
 Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id BDA16589A0; Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  5 Sep 2022 21:55:24 -0400
Message-Id: <1662429337-18737-12-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
References: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 11/24] lnet: change ni_status in lnet_ni to
 u32*
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

struct lnet_ni.ni_status points to a 'struct lnet_ni_status', but only
the ns_status field of that structure is ever accessed.

Change ni_status to point directly to just the ns_status field.
This will provide flexibility for introducing a variant for 'struct
lnet_ni_status' which holds a large-address nid.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 9e2df7e5cc5fca3c6 ("LU-10391 lnet: change ni_status in lnet_ni to u32*")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/44626
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h  | 8 ++++----
 include/linux/lnet/lib-types.h | 2 +-
 net/lnet/lnet/api-ni.c         | 2 +-
 net/lnet/lnet/router.c         | 2 +-
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 57c8dc2..2900c05 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -108,11 +108,11 @@
 {
 	bool update = false;
 
-	if (ni->ni_status && ni->ni_status->ns_status != status) {
+	if (ni->ni_status && *ni->ni_status != status) {
 		CDEBUG(D_NET, "ni %s status changed from %#x to %#x\n",
 		       libcfs_nidstr(&ni->ni_nid),
-		       ni->ni_status->ns_status, status);
-		ni->ni_status->ns_status = status;
+		       *ni->ni_status, status);
+		*ni->ni_status = status;
 		update = true;
 	}
 
@@ -128,7 +128,7 @@
 	else if (atomic_read(&ni->ni_fatal_error_on))
 		return LNET_NI_STATUS_DOWN;
 	else if (ni->ni_status)
-		return ni->ni_status->ns_status;
+		return *ni->ni_status;
 	else
 		return LNET_NI_STATUS_UP;
 }
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 09b9d8e..2266d1b 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -500,7 +500,7 @@ struct lnet_ni {
 	struct lnet_net		*ni_net;
 
 	/* my health status */
-	struct lnet_ni_status	*ni_status;
+	u32			*ni_status;
 
 	/* NI FSM. Protected by lnet_ni_lock() */
 	enum lnet_ni_state	ni_state;
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 7c94d16..0449136 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1967,7 +1967,7 @@ struct lnet_ping_buffer *
 
 			lnet_ni_lock(ni);
 			ns->ns_status = lnet_ni_get_status_locked(ni);
-			ni->ni_status = ns;
+			ni->ni_status = &ns->ns_status;
 			lnet_ni_unlock(ni);
 
 			i++;
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index b684243..98707e9 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -1082,7 +1082,7 @@ int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 			 */
 			if (atomic_read(&ni->ni_fatal_error_on) &&
 			    ni->ni_status &&
-			    ni->ni_status->ns_status != LNET_NI_STATUS_DOWN &&
+			    *ni->ni_status != LNET_NI_STATUS_DOWN &&
 			    lnet_ni_set_status(ni, LNET_NI_STATUS_DOWN))
 				push = true;
 		}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
