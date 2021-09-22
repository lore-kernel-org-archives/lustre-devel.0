Return-Path: <SRS0=2ypu=OM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A951C433EF
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:20:08 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 361546112F
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:20:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 361546112F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7B6D421E009;
	Tue, 21 Sep 2021 19:20:07 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2251221C9A7
 for <lustre-devel@lists.lustre.org>; Tue, 21 Sep 2021 19:20:05 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id F2D83349;
 Tue, 21 Sep 2021 22:20:03 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id E870EFF4A3; Tue, 21 Sep 2021 22:20:03 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Tue, 21 Sep 2021 22:19:37 -0400
Message-Id: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/24] lustre: Update to OpenSFS Sept 21, 2021
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

Merge latest new OpenSFS work to native Linux client. Biggest
change is the native support of the Lustre utilites with the
Linux client!!!! I do see new test failures due to the debugfs
root only issues which will be addressed later.

Alex Zhuravlev (1):
  lustre: obdclass: EAGAIN after rhashtable_walk_next()

Alexander Boyko (1):
  lustre: llite: don't touch vma after filemap_fault

Amir Shehata (1):
  lnet: Lock primary NID logic

Chris Horn (1):
  lnet: Check for -ESHUTDOWN in lnet_parse

Hongchao Zhang (2):
  lustre: quota: enforce block quota for chgrp
  lustre: llite: check read only mount for setquota

James Simmons (2):
  lustre: uapi: fixup UAPI headers for native Linux client.
  lustre: ptlrpc: separate out server code for wiretest

Mr NeilBrown (10):
  lnet: introduce struct lnet_nid
  lnet: add string formating/parsing for IPv6 nids
  lnet: change lpni_nid in lnet_peer_ni to lnet_nid
  lnet: change lp_primary_nid to struct lnet_nid
  lnet: change lp_disc_*_nid to struct lnet_nid
  lnet: socklnd: factor out key calculation for ksnd_peers
  lnet: introduce lnet_processid for ksock_peer_ni
  lnet: enhance connect/accept to support large addr
  lnet: change lr_nid to struct lnet_nid
  lnet: extend rspt_next_hop_nid in lnet_rsp_tracker

Oleg Drokin (1):
  lustre: llite: Remove inode locking in ll_fsync

Patrick Farrell (1):
  lustre: llite: Always do lookup on ENOENT in open

Qian Yingjin (1):
  lustre: pcc: VM_WRITE should not trigger layout write

Sebastien Buisson (1):
  lustre: sec: filename encryption

Serguei Smirnov (1):
  lnet: socklnd: fix link state detection

Vitaly Fertman (1):
  lustre: ptlrpc: two replay lock threads

 fs/lustre/include/cl_object.h           |   5 -
 fs/lustre/include/lustre_swab.h         |   1 -
 fs/lustre/include/obd.h                 |   4 +
 fs/lustre/include/obd_support.h         |   1 +
 fs/lustre/ldlm/ldlm_request.c           |  10 +-
 fs/lustre/llite/crypto.c                | 144 +++++++++
 fs/lustre/llite/dcache.c                |   8 +
 fs/lustre/llite/dir.c                   |  52 +++-
 fs/lustre/llite/file.c                  |  56 ++--
 fs/lustre/llite/llite_internal.h        |  29 +-
 fs/lustre/llite/llite_lib.c             |  63 +++-
 fs/lustre/llite/llite_mmap.c            |  31 +-
 fs/lustre/llite/namei.c                 |  47 ++-
 fs/lustre/llite/statahead.c             |  48 +++
 fs/lustre/llite/vvp_dev.c               |   6 +
 fs/lustre/llite/vvp_io.c                |   3 +-
 fs/lustre/lov/lov_io.c                  |   6 +-
 fs/lustre/mdc/mdc_lib.c                 |   6 +-
 fs/lustre/obdclass/jobid.c              |   5 +
 fs/lustre/obdclass/llog_swab.c          |  33 ---
 fs/lustre/obdclass/obd_config.c         |   4 +-
 fs/lustre/ptlrpc/layout.c               |   5 +-
 fs/lustre/ptlrpc/pack_generic.c         |  13 +-
 fs/lustre/ptlrpc/wiretest.c             | 210 ++++++-------
 include/linux/lnet/lib-lnet.h           |  39 ++-
 include/linux/lnet/lib-types.h          |  18 +-
 include/uapi/linux/lnet/lnet-idl.h      |  39 ++-
 include/uapi/linux/lnet/lnet-types.h    | 106 ++++++-
 include/uapi/linux/lnet/nidstr.h        |  12 +-
 include/uapi/linux/lustre/lustre_idl.h  |  78 +----
 include/uapi/linux/lustre/lustre_user.h |  20 ++
 net/lnet/klnds/o2iblnd/o2iblnd.c        |  13 +-
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c     |  17 +-
 net/lnet/klnds/socklnd/socklnd.c        | 353 +++++++++++++++-------
 net/lnet/klnds/socklnd/socklnd.h        |  14 +-
 net/lnet/klnds/socklnd/socklnd_cb.c     | 119 ++++----
 net/lnet/klnds/socklnd/socklnd_proto.c  |  14 +-
 net/lnet/lnet/acceptor.c                | 112 ++++---
 net/lnet/lnet/api-ni.c                  | 178 ++++++++---
 net/lnet/lnet/config.c                  |  20 +-
 net/lnet/lnet/lib-move.c                | 155 +++++-----
 net/lnet/lnet/lib-msg.c                 |  13 +-
 net/lnet/lnet/lib-socket.c              |  32 +-
 net/lnet/lnet/lo.c                      |   3 +-
 net/lnet/lnet/net_fault.c               |   4 +-
 net/lnet/lnet/nidstrings.c              | 163 ++++++++++-
 net/lnet/lnet/peer.c                    | 503 +++++++++++++++++++-------------
 net/lnet/lnet/router.c                  |  88 +++---
 net/lnet/lnet/router_proc.c             |  12 +-
 net/lnet/lnet/udsp.c                    |  39 +--
 50 files changed, 1997 insertions(+), 957 deletions(-)

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
