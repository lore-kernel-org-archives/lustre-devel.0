Return-Path: <SRS0=Xi2l=P3=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11F4FC433EF
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:07:51 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B341D61053
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:07:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org B341D61053
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id BC9FA21C996;
	Mon,  8 Nov 2021 07:07:49 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (SMTP3.CCS.ORNL.GOV [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9ADD321C967
 for <lustre-devel@lists.lustre.org>; Mon,  8 Nov 2021 07:07:47 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 0A5CAB6;
 Mon,  8 Nov 2021 10:07:46 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id F191FE07E1; Mon,  8 Nov 2021 10:07:45 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  8 Nov 2021 10:07:28 -0500
Message-Id: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/15] lustre: update to OpenSFS tree Nov 8,
 2021
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

Next batch of patches that landed to OpenSFS tree backported
to native Linux client.

Alex Zhuravlev (1):
  lustre: mdc: add support for grant shrink

Alexander Zarochentsev (1):
  lustre: ptlrpc: recalc timer on EINPROGRESS reply

Andreas Dilger (3):
  lustre: ptlrpc: align function names with param names
  lnet: don't retry allocating router buffers
  lustre: obdclass: add start time to stats files

Andrew Perepechko (1):
  lustre: vfs: set_nlink() is not race-safe

Artem Blagodarenko (1):
  lnet: socklnd: lock ksnc_tx_queue list processing

Chris Horn (1):
  lnet: Fix reference leak in lnet_parse

Lai Siyao (2):
  lustre: dne: dir migrate in QOS mode
  lustre: lmv: update default LMV upon any change

Lei Feng (1):
  lustre: ptlrpc: remove LASSERT in nrs_polices debugfs handler

Sebastien Buisson (1):
  lustre: sec: keep encryption context in xattr cache

Sergey Cheremencev (1):
  lustre: lov: fix error handling in lov_new_pool

Serguei Smirnov (2):
  lnet: socklnd: default conns_per_peer to 0
  lnet: don't use hops to determine the route state

 fs/lustre/include/lprocfs_status.h         |   5 +-
 fs/lustre/include/lustre_lmv.h             |  12 +-
 fs/lustre/include/lustre_osc.h             |   3 +
 fs/lustre/include/obd.h                    |   2 +
 fs/lustre/llite/file.c                     |   3 +
 fs/lustre/llite/llite_internal.h           |   6 +-
 fs/lustre/llite/llite_lib.c                |   6 +-
 fs/lustre/llite/lproc_llite.c              |  23 ++--
 fs/lustre/llite/namei.c                    |  12 +-
 fs/lustre/llite/xattr_cache.c              |  36 +++++-
 fs/lustre/lmv/lmv_intent.c                 |   2 +
 fs/lustre/lmv/lmv_obd.c                    | 176 ++++++++++++++++++++++++++---
 fs/lustre/lov/lov_pool.c                   |   3 +-
 fs/lustre/mdc/lproc_mdc.c                  | 114 ++++++++++++++++++-
 fs/lustre/obdclass/genops.c                |   8 +-
 fs/lustre/obdclass/lprocfs_status.c        |  28 +++--
 fs/lustre/obdclass/lu_tgt_pool.c           |   9 +-
 fs/lustre/osc/lproc_osc.c                  |  15 +--
 fs/lustre/osc/osc_request.c                |   2 +
 fs/lustre/ptlrpc/client.c                  |   4 +-
 fs/lustre/ptlrpc/lproc_ptlrpc.c            | 100 ++++++++++------
 include/linux/lnet/lib-lnet.h              |   2 +-
 net/lnet/klnds/socklnd/socklnd_cb.c        |   5 +
 net/lnet/klnds/socklnd/socklnd_modparams.c |  10 +-
 net/lnet/lnet/lib-move.c                   |   2 +
 net/lnet/lnet/router.c                     |  39 ++++---
 26 files changed, 501 insertions(+), 126 deletions(-)

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
