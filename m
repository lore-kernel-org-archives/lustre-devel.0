Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B06FC77B70
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:42:08 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWV96PHRz22Yl;
	Sun,  9 Apr 2023 05:23:29 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWQ00kPKz22S6
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:19:52 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 57C75100848E;
 Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 55FEB2AB; Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:13:12 -0400
Message-Id: <1681042400-15491-33-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 32/40] lustre: ptlrpc: fix clang build errors
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

From: Timothy Day <timday@amazon.com>

Fixed bugs which cause errors on Clang.

The majority of changes involve adding
defines for the 'ptlrpc_nrs_ctl' enum.
This avoids having to explicitly cast
enums from one type to another.

A 'strlcpy' in 'sptlrpc_process_config'
was copying the wrong number of bytes.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16518
Lustre-commit: 50f28f81b5aa8f8ad ("LU-16518 ptlrpc: fix clang build errors")
Signed-off-by: Timothy Day <timday@amazon.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49859
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: jsimmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_nrs.h       | 11 ++++++++++-
 fs/lustre/include/lustre_nrs_delay.h | 14 ++++++--------
 fs/lustre/ptlrpc/nrs_delay.c         |  2 +-
 fs/lustre/ptlrpc/sec_config.c        |  2 +-
 4 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/fs/lustre/include/lustre_nrs.h b/fs/lustre/include/lustre_nrs.h
index 7e0a840..0e0dd73 100644
--- a/fs/lustre/include/lustre_nrs.h
+++ b/fs/lustre/include/lustre_nrs.h
@@ -64,7 +64,16 @@ enum ptlrpc_nrs_ctl {
 	 * Policies can start using opcodes from this value and onwards for
 	 * their own purposes; the assigned value itself is arbitrary.
 	 */
-	PTLRPC_NRS_CTL_1ST_POL_SPEC = 0x20,
+	PTLRPC_NRS_CTL_POL_SPEC_01 = 0x20,
+	PTLRPC_NRS_CTL_POL_SPEC_02,
+	PTLRPC_NRS_CTL_POL_SPEC_03,
+	PTLRPC_NRS_CTL_POL_SPEC_04,
+	PTLRPC_NRS_CTL_POL_SPEC_05,
+	PTLRPC_NRS_CTL_POL_SPEC_06,
+	PTLRPC_NRS_CTL_POL_SPEC_07,
+	PTLRPC_NRS_CTL_POL_SPEC_08,
+	PTLRPC_NRS_CTL_POL_SPEC_09,
+	PTLRPC_NRS_CTL_POL_SPEC_10
 };
 
 /**
diff --git a/fs/lustre/include/lustre_nrs_delay.h b/fs/lustre/include/lustre_nrs_delay.h
index 52c3885..75bf56d 100644
--- a/fs/lustre/include/lustre_nrs_delay.h
+++ b/fs/lustre/include/lustre_nrs_delay.h
@@ -73,14 +73,12 @@ struct nrs_delay_req {
 	time64_t	req_start_time;
 };
 
-enum nrs_ctl_delay {
-	NRS_CTL_DELAY_RD_MIN = PTLRPC_NRS_CTL_1ST_POL_SPEC,
-	NRS_CTL_DELAY_WR_MIN,
-	NRS_CTL_DELAY_RD_MAX,
-	NRS_CTL_DELAY_WR_MAX,
-	NRS_CTL_DELAY_RD_PCT,
-	NRS_CTL_DELAY_WR_PCT,
-};
+#define NRS_CTL_DELAY_RD_MIN PTLRPC_NRS_CTL_POL_SPEC_01
+#define NRS_CTL_DELAY_WR_MIN PTLRPC_NRS_CTL_POL_SPEC_02
+#define NRS_CTL_DELAY_RD_MAX PTLRPC_NRS_CTL_POL_SPEC_03
+#define NRS_CTL_DELAY_WR_MAX PTLRPC_NRS_CTL_POL_SPEC_04
+#define NRS_CTL_DELAY_RD_PCT PTLRPC_NRS_CTL_POL_SPEC_05
+#define NRS_CTL_DELAY_WR_PCT PTLRPC_NRS_CTL_POL_SPEC_06
 
 /** @} delay */
 
diff --git a/fs/lustre/ptlrpc/nrs_delay.c b/fs/lustre/ptlrpc/nrs_delay.c
index 127f00c..b249749 100644
--- a/fs/lustre/ptlrpc/nrs_delay.c
+++ b/fs/lustre/ptlrpc/nrs_delay.c
@@ -322,7 +322,7 @@ static int nrs_delay_ctl(struct ptlrpc_nrs_policy *policy,
 
 	assert_spin_locked(&policy->pol_nrs->nrs_lock);
 
-	switch ((enum nrs_ctl_delay)opc) {
+	switch (opc) {
 	default:
 		return -EINVAL;
 
diff --git a/fs/lustre/ptlrpc/sec_config.c b/fs/lustre/ptlrpc/sec_config.c
index e0ddebd..1b56ef4 100644
--- a/fs/lustre/ptlrpc/sec_config.c
+++ b/fs/lustre/ptlrpc/sec_config.c
@@ -649,7 +649,7 @@ int sptlrpc_process_config(struct lustre_cfg *lcfg)
 	 *	is a actual filesystem.
 	 */
 	if (server_name2fsname(target, fsname, NULL))
-		strlcpy(fsname, target, sizeof(target));
+		strlcpy(fsname, target, sizeof(fsname));
 
 	rc = sptlrpc_parse_rule(param, &rule);
 	if (rc)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
