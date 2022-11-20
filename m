Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A0CFFC4332F
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Nov 2022 14:34:19 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4NFXkF4RV5z21Hf;
	Sun, 20 Nov 2022 06:20:53 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4NFXk01Zt4z21H8
 for <lustre-devel@lists.lustre.org>; Sun, 20 Nov 2022 06:20:40 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id DCCE310087C5;
 Sun, 20 Nov 2022 09:17:09 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D9CBBE8B9B; Sun, 20 Nov 2022 09:17:09 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Nov 2022 09:17:00 -0500
Message-Id: <1668953828-10909-15-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
References: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 14/22] lustre: clio: append to non-existent
 component
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
Cc: Vitaly Fertman <vitaly.fertman@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Vitaly Fertman <vitaly.fertman@hpe.com>

should return an error, but it fails now with a BUG below
because @rc of lov_io_layout_at() is not checked for < 0

BUG: unable to handle kernel paging request at ffff99d3c2f74030
    Call Trace:
      lov_stripe_number+0x19/0x40 [lov]
      lov_page_init_composite+0x103/0x5f0 [lov]
      ? kmem_cache_alloc+0x12e/0x270
      cl_page_alloc+0x19f/0x660 [obdclass]
      cl_page_find+0x1a0/0x250 [obdclass]
      ll_write_begin+0x1f7/0xfb0 [lustre]

HPE-bug-id: LUS-11075
WC-bug-id: https://jira.whamcloud.com/browse/LU-16281
Lustre-commit: 8fdeca3b6faf22c72 ("LU-16281 clio: append to non-existent component")
Signed-off-by: Vitaly Fertman <vitaly.fertman@hpe.com>
Reviewed-on: https://es-gerrit.dev.cray.com/161123
Reviewed-by: Alexander Zarochentsev <alexander.zarochentsev@hpe.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48994
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alexander <alexander.boyko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_page.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/lustre/lov/lov_page.c b/fs/lustre/lov/lov_page.c
index a22b71f..6e28e62 100644
--- a/fs/lustre/lov/lov_page.c
+++ b/fs/lustre/lov/lov_page.c
@@ -84,6 +84,8 @@ int lov_page_init_composite(const struct lu_env *env, struct cl_object *obj,
 		suboff = lio->lis_cached_suboff + offset - lio->lis_cached_off;
 	} else {
 		entry = lov_io_layout_at(lio, offset);
+		if (entry < 0)
+			return -ENODATA;
 
 		stripe = lov_stripe_number(loo->lo_lsm, entry, offset);
 		rc = lov_stripe_offset(loo->lo_lsm, entry, offset, stripe,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
