Return-Path: <SRS0=WSMT=J7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74803C43460
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 00:10:26 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0EA57610E6
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 00:10:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EA57610E6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 62CCF21F4A9;
	Mon,  3 May 2021 17:10:24 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 730DE21F3B4
 for <lustre-devel@lists.lustre.org>; Mon,  3 May 2021 17:10:21 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 15FDBEDA;
 Mon,  3 May 2021 20:10:20 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 0B87E8AD38; Mon,  3 May 2021 20:10:20 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  3 May 2021 20:10:02 -0400
Message-Id: <1620087016-17857-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/14] Update to OpenSFS tree as of May 3,
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

Port the latest work from the OpenSFS tree to the native
Linux client as of May 4, 2021. This now includes the
fake symlink DOAS work.

Alex Zhuravlev (1):
  lustre: mdc: make rpc set for MDS_STATFS interruptible

Alexander Boyko (1):
  lustre: ptlrpc: idle import vs lock enqueue race

Andreas Dilger (1):
  lustre: mdc: include linux/idr.h for referenced code

Bruno Faccini (1):
  lustre: llite: fake symlink type of foreign file/dir

Chris Horn (5):
  lnet: Recover local NI w/exponential backoff interval
  lnet: Deprecate lnet_recovery_interval
  lnet: Router ping timeout with discovery disabled
  lnet: Ensure proper peer, peer NI, peer net hierarchy
  lnet: Skip discovery in LNetPrimaryNID if DD disabled

Mr NeilBrown (4):
  lnet: libcfs: simplify task management in tracefile.c
  lustre: move lu_tgt_pool out of obd_target.h
  lnet: libcfs: remove references to Sun Trademark.
  lustre: llite: use d_is_symlink to test if dentry is a symlink

Patrick Farrell (1):
  lustre: llite: Remove last lockahead old compat

 fs/lustre/include/lu_object.h           |  18 +-
 fs/lustre/include/lustre_net.h          |   1 +
 fs/lustre/include/obd_class.h           |   2 +
 fs/lustre/include/obd_support.h         |   1 +
 fs/lustre/include/obd_target.h          |  53 ---
 fs/lustre/llite/Makefile                |   1 +
 fs/lustre/llite/dcache.c                |  14 +-
 fs/lustre/llite/dir.c                   |  11 +
 fs/lustre/llite/file.c                  |  53 ++-
 fs/lustre/llite/foreign_symlink.h       |  49 +++
 fs/lustre/llite/llite_foreign.c         | 284 ++++++++++++
 fs/lustre/llite/llite_foreign_symlink.c | 758 ++++++++++++++++++++++++++++++++
 fs/lustre/llite/llite_internal.h        |  35 +-
 fs/lustre/llite/llite_lib.c             | 105 +++++
 fs/lustre/llite/lproc_llite.c           |  12 +
 fs/lustre/llite/namei.c                 |  33 +-
 fs/lustre/llite/pcc.c                   |   4 +-
 fs/lustre/llite/symlink.c               |   1 +
 fs/lustre/lov/lov_object.c              |   3 +-
 fs/lustre/lov/lov_pack.c                |  13 +-
 fs/lustre/mdc/mdc_changelog.c           |   1 +
 fs/lustre/mdc/mdc_request.c             |   1 +
 fs/lustre/obdclass/lu_tgt_pool.c        |   2 +-
 fs/lustre/obdclass/obd_mount.c          |   4 +-
 fs/lustre/osc/osc_lock.c                |   5 +
 fs/lustre/ptlrpc/client.c               |  11 +
 fs/lustre/ptlrpc/import.c               |  63 ++-
 fs/lustre/ptlrpc/pinger.c               |   5 +-
 include/linux/libcfs/libcfs.h           |   1 -
 include/linux/libcfs/libcfs_cpu.h       |   1 -
 include/linux/libcfs/libcfs_debug.h     |   1 -
 include/linux/libcfs/libcfs_hash.h      |   1 -
 include/linux/libcfs/libcfs_private.h   |   1 -
 include/linux/libcfs/libcfs_string.h    |   1 -
 include/linux/lnet/lib-lnet.h           |   9 +
 include/linux/lnet/lib-types.h          |   7 +
 include/uapi/linux/lustre/lustre_user.h |  49 ++-
 net/lnet/libcfs/debug.c                 |   1 -
 net/lnet/libcfs/hash.c                  |   1 -
 net/lnet/libcfs/libcfs_cpu.c            |   1 -
 net/lnet/libcfs/libcfs_lock.c           |   1 -
 net/lnet/libcfs/libcfs_mem.c            |   1 -
 net/lnet/libcfs/libcfs_string.c         |   1 -
 net/lnet/libcfs/module.c                |   1 -
 net/lnet/libcfs/tracefile.c             |  83 ++--
 net/lnet/libcfs/tracefile.h             |   1 -
 net/lnet/lnet/api-ni.c                  |  26 +-
 net/lnet/lnet/lib-move.c                |  60 +--
 net/lnet/lnet/lib-msg.c                 |  48 +-
 net/lnet/lnet/peer.c                    |  55 ++-
 net/lnet/lnet/router.c                  |   8 +-
 51 files changed, 1640 insertions(+), 262 deletions(-)
 delete mode 100644 fs/lustre/include/obd_target.h
 create mode 100644 fs/lustre/llite/foreign_symlink.h
 create mode 100644 fs/lustre/llite/llite_foreign.c
 create mode 100644 fs/lustre/llite/llite_foreign_symlink.c

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
