Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FD14C433B4
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:42 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 219946124B
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 219946124B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1F8B921F709;
	Sun, 25 Apr 2021 13:09:19 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0ED8721F513
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:46 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 29CCF10087CA;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 28A9669A64; Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:23 -0400
Message-Id: <1619381316-7719-17-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 16/29] lnet: libcfs: fix setting of debug_path
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

From: Andreas Dilger <adilger@whamcloud.com>

While it was possible to set "lctl set_param debug_path=path" or
"echo path > /sys/module/libcfs/parameters/libcfs_debug_file_path"
this change does not affect the path used to dump debug logs.

Connect these parameters to the pathname used for the debug log.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14550
Lustre-commit: f7392c7c4a16bc11 ("LU-14550 libcfs: fix setting of debug_path")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/43109
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_request.c         |  5 ++---
 include/linux/libcfs/libcfs_debug.h |  2 +-
 net/lnet/libcfs/debug.c             | 18 +++++-------------
 3 files changed, 8 insertions(+), 17 deletions(-)

diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 8046e33..1bd0d2c 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1804,9 +1804,8 @@ static void dump_all_bulk_pages(struct obdo *oa, u32 page_count,
 	 */
 	snprintf(dbgcksum_file_name, sizeof(dbgcksum_file_name),
 		 "%s-checksum_dump-osc-" DFID ":[%llu-%llu]-%x-%x",
-		 (strncmp(libcfs_debug_file_path_arr, "NONE", 4) != 0 ?
-		  libcfs_debug_file_path_arr :
-		  LIBCFS_DEBUG_FILE_PATH_DEFAULT),
+		 (strncmp(libcfs_debug_file_path, "NONE", 4) != 0 ?
+		  libcfs_debug_file_path : LIBCFS_DEBUG_FILE_PATH_DEFAULT),
 		 oa->o_valid & OBD_MD_FLFID ? oa->o_parent_seq : 0ULL,
 		 oa->o_valid & OBD_MD_FLFID ? oa->o_parent_oid : 0,
 		 oa->o_valid & OBD_MD_FLFID ? oa->o_parent_ver : 0,
diff --git a/include/linux/libcfs/libcfs_debug.h b/include/linux/libcfs/libcfs_debug.h
index 93eb752..bc85bb9 100644
--- a/include/linux/libcfs/libcfs_debug.h
+++ b/include/linux/libcfs/libcfs_debug.h
@@ -55,7 +55,7 @@
 extern unsigned int libcfs_console_min_delay;
 extern unsigned int libcfs_console_backoff;
 extern unsigned int libcfs_debug_binary;
-extern char libcfs_debug_file_path_arr[PATH_MAX];
+extern char *libcfs_debug_file_path;
 
 struct task_struct;
 
diff --git a/net/lnet/libcfs/debug.c b/net/lnet/libcfs/debug.c
index e519fdb..cb6c33a 100644
--- a/net/lnet/libcfs/debug.c
+++ b/net/lnet/libcfs/debug.c
@@ -225,11 +225,9 @@ static int param_set_uintpos(const char *val, const struct kernel_param *kp)
 
 static DECLARE_COMPLETION(debug_complete);
 
-char libcfs_debug_file_path_arr[PATH_MAX] = LIBCFS_DEBUG_FILE_PATH_DEFAULT;
-EXPORT_SYMBOL(libcfs_debug_file_path_arr);
-
 /* We need to pass a pointer here, but elsewhere this must be a const */
-static char *libcfs_debug_file_path = LIBCFS_DEBUG_FILE_PATH_DEFAULT;
+char *libcfs_debug_file_path = LIBCFS_DEBUG_FILE_PATH_DEFAULT;
+EXPORT_SYMBOL(libcfs_debug_file_path);
 module_param(libcfs_debug_file_path, charp, 0644);
 MODULE_PARM_DESC(libcfs_debug_file_path,
 		 "Path for dumping debug logs, set 'NONE' to prevent log dumping");
@@ -379,12 +377,12 @@ static void libcfs_debug_dumplog_internal(void *arg)
 
 	current_time = ktime_get_real_seconds();
 
-	if (strncmp(libcfs_debug_file_path_arr, "NONE", 4) &&
+	if (strncmp(libcfs_debug_file_path, "NONE", 4) != 0 &&
 	    current_time > last_dump_time) {
 		last_dump_time = current_time;
 		snprintf(debug_file_name, sizeof(debug_file_name) - 1,
-			 "%s.%lld.%ld", libcfs_debug_file_path_arr,
-			 (s64)current_time, (long)arg);
+			 "%s.%lld.%ld", libcfs_debug_file_path,
+			 (s64)current_time, (uintptr_t)arg);
 		pr_alert("LustreError: dumping log to %s\n", debug_file_name);
 		cfs_tracefile_dump_all_pages(debug_file_name);
 		libcfs_run_debug_log_upcall(debug_file_name);
@@ -545,12 +543,6 @@ int libcfs_debug_init(unsigned long bufsize)
 		libcfs_console_min_delay = CDEBUG_DEFAULT_MIN_DELAY;
 	}
 
-	if (libcfs_debug_file_path) {
-		strlcpy(libcfs_debug_file_path_arr,
-			libcfs_debug_file_path,
-			sizeof(libcfs_debug_file_path_arr));
-	}
-
 	/* If libcfs_debug_mb is uninitialized then just make the
 	 * total buffers smp_num_cpus * TCD_MAX_PAGES
 	 */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
