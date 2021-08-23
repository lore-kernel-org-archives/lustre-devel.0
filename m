Return-Path: <SRS0=6+cL=NO=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29A82C4338F
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:27:54 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A3361611F2
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:27:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org A3361611F2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0182521CAB9;
	Sun, 22 Aug 2021 19:27:52 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E99C521CAB2
 for <lustre-devel@lists.lustre.org>; Sun, 22 Aug 2021 19:27:49 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 1A62B100BAEB;
 Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 0B5DFB6C67; Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 22 Aug 2021 22:27:31 -0400
Message-Id: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/15] lustre: sync to OpenSFS as of Aug 22,
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

Update to latest OpenSFS work which is at 2.14.54

Alex Zhuravlev (1):
  lustre: mgc: rework mgc_apply_recover_logs() for gcc10

Amir Shehata (3):
  lnet: keep in insync to change due to GPU Direct Support
  lustre: osc: Support RDMA only pages
  lnet: peer state to lock primary nid

Chris Horn (3):
  lnet: Reflect ni_fatal in NI status
  lnet: Provide kernel API for adding peers
  lustre: obdclass: Add peer/peer NI when processing llog

James Simmons (1):
  lustre: obdclass: reintroduce lu_ref

Lai Siyao (1):
  lustre: uapi: support fixed directory layout

Mikhail Pershin (1):
  lustre: mdt: implement fallocate in MDC/MDT

Oleg Drokin (1):
  lustre: update version to 2.14.54

Qian Yingjin (1):
  lustre: pcc: add LCM_FL_PCC_RDONLY layout flag

Serguei Smirnov (2):
  lnet: socklnd: allow dynamic setting of conns_per_peer
  lnet: socklnd: set conns_per_peer based on link speed

Shaun Tancheff (1):
  lustre: llite: Proved an abstraction for AS_EXITING

 fs/lustre/Kconfig                          |   9 +
 fs/lustre/include/lu_ref.h                 | 104 +++++++-
 fs/lustre/include/lustre_osc.h             |  10 +-
 fs/lustre/ldlm/ldlm_lib.c                  |   3 +-
 fs/lustre/llite/llite_internal.h           |   7 +
 fs/lustre/llite/vvp_object.c               |   2 +-
 fs/lustre/mdc/mdc_dev.c                    |  29 ++-
 fs/lustre/mgc/mgc_request.c                |  24 +-
 fs/lustre/obdclass/Makefile                |   3 +-
 fs/lustre/obdclass/cl_io.c                 |   8 +
 fs/lustre/obdclass/lu_ref.c                | 393 +++++++++++++++++++++++++++++
 fs/lustre/obdclass/lustre_peer.c           |  18 +-
 fs/lustre/osc/osc_io.c                     |   7 +-
 fs/lustre/osc/osc_request.c                |  18 +-
 fs/lustre/ptlrpc/wiretest.c                |   3 +
 include/linux/lnet/api.h                   |   1 +
 include/linux/lnet/lib-lnet.h              |  19 +-
 include/linux/lnet/lib-types.h             |  32 +++
 include/uapi/linux/lnet/libcfs_ioctl.h     |   3 +-
 include/uapi/linux/lnet/lnet-dlc.h         |  14 +
 include/uapi/linux/lustre/lustre_user.h    |  18 +-
 include/uapi/linux/lustre/lustre_ver.h     |   4 +-
 net/lnet/klnds/o2iblnd/o2iblnd.c           |   1 +
 net/lnet/klnds/o2iblnd/o2iblnd.h           |   9 +-
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c        |  16 +-
 net/lnet/klnds/socklnd/socklnd.c           |  70 ++---
 net/lnet/klnds/socklnd/socklnd.h           |   4 +
 net/lnet/klnds/socklnd/socklnd_modparams.c | 126 ++++++++-
 net/lnet/lnet/api-ni.c                     |  59 ++++-
 net/lnet/lnet/lib-move.c                   |  62 ++++-
 net/lnet/lnet/peer.c                       |  60 ++++-
 net/lnet/lnet/router_proc.c                |   2 +-
 32 files changed, 1007 insertions(+), 131 deletions(-)

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
