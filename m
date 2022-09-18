Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id CBA52C32771
	for <lustre-devel@archiver.kernel.org>; Sun, 18 Sep 2022 05:22:43 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MVbmL12n8z1y7K;
	Sat, 17 Sep 2022 22:22:42 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MVbm16yMMz1yBg
 for <lustre-devel@lists.lustre.org>; Sat, 17 Sep 2022 22:22:25 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id E61708F0A;
 Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id E3C3837C; Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 18 Sep 2022 01:22:00 -0400
Message-Id: <1663478534-19917-11-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
References: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 10/24] lustre: llog: handle -EBADR for
 catalog processing
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
Cc: Mikhail Pershin <mpershin@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mikhail Pershin <mpershin@whamcloud.com>

Llog catalog processing might retry to get the last llog block
to check for new records if any. That might return -EBADR code
which should be considered as valid. Previously -EIO was
returned in all cases.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16052
Lustre-commit: e260f751f2a21fa12 ("LU-16052 llog: handle -EBADR for catalog processing")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/48070
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Etienne AUJAMES <eaujames@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/llog.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/obdclass/llog.c b/fs/lustre/obdclass/llog.c
index 0cc64ce..38904b6 100644
--- a/fs/lustre/obdclass/llog.c
+++ b/fs/lustre/obdclass/llog.c
@@ -341,8 +341,8 @@ static int llog_process_thread(void *arg)
 		/* we`ve tried to reread the chunk, but there is no
 		 * new records
 		 */
-		if (rc == -EIO && repeated && (chunk_offset + buf_offset) ==
-		    cur_offset) {
+		if (repeated && (chunk_offset + buf_offset) == cur_offset &&
+		    (rc == -EBADR || rc == -EIO)) {
 			rc = 0;
 			goto out;
 		}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
