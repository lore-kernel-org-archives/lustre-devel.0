Return-Path: <SRS0=Kfxm=MZ=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E277BC4320A
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:54:35 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A65FF60F36
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:54:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org A65FF60F36
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 672BE352F40;
	Mon,  2 Aug 2021 12:54:26 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B1D7235286A
 for <lustre-devel@lists.lustre.org>; Mon,  2 Aug 2021 12:50:57 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 68BAA100804B;
 Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 6604CC2F55; Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  2 Aug 2021 15:50:31 -0400
Message-Id: <1627933851-7603-12-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
References: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 11/25] lustre: llite: Remove transient page
 counting
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
Cc: Patrick Farrell <farr0186@gmail.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Patrick Farrell <farr0186@gmail.com>

Transient page counting is not used for anything, as
already noted in the commit message, but costs something
like 4% of the time in DIO page submission.

Remove it.

mpirun -np 1  $IOR -w -r -t 64M -b 64G -o ./iorfile --posix.odirect

This patch reduces i/o time in ms/GiB by:
Write: 6 ms/GiB
Read: 11 ms/GiB

Totals:
Write: 174 ms/GiB
Read: 167 ms/GiB

With previous patches in series:
write     5703 MiB/s
read      5756 MiB/s

Plus this patch:
write     5900 MiB/s
read      6136 MiB/s

WC-bug-id: https://jira.whamcloud.com/browse/LU-13799
Lustre-commit: 587e5aa8342980f7 ("LU-13799 llite: Remove transient page counting")
Signed-off-by: Patrick Farrell <farr0186@gmail.com>
Reviewed-on: https://review.whamcloud.com/39441
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/vvp_internal.h | 7 -------
 fs/lustre/llite/vvp_object.c   | 4 +---
 fs/lustre/llite/vvp_page.c     | 5 -----
 3 files changed, 1 insertion(+), 15 deletions(-)

diff --git a/fs/lustre/llite/vvp_internal.h b/fs/lustre/llite/vvp_internal.h
index f2599be..b5e1df2 100644
--- a/fs/lustre/llite/vvp_internal.h
+++ b/fs/lustre/llite/vvp_internal.h
@@ -189,13 +189,6 @@ struct vvp_object {
 	struct inode	       *vob_inode;
 
 	/**
-	 * Number of transient pages.  This is no longer protected by i_sem,
-	 * and needs to be atomic.  This is not actually used for anything,
-	 * and can probably be removed.
-	 */
-	atomic_t		vob_transient_pages;
-
-	/**
 	 * Number of outstanding mmaps on this file.
 	 *
 	 * \see ll_vm_open(), ll_vm_close().
diff --git a/fs/lustre/llite/vvp_object.c b/fs/lustre/llite/vvp_object.c
index 096d996..294df88 100644
--- a/fs/lustre/llite/vvp_object.c
+++ b/fs/lustre/llite/vvp_object.c
@@ -63,8 +63,7 @@ static int vvp_object_print(const struct lu_env *env, void *cookie,
 	struct inode *inode = obj->vob_inode;
 	struct ll_inode_info *lli;
 
-	(*p)(env, cookie, "(%d %d) inode: %p ",
-	     atomic_read(&obj->vob_transient_pages),
+	(*p)(env, cookie, "(%d) inode: %p ",
 	     atomic_read(&obj->vob_mmap_cnt), inode);
 	if (inode) {
 		lli = ll_i2info(inode);
@@ -228,7 +227,6 @@ static int __vvp_object_init(const struct lu_env *env,
 			     const struct cl_object_conf *conf)
 {
 	vob->vob_inode = conf->coc_inode;
-	atomic_set(&vob->vob_transient_pages, 0);
 	cl_object_page_init(&vob->vob_cl, sizeof(struct vvp_page));
 	return 0;
 }
diff --git a/fs/lustre/llite/vvp_page.c b/fs/lustre/llite/vvp_page.c
index 2ecd414..9e14898 100644
--- a/fs/lustre/llite/vvp_page.c
+++ b/fs/lustre/llite/vvp_page.c
@@ -437,10 +437,8 @@ static void vvp_transient_page_fini(const struct lu_env *env,
 				    struct pagevec *pvec)
 {
 	struct vvp_page *vpg = cl2vvp_page(slice);
-	struct vvp_object *clobj = cl2vvp(slice->cpl_obj);
 
 	vvp_page_fini_common(vpg, pvec);
-	atomic_dec(&clobj->vob_transient_pages);
 }
 
 static const struct cl_page_operations vvp_transient_page_ops = {
@@ -469,11 +467,8 @@ int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
 		cl_page_slice_add(page, &vpg->vpg_cl, obj,
 				  &vvp_page_ops);
 	} else {
-		struct vvp_object *clobj = cl2vvp(obj);
-
 		cl_page_slice_add(page, &vpg->vpg_cl, obj,
 				  &vvp_transient_page_ops);
-		atomic_inc(&clobj->vob_transient_pages);
 	}
 	return 0;
 }
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
