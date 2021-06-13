Return-Path: <SRS0=27wn=LH=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76EB4C48BE8
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:51 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3F997611CA
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F997611CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 18AE721F704;
	Sun, 13 Jun 2021 16:12:22 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id AAFA421CB51
 for <lustre-devel@lists.lustre.org>; Sun, 13 Jun 2021 16:11:45 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id D7900100B05A;
 Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D4FAA9C308; Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 13 Jun 2021 19:11:28 -0400
Message-Id: <1623625897-17706-19-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
References: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 18/27] lustre: llog: changelog purge deletes
 plain llog
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
Cc: Alexander Boyko <alexander.boyko@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Alexander Boyko <alexander.boyko@hpe.com>

With a massive cancel records changelog could delete a plain
llog file and skip one by one record cancelling.
Also patch fixes the race between llog_destroy and llog_next_block.

HPE-bug-id: LUS-9950
WC-bug-id: https://jira.whamcloud.com/browse/LU-14688
Lustre-commit: d813c75df6798efb ("LU-14688 mdt: changelog purge deletes plain llog")
Signed-off-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-on: https://review.whamcloud.com/43719
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/llog.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/lustre/obdclass/llog.c b/fs/lustre/obdclass/llog.c
index c342734..768bc47 100644
--- a/fs/lustre/obdclass/llog.c
+++ b/fs/lustre/obdclass/llog.c
@@ -323,6 +323,10 @@ static int llog_process_thread(void *arg)
 			CDEBUG(D_OTHER,
 			       "cur_offset %llu, chunk_offset %llu, buf_offset %u, rc = %d\n",
 			       cur_offset, (u64)chunk_offset, buf_offset, rc);
+		if (rc == -ESTALE) {
+			rc = 0;
+			goto out;
+		}
 		/* we`ve tried to reread the chunk, but there is no
 		 * new records
 		 */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
