Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id D821BC433EF
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:31:56 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3922821F9D8;
	Sun, 20 Mar 2022 06:31:37 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2FFEF21F97F
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:19 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 68CA5EFA;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 65AB5D87DE; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:49 -0400
Message-Id: <1647783064-20688-36-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 35/50] lnet: libcfs: Use FAIL_CHECK_QUIET for
 fake i/o
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

From: Patrick Farrell <pfarrell@whamcloud.com>

Logging to the console is relatively expensive and doing it
for fake i/o is very expensive in terms of CPU time.

If we use FAIL_CHECK_QUIET, a debug message is logged only once
to the console, and the rest at D_INFO level (probably not at all).

This should hugely reduce the CPU cost of the debugging.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14935
Lustre-commit: 890466a32d3e8683a ("LU-14935 tests: Use FAIL_CHECK_QUIET for fake i/o")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44651
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Etienne AUJAMES <eaujames@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h    | 1 +
 include/linux/libcfs/libcfs_fail.h | 6 +++---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index d57c25c..0732fe9a 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -524,6 +524,7 @@
 /* Assign references to moved code to reduce code changes */
 #define OBD_FAIL_PRECHECK(id)			CFS_FAIL_PRECHECK(id)
 #define OBD_FAIL_CHECK(id)			CFS_FAIL_CHECK(id)
+#define OBD_FILE_CHECK_QUIET(id)		CFS_FILE_CHECK_QUIET(id)
 #define OBD_FAIL_CHECK_VALUE(id, value)		CFS_FAIL_CHECK_VALUE(id, value)
 #define OBD_FAIL_CHECK_ORSET(id, value)		CFS_FAIL_CHECK_ORSET(id, value)
 #define OBD_FAIL_CHECK_RESET(id, value)		CFS_FAIL_CHECK_RESET(id, value)
diff --git a/include/linux/libcfs/libcfs_fail.h b/include/linux/libcfs/libcfs_fail.h
index 731401b..552aad6 100644
--- a/include/linux/libcfs/libcfs_fail.h
+++ b/include/linux/libcfs/libcfs_fail.h
@@ -87,15 +87,15 @@ static inline bool CFS_FAIL_PRECHECK(u32 id)
 		 (cfs_fail_loc & id & CFS_FAULT));
 }
 
-static inline int cfs_fail_check_set(u32 id, u32 value,
-				     int set, int quiet)
+static inline int cfs_fail_check_set(u32 id, u32 value, int set, int quiet)
 {
+	unsigned long failed_once = cfs_fail_loc & CFS_FAILED; /* ok if racy */
 	int ret = 0;
 
 	if (unlikely(CFS_FAIL_PRECHECK(id))) {
 		ret = __cfs_fail_check_set(id, value, set);
 		if (ret) {
-			if (quiet) {
+			if (quiet && failed_once) {
 				CDEBUG(D_INFO, "*** cfs_fail_loc=%x, val=%u***\n",
 				       id, value);
 			} else {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
