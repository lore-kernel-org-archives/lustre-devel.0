Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E7CB1C433F5
	for <lustre-devel@archiver.kernel.org>; Tue, 19 Apr 2022 00:31:42 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4EB04427657;
	Mon, 18 Apr 2022 17:31:21 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0BD60425525
 for <lustre-devel@lists.lustre.org>; Mon, 18 Apr 2022 17:31:07 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 2161210058C3;
 Mon, 18 Apr 2022 20:31:06 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 189B0D58C0; Mon, 18 Apr 2022 20:31:06 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 18 Apr 2022 20:30:57 -0400
Message-Id: <1650328264-8763-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 0/7] lustre: OpenSFS updates April 18, 2022
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

Backport patches from the OpenSFS tree to the native Linux client
as of April 18, 2022.

Alexander Zarochentsev (1):
  lustre: ptlrpc: unregister reply buffer on rq_err

Andreas Dilger (1):
  lustre: lmv: change default hash back to fnv_1a_64

Chris Horn (2):
  lnet: only update gateway NI status on discovery
  lnet: ln_api_mutex deadlocks

John L. Hammond (1):
  lustre: lov: remove lo_trunc_stripeno

Patrick Farrell (1):
  lustre: llite: Fix use of uninitialized fields

Shaun Tancheff (1):
  lustre: clio: Disable lockless for DIO with O_APPEND

 fs/lustre/llite/file.c                  |  2 ++
 fs/lustre/llite/rw.c                    | 18 ++++++++++-----
 fs/lustre/lov/lov_cl_internal.h         | 17 ++++++--------
 fs/lustre/lov/lov_io.c                  | 40 +++++++++++++++++++++++----------
 fs/lustre/lov/lov_lock.c                | 35 ++++++++++++++++-------------
 fs/lustre/lov/lov_object.c              |  2 --
 fs/lustre/ptlrpc/client.c               |  5 +++++
 include/uapi/linux/lustre/lustre_user.h |  2 +-
 net/lnet/lnet/api-ni.c                  | 40 ++++++++++++++++++++++++++++-----
 net/lnet/lnet/config.c                  |  2 +-
 net/lnet/lnet/lib-move.c                | 18 +++++++++++----
 net/lnet/lnet/peer.c                    | 11 ++++++---
 net/lnet/lnet/router.c                  |  2 +-
 net/lnet/lnet/router_proc.c             |  2 +-
 14 files changed, 135 insertions(+), 61 deletions(-)

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
