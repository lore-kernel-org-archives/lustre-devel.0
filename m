Return-Path: <SRS0=GtYW=HL=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61801C433DB
	for <lustre-devel@archiver.kernel.org>; Tue,  9 Feb 2021 00:54:35 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C042D61606
	for <lustre-devel@archiver.kernel.org>; Tue,  9 Feb 2021 00:54:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C042D61606
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4EA7030F9A7;
	Mon,  8 Feb 2021 16:54:34 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4A28B30F94F
 for <lustre-devel@lists.lustre.org>; Mon,  8 Feb 2021 16:54:30 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id E7A0A1006EB1;
 Mon,  8 Feb 2021 19:54:28 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id DFE144CC21; Mon,  8 Feb 2021 19:54:28 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  8 Feb 2021 19:54:18 -0500
Message-Id: <1612832067-1449-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 0/9] Sync to OpenSFS as of Feb 8, 2021
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

Bring the Linux client up to date with the OpenSFS branch as of
Feb 8, 2021

Andreas Dilger (2):
  lustre: llite: send file mode with rename RPC
  lustre: osc: avoid crash if ocd reset

Bobi Jam (1):
  lustre: osc: correctly update size/kms for fallocate

Emoly Liu (1):
  lustre: lov: return stripe_count=1 instead of 0 for DoM files

Mikhail Pershin (1):
  lustre: ldlm: don't change GROUP lock GID on client

Qian Yingjin (1):
  lustre: flr: skip unknown FLR component types

Sebastien Buisson (1):
  lustre: sec: get rid of bad rss-counter state messages

Wang Shilong (1):
  lustre: obdclass: connect vs disconnect race

Yang Sheng (1):
  lustre: obdclass: add option %H for jobid

 fs/lustre/include/cl_object.h           |  6 +++
 fs/lustre/include/lustre_crypto.h       |  8 +++
 fs/lustre/include/obd.h                 |  8 +--
 fs/lustre/ldlm/ldlm_inodebits.c         |  5 +-
 fs/lustre/llite/namei.c                 |  9 +++-
 fs/lustre/llite/rw26.c                  | 23 ++-------
 fs/lustre/llite/vvp_io.c                |  2 +-
 fs/lustre/lov/lov_cl_internal.h         |  7 ++-
 fs/lustre/lov/lov_ea.c                  | 66 ++++++++++++++++++------
 fs/lustre/lov/lov_internal.h            | 15 +++++-
 fs/lustre/lov/lov_io.c                  | 25 ++++++---
 fs/lustre/lov/lov_object.c              | 22 +++++++-
 fs/lustre/lov/lov_pack.c                |  8 +++
 fs/lustre/obdclass/cl_io.c              | 11 ----
 fs/lustre/obdclass/cl_page.c            |  1 +
 fs/lustre/obdclass/jobid.c              | 13 ++++-
 fs/lustre/obdclass/obd_config.c         |  4 --
 fs/lustre/osc/osc_cache.c               |  3 +-
 fs/lustre/osc/osc_io.c                  | 33 ++++++------
 fs/lustre/osc/osc_object.c              |  4 +-
 fs/lustre/osc/osc_request.c             | 89 ++++++++++++++++++++++++++-------
 include/uapi/linux/lustre/lustre_user.h |  1 +
 22 files changed, 258 insertions(+), 105 deletions(-)

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
