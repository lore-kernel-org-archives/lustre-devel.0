Return-Path: <SRS0=Xi2l=P3=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81E35C433EF
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:08:46 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 4D6A761027
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:08:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 4D6A761027
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5974521F432;
	Mon,  8 Nov 2021 07:08:28 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (SMTP3.CCS.ORNL.GOV [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5B4A721C967
 for <lustre-devel@lists.lustre.org>; Mon,  8 Nov 2021 07:07:51 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 311F8222B;
 Mon,  8 Nov 2021 10:07:46 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 2F607E07E4; Mon,  8 Nov 2021 10:07:46 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  8 Nov 2021 10:07:40 -0500
Message-Id: <1636384063-13838-13-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
References: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 12/15] lustre: ptlrpc: remove LASSERT in
 nrs_polices debugfs handler
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
Cc: Lei Feng <flei@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Lei Feng <flei@whamcloud.com>

It's not necessary to LASSERT() in nrs_polices debugfs handler.
CERROR() and returning error is good enough.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14587
Lustre-commit: 9997f94d4b6ee335d ("LU-14587 ptlrpc: remove LASSERT in nrs_polices proc handler")
Signed-off-by: Lei Feng <flei@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/45200
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/lproc_ptlrpc.c | 51 +++++++++++++++++++++++++++++++++--------
 1 file changed, 41 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index 0323291..b2daf1f 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -570,6 +570,8 @@ static int ptlrpc_lprocfs_nrs_policies_seq_show(struct seq_file *m, void *n)
 			if (i == 0) {
 				memcpy(infos[pol_idx].pi_name, tmp.pi_name,
 				       NRS_POL_NAME_MAX);
+				memcpy(infos[pol_idx].pi_arg, tmp.pi_arg,
+				       sizeof(tmp.pi_arg));
 				memcpy(&infos[pol_idx].pi_state, &tmp.pi_state,
 				       sizeof(tmp.pi_state));
 				infos[pol_idx].pi_fallback = tmp.pi_fallback;
@@ -578,17 +580,39 @@ static int ptlrpc_lprocfs_nrs_policies_seq_show(struct seq_file *m, void *n)
 				 * sanity-check the values we get.
 				 */
 			} else {
-				LASSERT(strncmp(infos[pol_idx].pi_name,
-						tmp.pi_name,
-						NRS_POL_NAME_MAX) == 0);
+				if (strncmp(infos[pol_idx].pi_name,
+					    tmp.pi_name,
+					    NRS_POL_NAME_MAX) != 0) {
+					spin_unlock(&nrs->nrs_lock);
+					rc = -EINVAL;
+					CERROR("%s: failed to check pi_name: rc = %d\n",
+					       svc->srv_thread_name, rc);
+					goto unlock;
+				}
+				if (strncmp(infos[pol_idx].pi_arg,
+					    tmp.pi_arg,
+					    sizeof(tmp.pi_arg)) != 0) {
+					spin_unlock(&nrs->nrs_lock);
+					rc = -EINVAL;
+					CERROR("%s: failed to check pi_arg: rc = %d\n",
+					       svc->srv_thread_name, rc);
+					goto unlock;
+				}
 				/**
-				 * Not asserting ptlrpc_nrs_pol_info::pi_state,
+				 * Not checking ptlrpc_nrs_pol_info::pi_state,
 				 * because it may be different between
 				 * instances of the same policy in different
 				 * service partitions.
 				 */
-				LASSERT(infos[pol_idx].pi_fallback ==
-					tmp.pi_fallback);
+
+				if (infos[pol_idx].pi_fallback !=
+				    tmp.pi_fallback) {
+					spin_unlock(&nrs->nrs_lock);
+					rc = -EINVAL;
+					CERROR("%s: failed to check pi_fallback: rc = %d\n",
+					       svc->srv_thread_name, rc);
+					goto unlock;
+				}
 			}
 
 			infos[pol_idx].pi_req_queued += tmp.pi_req_queued;
@@ -633,12 +657,18 @@ static int ptlrpc_lprocfs_nrs_policies_seq_show(struct seq_file *m, void *n)
 		   !hp ?  "\nregular_requests:" : "high_priority_requests:");
 
 	for (pol_idx = 0; pol_idx < num_pols; pol_idx++) {
-		seq_printf(m,  "  - name: %s\n"
-			       "    state: %s\n"
+		if (strlen(infos[pol_idx].pi_arg) > 0)
+			seq_printf(m, "  - name: %s %s\n",
+				   infos[pol_idx].pi_name,
+				   infos[pol_idx].pi_arg);
+		else
+			seq_printf(m, "  - name: %s\n",
+				   infos[pol_idx].pi_name);
+
+		seq_printf(m,  "    state: %s\n"
 			       "    fallback: %s\n"
 			       "    queued: %-20d\n"
 			       "    active: %-20d\n\n",
-			       infos[pol_idx].pi_name,
 			       nrs_state2str(infos[pol_idx].pi_state),
 			       infos[pol_idx].pi_fallback ? "yes" : "no",
 			       (int)infos[pol_idx].pi_req_queued,
@@ -655,8 +685,9 @@ static int ptlrpc_lprocfs_nrs_policies_seq_show(struct seq_file *m, void *n)
 		goto again;
 	}
 
-	kfree(infos);
 unlock:
+	kfree(infos);
+
 	mutex_unlock(&nrs_core.nrs_mutex);
 
 	return rc;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
