Return-Path: <SRS0=EXfh=KK=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B5CFC433ED
	for <lustre-devel@archiver.kernel.org>; Sat, 15 May 2021 13:06:18 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id CBDFC61355
	for <lustre-devel@archiver.kernel.org>; Sat, 15 May 2021 13:06:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBDFC61355
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6CCE721E041;
	Sat, 15 May 2021 06:06:16 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7A51421CAD2
 for <lustre-devel@lists.lustre.org>; Sat, 15 May 2021 06:06:13 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 7431C100676D;
 Sat, 15 May 2021 09:06:12 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 6B10164D42; Sat, 15 May 2021 09:06:12 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sat, 15 May 2021 09:05:57 -0400
Message-Id: <1621083970-32463-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/13] lustre: sync to OpenSFS tree as of May
 14, 2021
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

Next batch of patches from the OpenSFS tree ported the native Linux
client.

Andreas Dilger (1):
  lustre: lmv: qos stay on current MDT if less full

Bobi Jam (1):
  lustre: lov: correctly handling sub-lock init failure

Chris Horn (3):
  lnet: Allow delayed sends
  lnet: Local NI must be on same net as next-hop
  lnet: Correct the router ping interval calculation

Lai Siyao (2):
  lustre; obdclass: server qos penalty miscaculated
  lustre: lmv: add default LMV inherit depth

Nikitas Angelinas (1):
  lustre: ptlrpc: remove might_sleep() in sptlrpc_gc_del_sec()

Oleg Drokin (1):
  lustre: llite: Introduce inode open heat counter

Sebastien Buisson (1):
  lustre: sec: rework includes for client encryption

Serguei Smirnov (1):
  lnet: socklnd: add conns_per_peer parameter

Wang Shilong (2):
  lustre: readahead: export pages directly without RA
  lustre: readahead: fix reserving for unaliged read

 fs/lustre/include/lu_object.h              |  30 +++++-
 fs/lustre/include/lustre_crypto.h          | 158 ++++++++++++++++-------------
 fs/lustre/include/lustre_lmv.h             |   8 +-
 fs/lustre/include/obd.h                    |  10 +-
 fs/lustre/llite/crypto.c                   |   6 +-
 fs/lustre/llite/dir.c                      |  20 ++--
 fs/lustre/llite/file.c                     |  92 +++++++++++++----
 fs/lustre/llite/llite_internal.h           |  50 +++++----
 fs/lustre/llite/llite_lib.c                |  11 +-
 fs/lustre/llite/lproc_llite.c              | 112 +++++++++++++++++++-
 fs/lustre/llite/namei.c                    |  37 ++++---
 fs/lustre/llite/rw.c                       |  13 ++-
 fs/lustre/llite/super25.c                  |   4 +-
 fs/lustre/llite/vvp_io.c                   |  18 ++--
 fs/lustre/lmv/lmv_obd.c                    |  84 ++++++++++++---
 fs/lustre/lov/lov_lock.c                   |   2 +
 fs/lustre/obdclass/lu_tgt_descs.c          |  36 +++----
 fs/lustre/osc/osc_request.c                |  12 +--
 fs/lustre/ptlrpc/pack_generic.c            |   5 +-
 fs/lustre/ptlrpc/sec_gc.c                  |   2 -
 include/linux/lnet/lib-lnet.h              |   1 +
 include/linux/lnet/lib-types.h             |   4 +-
 include/uapi/linux/lustre/lustre_user.h    |  37 ++++++-
 net/lnet/klnds/socklnd/socklnd.c           |  92 +++++++++++++++--
 net/lnet/klnds/socklnd/socklnd.h           |  23 ++++-
 net/lnet/klnds/socklnd/socklnd_cb.c        |   3 +-
 net/lnet/klnds/socklnd/socklnd_modparams.c |   9 ++
 net/lnet/lnet/lib-move.c                   |  34 +++----
 net/lnet/lnet/net_fault.c                  |  24 ++++-
 net/lnet/lnet/router.c                     |  57 +++++++----
 30 files changed, 726 insertions(+), 268 deletions(-)

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
