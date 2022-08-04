Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 91906C19F29
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:38:35 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4LyrwS5Zr6z23J9;
	Wed,  3 Aug 2022 18:38:32 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4LyrwL6QBJz1y73
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:26 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id A8F84100AFF2;
 Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 9FBE68BBFC; Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:37:47 -0400
Message-Id: <1659577097-19253-3-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 02/32] lustre: flr: Don't assume RDONLY
 implies SOM
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

From: Patrick Farrell <pfarrell@whamcloud.com>

In lov_io_slice_mirror_init, the client code assumes that
the LCM_FL_RDONLY flag in the layout implies SOM and skips
glimpse if it sees one.  The RDONLY flag means the mirrors
are in sync, which has historically implied SOM is valid.

To start with, using LCM_FL_RDONLY to imply SOM is sort of
a layering violation.  SOM is only communicated from the
MDS when it is valid, and the client already skips glimpse
in that case, so this duplicates functionality from the
higher layers.

More seriously, patch:
"LU-14526 flr: mirror split downgrade SOM"
(https://review.whamcloud.com/43168/)
Made it possible to have LCM_FL_RDONLY but not strict SOM,
so this assumption is no longer correct.

The fix is to not look at LCM_FL_RDONLY when deciding
whether to glimpse a file for size.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15609
Lustre-commit: 250108ad754cfa932 ("LU-15609 flr: Don't assume RDONLY implies SOM")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/46666
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h | 7 +++----
 fs/lustre/lov/lov_io.c          | 7 -------
 2 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 0732fe9a..b6c8a72 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -515,10 +515,9 @@
 #define OBD_FAIL_UNKNOWN_LMV_STRIPE			0x1901
 
 /* FLR */
-#define OBD_FAIL_FLR_GLIMPSE_IMMUTABLE			0x1A00
-#define OBD_FAIL_FLR_LV_DELAY			0x1A01
-#define OBD_FAIL_FLR_LV_INC			0x1A02
-#define OBD_FAIL_FLR_RANDOM_PICK_MIRROR	0x1A03
+#define OBD_FAIL_FLR_LV_DELAY				0x1A01
+#define OBD_FAIL_FLR_LV_INC				0x1A02
+#define OBD_FAIL_FLR_RANDOM_PICK_MIRROR			0x1A03
 
 /* LNet is allocated failure locations 0xe000 to 0xffff */
 /* Assign references to moved code to reduce code changes */
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index b535092..32f028b 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -540,13 +540,6 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 	case CIT_GLIMPSE:
 		lio->lis_pos = 0;
 		lio->lis_endpos = OBD_OBJECT_EOF;
-
-		if (lov_flr_state(obj) == LCM_FL_RDONLY &&
-		    !OBD_FAIL_CHECK(OBD_FAIL_FLR_GLIMPSE_IMMUTABLE)) {
-			/* SoM is accurate, no need glimpse */
-			result = 1;
-			goto out;
-		}
 		break;
 
 	case CIT_MISC:
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
