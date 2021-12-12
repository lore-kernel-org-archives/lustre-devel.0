Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 2FD74C433EF
	for <lustre-devel@archiver.kernel.org>; Sun, 12 Dec 2021 15:08:08 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id EFE1E21E021;
	Sun, 12 Dec 2021 07:08:07 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6630221CBC4
 for <lustre-devel@lists.lustre.org>; Sun, 12 Dec 2021 07:08:06 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id AD1F4100848F;
 Sun, 12 Dec 2021 10:08:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A0241E07E0; Sun, 12 Dec 2021 10:08:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 12 Dec 2021 10:07:51 -0500
Message-Id: <1639321683-22909-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/12] lustre: backport OpenSFS work Dec 12,
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

Backport of the latest work on the OpenSFS branch as of Dec 12
2021

Andreas Dilger (1):
  lustre: llite: avoid needless large stats alloc

Chris Horn (5):
  lustre: ptlrpc: Do not unlink difficult reply until sent
  lnet: Allow specifying a source NID for lnetctl ping
  lnet: Fix source specified send to different net
  lnet: Fix source specified to routed destination
  lnet: o2iblnd: Default map_on_demand to 1

James Simmons (2):
  lnet: uapi: move out kernel only code.
  lustre: obdclass: make niduuid for lustre_stop_mgc() static

Qian Yingjin (1):
  lustre: pcc: disable PCC for encrypted files

Sebastien Buisson (1):
  lustre: llite: properly detect SELinux disabled case

Sergey Cheremencev (1):
  lustre: obdclass: cosmetic changes in pool handling

Vladimir Saveliev (1):
  lustre: llite: do not take mod rpc slot for getxattr

 fs/lustre/include/lu_object.h              |   2 +-
 fs/lustre/include/lustre_net.h             |   3 +-
 fs/lustre/include/obd_support.h            |   1 +
 fs/lustre/ldlm/ldlm_lib.c                  |  11 +-
 fs/lustre/llite/file.c                     |   3 +
 fs/lustre/llite/llite_internal.h           |   7 +-
 fs/lustre/llite/llite_lib.c                |  10 +-
 fs/lustre/llite/lproc_llite.c              | 238 +++++++++++++++++++++--------
 fs/lustre/llite/pcc.c                      |   3 +
 fs/lustre/llite/xattr_cache.c              |   2 +
 fs/lustre/llite/xattr_security.c           |   8 +-
 fs/lustre/mdc/mdc_locks.c                  |   2 +-
 fs/lustre/obdclass/lu_tgt_pool.c           |  15 +-
 fs/lustre/obdclass/obd_mount.c             |  25 +--
 fs/lustre/ptlrpc/events.c                  |  19 ++-
 fs/lustre/ptlrpc/pack_generic.c            |   2 +-
 fs/lustre/ptlrpc/service.c                 |  10 +-
 include/linux/lnet/lib-types.h             |  16 ++
 include/uapi/linux/lnet/lnet-dlc.h         |   1 +
 include/uapi/linux/lnet/nidstr.h           |  13 --
 net/lnet/klnds/o2iblnd/o2iblnd_modparams.c |   3 +-
 net/lnet/lnet/api-ni.c                     |  29 +++-
 net/lnet/lnet/lib-move.c                   |  28 ++--
 23 files changed, 302 insertions(+), 149 deletions(-)

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
