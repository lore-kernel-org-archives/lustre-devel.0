Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 6E429C02199
	for <lustre-devel@archiver.kernel.org>; Sat,  8 Feb 2025 00:42:54 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YqWyz3YPrz20t5;
	Fri, 07 Feb 2025 16:33:15 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YqWw84CVQz1xfS
 for <lustre-devel@lists.lustre.org>; Fri, 07 Feb 2025 16:30:48 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 245FD893E8C;
 Fri,  7 Feb 2025 19:30:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 22ECE106BE16; Fri,  7 Feb 2025 19:30:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri,  7 Feb 2025 19:30:23 -0500
Message-ID: <20250208003027.180076-18-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250208003027.180076-1-jsimmons@infradead.org>
References: <20250208003027.180076-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 17/21] lustre: clio: Trivial DIO cleanups
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Patrick Farrell <pfarrell@whamcloud.com>

This is some minor DIO refactoring and an additional debug
message discovered while working on this.  Extremely minor.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13805
Lustre-commit: a667cfac0e70cd4da ("LU-13805 clio: Trivial DIO cleanups")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49987
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/cl_io.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index ee82260ab0f5..d6518e9f9c66 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -1273,14 +1273,11 @@ void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
 
 		spin_unlock(&anchor->csi_waitq.lock);
 
-		if (csi_dio_aio) {
-			if (end_io == cl_dio_aio_end) {
-				if (!creator_free)
-					cl_dio_aio_free(env, dio_aio);
-			} else if (end_io == cl_sub_dio_end) {
-				if (!creator_free)
-					cl_sub_dio_free(sub_dio_aio);
-			}
+		if (csi_dio_aio && !creator_free) {
+			if (end_io == cl_dio_aio_end)
+				cl_dio_aio_free(env, dio_aio);
+			else if (end_io == cl_sub_dio_end)
+				cl_sub_dio_free(sub_dio_aio);
 		}
 	}
 }
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
