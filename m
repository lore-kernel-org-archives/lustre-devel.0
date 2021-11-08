Return-Path: <SRS0=Xi2l=P3=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78F79C433EF
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:08:40 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3A42F6105A
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:08:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 3A42F6105A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id BA30521F412;
	Mon,  8 Nov 2021 07:08:23 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (SMTP3.CCS.ORNL.GOV [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CF41B21C967
 for <lustre-devel@lists.lustre.org>; Mon,  8 Nov 2021 07:07:49 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 1D7CD2224;
 Mon,  8 Nov 2021 10:07:46 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 10272E0815; Mon,  8 Nov 2021 10:07:46 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  8 Nov 2021 10:07:33 -0500
Message-Id: <1636384063-13838-6-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
References: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 05/15] lustre: ptlrpc: align function names
 with param names
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

Change the internal function names for the ptlrpc proc tunables
to match the parameter names exposed to userspace.  Otherwise it
is needlessly complex to find the function that implements the
"nrs_policies" parameter, since the parameter use itself is wrapped
in a macro that generates the proc handling structure.

Clean up code style in related functions.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14976
Lustre-commit: 7fe49f1e7cf0586da ("LU-14976 ptlrpc: align function names with param names")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44817
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/lproc_ptlrpc.c | 49 ++++++++++++++++++++++-------------------
 1 file changed, 26 insertions(+), 23 deletions(-)

diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index b291374..0323291 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -158,21 +158,22 @@
 
 const char *ll_opcode2str(u32 opcode)
 {
+	u32 offset = opcode_offset(opcode);
+
 	/* When one of the assertions below fail, chances are that:
 	 *     1) A new opcode was added in include/lustre/lustre_idl.h,
-	 *	but is missing from the table above.
+	 *	  but is missing from the table above.
 	 * or  2) The opcode space was renumbered or rearranged,
-	 *	and the opcode_offset() function in
-	 *	ptlrpc_internal.h needs to be modified.
+	 *	  and the opcode_offset() function in
+	 *	  ptlrpc_internal.h needs to be modified.
 	 */
-	u32 offset = opcode_offset(opcode);
-
 	LASSERTF(offset < LUSTRE_MAX_OPCODES,
 		 "offset %u >= LUSTRE_MAX_OPCODES %u\n",
 		 offset, LUSTRE_MAX_OPCODES);
 	LASSERTF(ll_rpc_opcode_table[offset].opcode == opcode,
 		 "ll_rpc_opcode_table[%u].opcode %u != opcode %u\n",
 		 offset, ll_rpc_opcode_table[offset].opcode, opcode);
+
 	return ll_rpc_opcode_table[offset].opname;
 }
 
@@ -249,7 +250,7 @@ static const char *ll_eopcode2str(u32 opcode)
 }
 
 static int
-ptlrpc_lprocfs_req_history_len_seq_show(struct seq_file *m, void *v)
+ptlrpc_lprocfs_req_buffer_history_len_seq_show(struct seq_file *m, void *v)
 {
 	struct ptlrpc_service *svc = m->private;
 	struct ptlrpc_service_part *svcpt;
@@ -260,13 +261,14 @@ static const char *ll_eopcode2str(u32 opcode)
 		total += svcpt->scp_hist_nrqbds;
 
 	seq_printf(m, "%d\n", total);
+
 	return 0;
 }
 
-LDEBUGFS_SEQ_FOPS_RO(ptlrpc_lprocfs_req_history_len);
+LDEBUGFS_SEQ_FOPS_RO(ptlrpc_lprocfs_req_buffer_history_len);
 
 static int
-ptlrpc_lprocfs_req_history_max_seq_show(struct seq_file *m, void *n)
+ptlrpc_lprocfs_req_buffer_history_max_seq_show(struct seq_file *m, void *n)
 {
 	struct ptlrpc_service *svc = m->private;
 	struct ptlrpc_service_part *svcpt;
@@ -281,9 +283,9 @@ static const char *ll_eopcode2str(u32 opcode)
 }
 
 static ssize_t
-ptlrpc_lprocfs_req_history_max_seq_write(struct file *file,
-					 const char __user *buffer,
-					 size_t count, loff_t *off)
+ptlrpc_lprocfs_req_buffer_history_max_seq_write(struct file *file,
+						const char __user *buffer,
+						size_t count, loff_t *off)
 {
 	struct seq_file *m = file->private_data;
 	struct ptlrpc_service *svc = m->private;
@@ -325,7 +327,7 @@ static const char *ll_eopcode2str(u32 opcode)
 	return count;
 }
 
