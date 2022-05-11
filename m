Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id DFDA9C433EF
	for <lustre-devel@archiver.kernel.org>; Wed, 11 May 2022 19:38:49 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9892D21C8F9;
	Wed, 11 May 2022 12:38:48 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1781C216163
 for <lustre-devel@lists.lustre.org>; Wed, 11 May 2022 12:38:47 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 84FCAEC2;
 Wed, 11 May 2022 15:38:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 7926B58946; Wed, 11 May 2022 15:38:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>, Sebastien Buisson <sbuisson@ddn.com>
Date: Wed, 11 May 2022 15:38:38 -0400
Message-Id: <1652297923-16141-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 0/5] lustre: sync to 2.15 LTS release
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

Last patches needed to bring native client in sync with
Lustre 2.15 LTS release.

Alex Zhuravlev (1):
  lustre: obdclass: llog to handle gaps

Arshad Hussain (1):
  lustre: uapi: fallocate interop for 2.14 clients

John L. Hammond (1):
  lustre: llite: disable fast_read and workaround

Oleg Drokin (1):
  lustre: update version to 2.15.0

Sebastien Buisson (1):
  lustre: sec: correctly handle page lock in ll_io_zero_page

 fs/lustre/llite/llite_lib.c            | 22 +++++++++++-----------
 fs/lustre/llite/rw.c                   | 11 +++++++++--
 fs/lustre/llite/vvp_page.c             |  6 ------
 fs/lustre/obdclass/llog.c              | 25 +++++++++----------------
 include/uapi/linux/lustre/lustre_idl.h |  3 +++
 include/uapi/linux/lustre/lustre_ver.h |  6 +++---
 6 files changed, 35 insertions(+), 38 deletions(-)

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
