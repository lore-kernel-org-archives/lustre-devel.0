Return-Path: <SRS0=0agL=O7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B6B0C433EF
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:40:57 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id EB74E60EBB
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:40:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org EB74E60EBB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8C29E21FC9D;
	Mon, 11 Oct 2021 10:40:55 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E807421FB84
 for <lustre-devel@lists.lustre.org>; Mon, 11 Oct 2021 10:40:52 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id A163624C;
 Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 98650A56A1; Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 11 Oct 2021 13:40:29 -0400
Message-Id: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/20] lustre: sync to OpenSFS Oct 11, 2021
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

Update to latest OpenSFS work. Fixed a few specific Linux client
bugs (lu_ref_add and osc_lru_reclaim patches).

Alex Zhuravlev (1):
  lustre: lov: prefer mirrors on non-rotational OSTs

Alexander Boyko (1):
  lustre: ptlrpc: handle reply and resend reorder

Andreas Dilger (1):
  lustre: brw: log T10 GRD tags during checksum calcs

Chris Horn (2):
  lnet: Ensure round robin selection of local NIs
  lnet: Ensure round robin selection of peer NIs

James Simmons (3):
  lustre: llite: harden ll_sbi ll_flags
  lustre: osc: use original cli for osc_lru_reclaim for debug msg
  lustre: obdclass: lu_ref_add() called in atomic context

Jian Yu (1):
  lnet: include linux/ethtool.h

Lai Siyao (1):
  lustre: nfs: don't store parent fid

Mikhail Pershin (1):
  lustre: llite: support fallocate() on selected mirror

Mr NeilBrown (1):
  lustre: ptlrpc: use wait_woken() in ptlrpcd()

Oleg Drokin (2):
  lustre: update version to 2.14.55
  lustre: osc: Do not attempt sending empty pages

Sebastien Buisson (4):
  lustre: sec: filename encryption - symlink support
  lustre: llite: move env contexts to ll_inode_info level
  lustre: sec: do not expose security.c to listxattr/getxattr
  lustre: sec: access to enc file's xattrs

Sergey Cheremencev (1):
  lustre: mdc: update max_easize on reconnect

Wang Shilong (1):
  lustre: quota: fix quota with root squash enabled

 fs/lustre/include/lu_object.h           |   7 +
 fs/lustre/include/obd.h                 |   2 +
 fs/lustre/llite/acl.c                   |   4 +-
 fs/lustre/llite/crypto.c                |  31 +-
 fs/lustre/llite/dir.c                   |  25 +-
 fs/lustre/llite/file.c                  |  30 +-
 fs/lustre/llite/llite_foreign_symlink.c |  12 +-
 fs/lustre/llite/llite_internal.h        | 150 ++++------
 fs/lustre/llite/llite_lib.c             | 494 ++++++++++++++++----------------
 fs/lustre/llite/llite_mmap.c            |  17 +-
 fs/lustre/llite/llite_nfs.c             |  13 -
 fs/lustre/llite/lproc_llite.c           |  78 ++---
 fs/lustre/llite/namei.c                 | 111 +++++--
 fs/lustre/llite/rw.c                    |  36 +--
 fs/lustre/llite/rw26.c                  |   5 +-
 fs/lustre/llite/statahead.c             |  27 +-
 fs/lustre/llite/symlink.c               |  85 +++++-
 fs/lustre/llite/vvp_dev.c               |   2 +-
 fs/lustre/llite/xattr.c                 |  53 +++-
 fs/lustre/llite/xattr_cache.c           |  65 +++--
 fs/lustre/lov/lov_cl_internal.h         |   5 +-
 fs/lustre/lov/lov_io.c                  |   3 +-
 fs/lustre/lov/lov_object.c              |  26 +-
 fs/lustre/mdc/mdc_dev.c                 |   2 +-
 fs/lustre/mdc/mdc_request.c             |   1 +
 fs/lustre/osc/osc_cache.c               |  23 +-
 fs/lustre/osc/osc_page.c                |  23 +-
 fs/lustre/osc/osc_quota.c               |   1 +
 fs/lustre/osc/osc_request.c             |  93 +++---
 fs/lustre/ptlrpc/client.c               |   5 +-
 fs/lustre/ptlrpc/events.c               |   3 +-
 fs/lustre/ptlrpc/ptlrpcd.c              |  23 +-
 fs/lustre/ptlrpc/wiretest.c             |   2 +
 include/uapi/linux/lustre/lustre_idl.h  |   4 +-
 include/uapi/linux/lustre/lustre_ver.h  |   4 +-
 net/lnet/klnds/o2iblnd/o2iblnd.c        |   4 +-
 net/lnet/lnet/lib-move.c                |   4 +-
 37 files changed, 860 insertions(+), 613 deletions(-)

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
