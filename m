Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 4CA94C25B50
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:43:17 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15Wp3VgNz21CH;
	Mon, 23 Jan 2023 15:13:58 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15Wg3FMlz21CV
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:13:51 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id C0C51E28;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id BFA7458991; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:55 -0500
Message-Id: <1674514855-15399-43-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 42/42] lustre: ldlm: remove obsolete
 LDLM_FL_SERVER_LOCK
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

From: Andreas Dilger <adilger@whamcloud.com>

The LDLM_FL_SERVER_LOCK flag and accompanying accessor macros have
never been used since they were first introduced.  Remove them.
It looks like this may have been duplicated by LDLM_FL_NS_SRV.

WC-bug-id: https://jira.whamcloud.com/browse/LU-2771
Lustre-commit: cb0aa0285b32fb432 ("LU-2771 ldlm: remove obsolete LDLM_FL_SERVER_LOCK")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49563
Reviewed-by: Vitaliy Kuznetsov <vkuznetsov@ddn.com>
Reviewed-by: jsimmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm_flags.h | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm_flags.h b/fs/lustre/include/lustre_dlm_flags.h
index 25480ee218e1..d4cd231ce80e 100644
--- a/fs/lustre/include/lustre_dlm_flags.h
+++ b/fs/lustre/include/lustre_dlm_flags.h
@@ -340,12 +340,6 @@
 #define ldlm_set_destroyed(_l)		LDLM_SET_FLAG((_l), 1ULL << 50)
 #define ldlm_clear_destroyed(_l)	LDLM_CLEAR_FLAG((_l), 1ULL << 50)
 
-/** flag whether this is a server namespace lock */
-#define LDLM_FL_SERVER_LOCK		0x0008000000000000ULL /* bit 51 */
-#define ldlm_is_server_lock(_l)		LDLM_TEST_FLAG((_l), 1ULL << 51)
-#define ldlm_set_server_lock(_l)	LDLM_SET_FLAG((_l), 1ULL << 51)
-#define ldlm_clear_server_lock(_l)	LDLM_CLEAR_FLAG((_l), 1ULL << 51)
-
 /**
  * It's set in lock_res_and_lock() and unset in unlock_res_and_lock().
  *
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
