Return-Path: <SRS0=Kfxm=MZ=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6328C4338F
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:51:34 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 853A560FC2
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:51:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 853A560FC2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 54E43352E47;
	Mon,  2 Aug 2021 12:51:24 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6E56835286A
 for <lustre-devel@lists.lustre.org>; Mon,  2 Aug 2021 12:50:54 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 4AB9F1007A89;
 Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 42B73C2F46; Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  2 Aug 2021 15:50:20 -0400
Message-Id: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/25] Sync to OpenSFS tree as of Aug 2, 2021
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

Port the latest patches from the OpenSFS tree as of Aug 2, 2021.
One patch was held back ("lustre: pcc: add LCM_FL_PCC_RDONLY layout flag")
due to a bug exposed by its change.

Andreas Dilger (2):
  lustre: llite: revert 'simplify callback handling for async getattr'
  lustre: uapi: remove MDS_SETATTR_PORTAL and service

Chris Horn (1):
  lnet: Protect lpni deref in lnet_health_check

Cyril Bordage (3):
  lnet: print device status in net show command
  lnet: check memdup_user_nul using IS_ERR
  lnet: add "stats reset" to lnetctl

Lai Siyao (3):
  lustre: lmv: getattr_name("..") under striped directory
  lustre: mdc: set default LMV on ROOT
  lustre: llite: enable filesystem-wide default LMV

Mr NeilBrown (2):
  lnet: discard lnet_current_net_count
  lnet: convert kiblnd/ksocknal_thread_start to vararg

Oleg Drokin (1):
  lustre: update version to 2.14.53

Patrick Farrell (10):
  lustre: llite: No locked parallel DIO
  lustre: llite: Modify AIO/DIO reference counting
  lustre: llite: Remove transient page counting
  lustre: lov: Improve DIO submit
  lustre: llite: Adjust dio refcounting
  lustre: clio: Skip prep for transients
  lustre: osc: Improve osc_queue_sync_pages
  lustre: osc: Remove lockless truncate
  lustre: osc: Remove client contention support
  lustre: osc: osc: Do not flush on lockless cancel

Serguei Smirnov (1):
  lnet: o2iblnd: clear fatal error on successful failover

Wang Shilong (2):
  lustre: llite: avoid stale data reading
  lustre: llite: avoid project quota overflow

 fs/lustre/include/cl_object.h           |  23 ++-
 fs/lustre/include/lustre_osc.h          |   3 -
 fs/lustre/include/obd.h                 |  37 ++--
 fs/lustre/include/obd_class.h           |   4 +-
 fs/lustre/llite/dir.c                   |   2 +
 fs/lustre/llite/file.c                  |  21 ++-
 fs/lustre/llite/llite_internal.h        |  12 +-
 fs/lustre/llite/llite_lib.c             |  22 ++-
 fs/lustre/llite/namei.c                 |  74 +++++++-
 fs/lustre/llite/rw.c                    |   4 +-
 fs/lustre/llite/rw26.c                  |  22 ++-
 fs/lustre/llite/statahead.c             | 324 +++++++++++++++++++++-----------
 fs/lustre/llite/vvp_internal.h          |   7 -
 fs/lustre/llite/vvp_io.c                |   4 +-
 fs/lustre/llite/vvp_object.c            |   4 +-
 fs/lustre/llite/vvp_page.c              |  22 ++-
 fs/lustre/lmv/lmv_obd.c                 |  44 +++--
 fs/lustre/lmv/lproc_lmv.c               |  26 ++-
 fs/lustre/lov/lov_io.c                  |  23 ++-
 fs/lustre/mdc/lproc_mdc.c               |  43 -----
 fs/lustre/mdc/mdc_dev.c                 |  15 +-
 fs/lustre/mdc/mdc_internal.h            |   3 +-
 fs/lustre/mdc/mdc_locks.c               |  31 +--
 fs/lustre/mdc/mdc_request.c             |   8 +
 fs/lustre/obdclass/cl_io.c              |  20 +-
 fs/lustre/obdclass/cl_page.c            |  21 ++-
 fs/lustre/obdecho/echo_client.c         |   4 +-
 fs/lustre/osc/lproc_osc.c               |  68 -------
 fs/lustre/osc/osc_cache.c               |   3 +-
 fs/lustre/osc/osc_io.c                  |  10 -
 fs/lustre/osc/osc_lock.c                |  31 +--
 fs/lustre/osc/osc_object.c              |  22 ---
 fs/lustre/ptlrpc/wiretest.c             |   2 -
 include/linux/lnet/lib-lnet.h           |   1 -
 include/uapi/linux/lnet/libcfs_ioctl.h  |   3 +-
 include/uapi/linux/lnet/lnet-dlc.h      |   1 +
 include/uapi/linux/lustre/lustre_idl.h  |  10 +-
 include/uapi/linux/lustre/lustre_user.h |   2 +
 include/uapi/linux/lustre/lustre_ver.h  |   4 +-
 net/lnet/klnds/o2iblnd/o2iblnd.c        |  37 +++-
 net/lnet/klnds/o2iblnd/o2iblnd.h        |  10 +-
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c     |  12 --
 net/lnet/klnds/socklnd/socklnd.c        |  16 +-
 net/lnet/klnds/socklnd/socklnd.h        |  10 +-
 net/lnet/klnds/socklnd/socklnd_cb.c     |  17 +-
 net/lnet/libcfs/module.c                |   4 +-
 net/lnet/libcfs/tracefile.c             |   8 +-
 net/lnet/lnet/api-ni.c                  |  32 +---
 net/lnet/lnet/lib-msg.c                 |  71 +++----
 net/lnet/lnet/router_proc.c             |   4 +-
 50 files changed, 642 insertions(+), 559 deletions(-)

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
