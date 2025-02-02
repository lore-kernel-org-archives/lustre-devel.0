Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id AD012C0218F
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 20:52:21 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMCy5JDlz20x3;
	Sun, 02 Feb 2025 12:48:30 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmMCQ5SqFz20tJ
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:48:02 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm-e204-208.ccs.ornl.gov [160.91.203.12])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C332018233D;
 Sun,  2 Feb 2025 15:46:41 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id C1DA0106BE17; Sun,  2 Feb 2025 15:46:41 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:11 -0500
Message-ID: <20250202204633.1148872-12-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 11/33] lustre: obd: replace simple_strtoul()
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
Cc: Arshad Hussain <arshad.hussain@aeoncomputing.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

Replace the use of simple_strtoul() in filename_is_volatile() with
sscanf(). This change also strengthens the checking of the format
of the volatile file's name.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9325
Lustre-commit: 79b34a83f811f5f1d ("LU-9325 obd: replace simple_strtoul()")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49910
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/include/obd.h | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 174372001b23..c62d9171150a 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -1219,7 +1219,7 @@ static inline bool filename_is_volatile(const char *name, size_t namelen,
 					int *idx)
 {
 	const char *start;
-	char *end;
+	int rnd, fd, rc;
 
 	if (strncmp(name, LUSTRE_VOLATILE_HDR, LUSTRE_VOLATILE_HDR_LEN) != 0)
 		return false;
@@ -1241,12 +1241,11 @@ static inline bool filename_is_volatile(const char *name, size_t namelen,
 	}
 	/* we have an idx, read it */
 	start = name + LUSTRE_VOLATILE_HDR_LEN + 1;
-	*idx = simple_strtoul(start, &end, 0);
-	/* error cases:
-	 * no digit, no trailing :, negative value
+	rc = sscanf(start, "%4x:%4x:fd=%2d", idx, &rnd, &fd);
+	/* error cases: no digit or negative value
+	 * rc will never be larger then 3
 	 */
-	if (((*idx == 0) && (end == start)) ||
-	    (*end != ':') || (*idx < 0))
+	if (rc <= 0 || *idx < 0)
 		goto bad_format;
 
 	return true;
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
