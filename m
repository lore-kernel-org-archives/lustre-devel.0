Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 17D9CC02199
	for <lustre-devel@archiver.kernel.org>; Sat,  8 Feb 2025 00:34:37 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YqWwC4cZLz1xt4;
	Fri, 07 Feb 2025 16:30:51 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YqWw21Cr0z1xPK
 for <lustre-devel@lists.lustre.org>; Fri, 07 Feb 2025 16:30:42 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id F24F6179486;
 Fri,  7 Feb 2025 19:30:32 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id EB704106BE1B; Fri,  7 Feb 2025 19:30:32 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri,  7 Feb 2025 19:30:12 -0500
Message-ID: <20250208003027.180076-7-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250208003027.180076-1-jsimmons@infradead.org>
References: <20250208003027.180076-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 06/21] lustre: osc: Ensure there's no
 eviction with long cache discard
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
Cc: James Nunez <jnunez@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Oleg Drokin <green@whamcloud.com>

Just pause execution while doing page processing
for discard if appropriate failloc is set.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14711
Lustre-commit: c0a7f78529e21c9ca ("LU-14711 tests: Ensure there's no eviction with long cache discard")
Signed-off-by: Oleg Drokin <green@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/43869
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Nunez <jnunez@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h | 1 +
 fs/lustre/osc/osc_cache.c       | 3 +++
 2 files changed, 4 insertions(+)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index bd5ccea30b2a..f1e2e3bbb247 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -336,6 +336,7 @@ extern char obd_jobid_var[];
 #define OBD_FAIL_OSC_DELAY_IO				0x414
 #define OBD_FAIL_OSC_NO_SIZE_DATA			0x415
 #define OBD_FAIL_OSC_DELAY_CANCEL			0x416
+#define OBD_FAIL_OSC_SLOW_PAGE_EVICT			0x417
 
 #define OBD_FAIL_PTLRPC					0x500
 #define OBD_FAIL_PTLRPC_ACK				0x501
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index f1f21c28765e..37624a7a99d6 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -3196,6 +3196,9 @@ bool osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
 		if (!res)
 			break;
 
+		OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_SLOW_PAGE_EVICT,
+				 cfs_fail_val ?: 20);
+
 		if (io->ci_type == CIT_MISC &&
 		    io->u.ci_misc.lm_next_rpc_time &&
 		    ktime_get_seconds() > io->u.ci_misc.lm_next_rpc_time) {
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
