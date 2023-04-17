Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 38ECEC77B76
	for <lustre-devel@archiver.kernel.org>; Mon, 17 Apr 2023 13:54:42 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Q0T1J73wCz21B1;
	Mon, 17 Apr 2023 06:49:08 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Q0SzW58BWz1yBk
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 06:47:35 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 6D0011005FA7;
 Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 6B5A7372; Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 17 Apr 2023 09:47:03 -0400
Message-Id: <1681739243-29375-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
References: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/27] lustre: fid: reduce
 LUSTRE_DATA_SEQ_MAX_WIDTH
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
Cc: Li Dongyang <dongyangli@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Li Dongyang <dongyangli@ddn.com>

Reduce LUSTRE_DATA_SEQ_MAX_WIDTH from ~4B to ~32M
to limit the number of objects under /O/[seq]/d[0..31]
dir on OSTs. This makes the directories stay optimial
for ldiskfs, to avoid going into the largedir/3-level
htree territory.

Check the seq->lcs_width which is a tunable set to
LUSTRE_DATA_SEQ_MAX_WIDTH by default, allow the value
up to IDIF_MAX_OID if a larger seq width is needed.

The seq will rollover when the seq width is exhausted,
the default is LUSTRE_DATA_SEQ_MAX_WIDTH.
For seq >= FID_SEQ_NORMAL objects, the upper limit of
seq width is OBIF_MAX_OID,
For IDIF/MDT0 objects, the upper limit is IDIF_MAX_OID.
The seq FID_SEQ_OST_MDT0 will change to a normal seq after the
rollover.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11912
Lustre-commit: 0ecb2a167c56ffff8 ("LU-11912 ofd: reduce LUSTRE_DATA_SEQ_MAX_WIDTH")
Signed-off-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/38424
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Sergey Cheremencev <scherementsev@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/fid/lproc_fid.c      | 2 +-
 fs/lustre/include/lustre_fid.h | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/fid/lproc_fid.c b/fs/lustre/fid/lproc_fid.c
index 8f6a4a8..9ca2814 100644
--- a/fs/lustre/fid/lproc_fid.c
+++ b/fs/lustre/fid/lproc_fid.c
@@ -154,7 +154,7 @@ static ssize_t ldebugfs_fid_width_seq_write(struct file *file,
 
 	spin_lock(&seq->lcs_lock);
 	if (seq->lcs_type == LUSTRE_SEQ_DATA)
-		max = LUSTRE_DATA_SEQ_MAX_WIDTH;
+		max = IDIF_MAX_OID;
 	else
 		max = LUSTRE_METADATA_SEQ_MAX_WIDTH;
 
diff --git a/fs/lustre/include/lustre_fid.h b/fs/lustre/include/lustre_fid.h
index 88a6061..5ebe362 100644
--- a/fs/lustre/include/lustre_fid.h
+++ b/fs/lustre/include/lustre_fid.h
@@ -173,9 +173,9 @@ enum {
 	LUSTRE_METADATA_SEQ_MAX_WIDTH = 0x0000000000020000ULL,
 
 	/*
-	 * This is how many data FIDs could be allocated in one sequence(4B - 1)
+	 * This is how many data FIDs could be allocated in one sequence(32M - 1)
 	 */
-	LUSTRE_DATA_SEQ_MAX_WIDTH = 0x00000000FFFFFFFFULL,
+	LUSTRE_DATA_SEQ_MAX_WIDTH = 0x0000000001FFFFFFULL,
 
 	/*
 	 * How many sequences to allocate to a client at once.
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
