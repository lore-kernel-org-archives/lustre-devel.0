Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 7E368C77B61
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:18:03 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWHq5PN3z1yDl;
	Sun,  9 Apr 2023 05:14:31 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWGf5f0fz1wY2
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:13:30 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id CB840100826E;
 Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id BB0F12B3; Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:12:42 -0400
Message-Id: <1681042400-15491-3-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 02/40] lustre: lov: fiemap improperly handles
 fm_extent_count=0
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
Cc: Andrew Perepechko <andrew.perepechko@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andrew Perepechko <andrew.perepechko@hpe.com>

FIEMAP calls with fm_extent_count=0 are supposed only to
return the number of extents.

lov_object_fiemap() attempts to initialize stripe_last
based on fiemap->fm_extents[0] which is not initialized
in userspace and not even allocated in kernelspace.

Eventually, the call exits with -EINVAL and "FIEMAP does
not init start entry" kernel log message.

Fixes: f39704f6e1 ("lustre: lov: FIEMAP support for PFL and FLR file")
HPE-bug-id: LUS-11443
WC-bug-id: https://jira.whamcloud.com/browse/LU-16480
Lustre-commit: 829af7b029d8e4e39 ("LU-16480 lov: fiemap improperly handles fm_extent_count=0")
Signed-off-by: Andrew Perepechko <andrew.perepechko@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49645
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_object.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 34cb6a0..5d65aab 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -1896,7 +1896,7 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 	struct fiemap_state fs = { NULL };
 	struct lu_extent range;
 	int cur_ext;
-	int stripe_last;
+	int stripe_last = 0;
 	int start_stripe = 0;
 	bool resume = false;
 
@@ -1992,9 +1992,10 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 	 * the high 16bits of fe_device remember which stripe the last
 	 * call has been arrived, we'd continue from there in this call.
 	 */
-	if (fiemap->fm_extent_count && fiemap->fm_extents[0].fe_logical)
+	if (fiemap->fm_extent_count && fiemap->fm_extents[0].fe_logical) {
 		resume = true;
-	stripe_last = get_fe_stripenr(&fiemap->fm_extents[0]);
+		stripe_last = get_fe_stripenr(&fiemap->fm_extents[0]);
+	}
 	/**
 	 * stripe_last records stripe number we've been processed in the last
 	 * call
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
