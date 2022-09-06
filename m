Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8FFB2C6FA86
	for <lustre-devel@archiver.kernel.org>; Tue,  6 Sep 2022 01:55:52 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MM7l917Ysz1y7W;
	Mon,  5 Sep 2022 18:55:49 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MM7l40V06z1y5j
 for <lustre-devel@lists.lustre.org>; Mon,  5 Sep 2022 18:55:44 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id AB006100AFF8;
 Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 9E267589A0; Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  5 Sep 2022 21:55:17 -0400
Message-Id: <1662429337-18737-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
References: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 04/24] lustre: llite: fully disable readahead
 in kernel I/O path
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

From: Qian Yingjin <qian@ddn.com>

In the new kernel (rhel9 or ubuntu 2204), the readahead path may
be out of the control of Lustre CLIO engine:

generic_file_read_iter()
  ->filemap_read()
    ->filemap_get_pages()
      ->page_cache_sync_readahead()
        ->page_cache_sync_ra()

void page_cache_sync_ra()
{
    if (!ractl->ra->ra_pages || blk_cgroup_congested()) {
	if (!ractl->file)
        	return;
	req_count = 1;
	do_forced_ra = true;
    }

    /* be dumb */
    if (do_forced_ra) {
	force_page_cache_ra(ractl, req_count);
	return;
    }
    ...
}

From the kernel readahead code, even if read-ahead is disabled
(via @ra_pages == 0), it still issues this request as read-ahead
as we will need it to satisfy the requested range. The forced
read-ahead will do the right thing and limit the read to just
the requested range, which we will set to 1 page for this case.

Thus it can not totally avoid the read-ahead in the kernel I/O
path only by setting @ra_pages with 0.
To fully disable the read-ahead in the Linux kernel I/O path, we
still need to set @io_pages to 0, it will set I/O range to 0 in
@force_page_cache_ra():

void force_page_cache_ra()
{
    ...
    max_pages = = max_t(unsigned long, bdi->io_pages,
			ra->ra_pages);
    nr_to_read = min_t(unsigned long, nr_to_read, max_pages);
    while (nr_to_read) {
	...
    }
    ...
}

After set bdi->io_pages with 0, it can pass the sanity/101j.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16019
Lustre-commit: f0cf7fd3cccb2313f ("LU-16019 llite: fully disable readahead in kernel I/O path")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/47993
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 5daced0..5931258 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1261,6 +1261,7 @@ int ll_fill_super(struct super_block *sb)
 
 	/* disable kernel readahead */
 	sb->s_bdi->ra_pages = 0;
+	sb->s_bdi->io_pages = 0;
 
 	/* Call ll_debugsfs_register_super() before lustre_process_log()
 	 * so that "llite.*.*" params can be processed correctly.
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
