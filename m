Return-Path: <SRS0=JyPa=L7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3247EC07E95
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jul 2021 19:11:24 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id BF5AC61C48
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jul 2021 19:11:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF5AC61C48
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 52F4821F8D1;
	Wed,  7 Jul 2021 12:11:22 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6435B21F888
 for <lustre-devel@lists.lustre.org>; Wed,  7 Jul 2021 12:11:19 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 35AF210090E1;
 Wed,  7 Jul 2021 15:11:18 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 2DD189D8AD; Wed,  7 Jul 2021 15:11:18 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  7 Jul 2021 15:11:01 -0400
Message-Id: <1625685076-1964-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/15] lustre: updates to OpenSFS tree as of
 July 7 2021
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

Sync the native client to current tip of OpenSFS tree.

Alex Zhuravlev (1):
  lustre: mgc: configurable wait-to-reprocess time

Alexander Boyko (1):
  lustre: client: don't panic for mgs evictions

Chris Horn (3):
  lnet: Add health ping stats
  lnet: Ensure ref taken when queueing for discovery
  lnet: Correct distance calculation of local NIDs

James Simmons (1):
  lnet: add netlink infrastructure

Oleg Drokin (3):
  lustre: osc: Notify server if cache discard takes a long time
  lustre: mdt: New connect flag for non-open-by-fid lock request
  lustre: obdclass: Wake up entire queue of requests on close completion

Patrick Farrell (5):
  lustre: osc: Move shrink update to per-write
  lustre: llite: parallelize direct i/o issuance
  lustre: osc: Don't get time for each page
  lustre: clio: Implement real list splice
  lustre: osc: Simplify clipping for transient pages

Serguei Smirnov (1):
  lnet: socklnd: detect link state to set fatal error on ni

 fs/lustre/include/cl_object.h          | 13 +++++-
 fs/lustre/include/lustre_osc.h         |  6 +--
 fs/lustre/include/obd_class.h          | 15 ++++++
 fs/lustre/llite/file.c                 | 51 +++++++++++++++++++--
 fs/lustre/llite/llite_internal.h       |  9 ++++
 fs/lustre/llite/llite_lib.c            |  4 +-
 fs/lustre/llite/lproc_llite.c          | 37 +++++++++++++++
 fs/lustre/llite/namei.c                |  4 +-
 fs/lustre/llite/rw26.c                 | 41 ++++++-----------
 fs/lustre/llite/vvp_io.c               |  1 +
 fs/lustre/mgc/mgc_internal.h           |  8 ++++
 fs/lustre/mgc/mgc_request.c            | 44 +++++++++++++-----
 fs/lustre/obdclass/cl_io.c             | 39 +++++++++++++---
 fs/lustre/obdclass/genops.c            |  6 ++-
 fs/lustre/obdclass/lprocfs_status.c    |  6 +++
 fs/lustre/osc/osc_cache.c              | 42 ++++++++++++++---
 fs/lustre/osc/osc_internal.h           |  1 +
 fs/lustre/osc/osc_io.c                 | 18 ++++++--
 fs/lustre/osc/osc_page.c               | 10 ++--
 fs/lustre/osc/osc_request.c            | 54 +++++++++++++++++-----
 fs/lustre/ptlrpc/import.c              |  5 +-
 fs/lustre/ptlrpc/wiretest.c            |  2 +
 include/linux/lnet/lib-types.h         | 15 ++++++
 include/uapi/linux/lnet/lnet-dlc.h     |  4 ++
 include/uapi/linux/lnet/lnet-nl.h      | 67 +++++++++++++++++++++++++++
 include/uapi/linux/lustre/lustre_idl.h |  1 +
 net/lnet/klnds/socklnd/socklnd.c       | 78 ++++++++++++++++++++++++++++++++
 net/lnet/klnds/socklnd/socklnd.h       |  1 +
 net/lnet/lnet/api-ni.c                 | 83 ++++++++++++++++++++++++++++++++++
 net/lnet/lnet/lib-move.c               | 40 ++++++++++------
 net/lnet/lnet/peer.c                   | 10 ++--
 31 files changed, 611 insertions(+), 104 deletions(-)
 create mode 100644 include/uapi/linux/lnet/lnet-nl.h

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