-LDEBUGFS_SEQ_FOPS(ptlrpc_lprocfs_req_history_max);
+LDEBUGFS_SEQ_FOPS(ptlrpc_lprocfs_req_buffer_history_max);
 
 static int
 ptlrpc_lprocfs_req_buffers_max_seq_show(struct seq_file *m, void *n)
@@ -513,7 +515,7 @@ static void nrs_policy_get_info_locked(struct ptlrpc_nrs_policy *policy,
  * Reads and prints policy status information for all policies of a PTLRPC
  * service.
  */
-static int ptlrpc_lprocfs_nrs_seq_show(struct seq_file *m, void *n)
+static int ptlrpc_lprocfs_nrs_policies_seq_show(struct seq_file *m, void *n)
 {
 	struct ptlrpc_service *svc = m->private;
 	struct ptlrpc_service_part *svcpt;
@@ -660,11 +662,13 @@ static int ptlrpc_lprocfs_nrs_seq_show(struct seq_file *m, void *n)
 	return rc;
 }
 
+#define LPROCFS_NRS_WR_MAX_ARG (1024)
 /**
  * The longest valid command string is the maximum policy name size, plus the
  * length of the " reg" substring
  */
-#define LPROCFS_NRS_WR_MAX_CMD	(NRS_POL_NAME_MAX + sizeof(" reg") - 1)
+#define LPROCFS_NRS_WR_MAX_CMD	(NRS_POL_NAME_MAX + sizeof(" reg") - 1 + \
+				 LPROCFS_NRS_WR_MAX_ARG)
 
 /**
  * Starts and stops a given policy on a PTLRPC service.
@@ -673,9 +677,9 @@ static int ptlrpc_lprocfs_nrs_seq_show(struct seq_file *m, void *n)
  * if the optional token is omitted, the operation is performed on both the
  * regular and high-priority (if the service has one) NRS head.
  */
-static ssize_t ptlrpc_lprocfs_nrs_seq_write(struct file *file,
-					    const char __user *buffer,
-					    size_t count, loff_t *off)
+static ssize_t ptlrpc_lprocfs_nrs_policies_seq_write(struct file *file,
+						     const char __user *buffer,
+						     size_t count, loff_t *off)
 {
 	struct seq_file *m = file->private_data;
 	struct ptlrpc_service *svc = m->private;
@@ -753,7 +757,7 @@ static ssize_t ptlrpc_lprocfs_nrs_seq_write(struct file *file,
 	return rc < 0 ? rc : count;
 }
 
-LDEBUGFS_SEQ_FOPS(ptlrpc_lprocfs_nrs);
+LDEBUGFS_SEQ_FOPS(ptlrpc_lprocfs_nrs_policies);
 
 /** @} nrs */
 
@@ -777,8 +781,7 @@ struct ptlrpc_srh_iterator {
 		 * we're searching for a seq on or after it (i.e. more
 		 * recent), search from it onwards.
 		 * Since the service history is LRU (i.e. culled reqs will
-		 * be near the head), we shouldn't have to do long
-		 * re-scans
+		 * be near the head), we shouldn't have to do long re-scans
 		 */
 		LASSERTF(srhi->srhi_seq == srhi->srhi_req->rq_history_seq,
 			 "%s:%d: seek seq %llu, request seq %llu\n",
@@ -1136,16 +1139,16 @@ void ptlrpc_ldebugfs_register_service(struct dentry *entry,
 {
 	struct ldebugfs_vars lproc_vars[] = {
 		{ .name		= "req_buffer_history_len",
-		  .fops		= &ptlrpc_lprocfs_req_history_len_fops,
+		  .fops		= &ptlrpc_lprocfs_req_buffer_history_len_fops,
 		  .data		= svc },
 		{ .name		= "req_buffer_history_max",
-		  .fops		= &ptlrpc_lprocfs_req_history_max_fops,
+		  .fops		= &ptlrpc_lprocfs_req_buffer_history_max_fops,
 		  .data		= svc },
 		{ .name		= "timeouts",
 		  .fops		= &ptlrpc_lprocfs_timeouts_fops,
 		  .data		= svc },
 		{ .name		= "nrs_policies",
-		  .fops		= &ptlrpc_lprocfs_nrs_fops,
+		  .fops		= &ptlrpc_lprocfs_nrs_policies_fops,
 		  .data		= svc },
 		{ .name		= "req_buffers_max",
 		  .fops		= &ptlrpc_lprocfs_req_buffers_max_fops,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
