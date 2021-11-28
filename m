Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id C1D9FC433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 28 Nov 2021 23:28:00 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id BC62C200EBB;
	Sun, 28 Nov 2021 15:27:59 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0C582200DE2
 for <lustre-devel@lists.lustre.org>; Sun, 28 Nov 2021 15:27:58 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 80699B7;
 Sun, 28 Nov 2021 18:27:56 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 74CCDC1AC4; Sun, 28 Nov 2021 18:27:56 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 28 Nov 2021 18:27:35 -0500
Message-Id: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/19] lustre: update to OpenSFS tree Nov 28,
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

Backport patches from the OpenSFS to the native Linux lustre client.
Track down a bug unique to Linux client exposed with sanity-lnet
test 212.

Alex Zhuravlev (2):
  lnet: libcfs: add timeout to cfs_race() to fix race
  lustre: ptlrpc: fix timeout after spurious wakeup

Andreas Dilger (1):
  lustre: ptlrpc: remove bogus LASSERT

Andriy Skulysh (1):
  lustre: llite: skip request slot for lmv_revalidate_slaves()

Bobi Jam (2):
  lustre: llite: tighten condition for fault not drop mmap_sem
  lustre: llite: mend the trunc_sem_up_write()

Chris Horn (4):
  lnet: o2iblnd: map_on_demand not needed for frag interop
  lnet: o2iblnd: Fix logic for unaligned transfer
  lnet: Reset ni_ping_count only on receive
  lnet: Fail peer add for existing gw peer

James Simmons (2):
  lnet: fix delay rule crash
  lnet: Netlink improvements

Mr NeilBrown (4):
  lnet: change tp_nid to 16byte in lnet_test_peer.
  lnet: extend preferred nids in struct lnet_peer_ni
  lnet: switch to large lnet_processid for matching
  lnet: libcfs: separate daemon_list from cfs_trace_data

Patrick Farrell (1):
  lustre: llite: Do not count tiny write twice

Sebastien Buisson (1):
  lustre: quota: optimize capability check for root squash

Serguei Smirnov (1):
  lnet: set eth routes needed for multi rail

 fs/lustre/include/lustre_dlm.h             |   7 +-
 fs/lustre/include/obd.h                    |   1 +
 fs/lustre/ldlm/ldlm_request.c              |  18 ++-
 fs/lustre/llite/file.c                     |   2 -
 fs/lustre/llite/llite_internal.h           |   2 +
 fs/lustre/llite/llite_mmap.c               |  13 +-
 fs/lustre/llite/statahead.c                |   1 +
 fs/lustre/lmv/lmv_intent.c                 |   2 +
 fs/lustre/mdc/mdc_dev.c                    |   3 +-
 fs/lustre/mdc/mdc_locks.c                  |   5 +-
 fs/lustre/osc/osc_cache.c                  |  23 ++--
 fs/lustre/osc/osc_request.c                |   2 +-
 fs/lustre/ptlrpc/niobuf.c                  |  32 +++--
 fs/lustre/ptlrpc/ptlrpcd.c                 |  11 +-
 include/linux/libcfs/libcfs_fail.h         |  10 +-
 include/linux/lnet/api.h                   |   2 +-
 include/linux/lnet/lib-lnet.h              |  29 ++--
 include/linux/lnet/lib-types.h             |  18 ++-
 include/uapi/linux/lnet/lnet-nl.h          |  29 +++-
 include/uapi/linux/lnet/nidstr.h           |   3 +-
 net/lnet/klnds/o2iblnd/o2iblnd.c           |   2 +-
 net/lnet/klnds/o2iblnd/o2iblnd.h           |   6 +-
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c        |  31 ++---
 net/lnet/klnds/socklnd/socklnd_modparams.c |   5 +
 net/lnet/libcfs/tracefile.c                | 213 +++++++++++++++--------------
 net/lnet/libcfs/tracefile.h                |  17 +--
 net/lnet/lnet/api-ni.c                     |  37 ++---
 net/lnet/lnet/lib-me.c                     |   4 +-
 net/lnet/lnet/lib-move.c                   |  86 ++++++------
 net/lnet/lnet/lib-msg.c                    |   6 +-
 net/lnet/lnet/lib-ptl.c                    |  45 +++---
 net/lnet/lnet/net_fault.c                  |  16 +--
 net/lnet/lnet/nidstrings.c                 |   9 +-
 net/lnet/lnet/peer.c                       | 111 +++++++++------
 net/lnet/lnet/udsp.c                       |  38 ++---
 net/lnet/selftest/rpc.c                    |  10 +-
 36 files changed, 473 insertions(+), 376 deletions(-)

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
