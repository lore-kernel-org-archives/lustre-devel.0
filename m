Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 1188FC25B50
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:13:55 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15Kt346Lz1yDH;
	Mon, 23 Jan 2023 15:05:22 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15KP1XNsz21C0
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:04:57 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 6558F9F0;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 60AAB58991; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:32 -0500
Message-Id: <1674514855-15399-20-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 19/42] lustre: ptlrpc: NUL terminate long
 jobid strings
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

It appears that some jobid names can be sent that are using the full
32-byte size, rather than containing an embedded NUL terminator. This
caused errors in lprocfs_job_stats_log() server side when it overflowed.

If there is no NUL terminator in lustre_msg_get_jobid() then add one
if not found within the buffer, so that the rest of the code doesn't
have to deal with unterminated strings.

This potentially exposes a larger issue that other places may not be
handling the unterminated string properly either, which needs to be
addressed separately on both the client and server.  Terminating the
jobid to 31 chars only on the client does not totally solve the issue,
since there will still be older clients that are not doing this, so
the server needs to handle this in any case.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16376
Lustre-commit: 9eba5d57297f807fd ("LU-16376 obdclass: NUL terminate long jobid strings")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49351
Reviewed-by: Feng Lei <flei@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/pack_generic.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 9a0341c62702..3499611a0740 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -1198,6 +1198,12 @@ char *lustre_msg_get_jobid(struct lustre_msg *msg)
 		if (!pb)
 			return NULL;
 
+		/* If clients send unterminated jobids, terminate them here
+		 * so that there is no chance of string overflow later.
+		 */
+		if (unlikely(pb->pb_jobid[LUSTRE_JOBID_SIZE - 1] != '\0'))
+			pb->pb_jobid[LUSTRE_JOBID_SIZE - 1] = '\0';
+
 		return pb->pb_jobid;
 	}
 	default:
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
