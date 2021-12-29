Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 5CD0EC433EF
	for <lustre-devel@archiver.kernel.org>; Wed, 29 Dec 2021 14:51:33 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A76293AD4ED;
	Wed, 29 Dec 2021 06:51:32 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CA6FC3AD371
 for <lustre-devel@lists.lustre.org>; Wed, 29 Dec 2021 06:51:29 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 7CC871006F01;
 Wed, 29 Dec 2021 09:51:28 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 72270D9E6B; Wed, 29 Dec 2021 09:51:28 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed, 29 Dec 2021 09:51:14 -0500
Message-Id: <1640789487-22279-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/13] lustre: port OpenSFS updates Dec 29,
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

Port the latest OpenSFS work to the Linux client as of Dec 29,
2021

Alexander Boyko (1):
  lustre: mdc: add client tunable to disable LSOM update

Alexey Lyashkov (1):
  lustre: ptlrpc: use a cached value

Arshad Hussain (1):
  lustre: quota: fallocate send UID/GID for quota

Chris Horn (2):
  lnet: Revert "lnet: Lock primary NID logic"
  lnet: Race on discovery queue

James Simmons (1):
  lnet: o2iblnd: convert ibp_refcount to a kref

Lai Siyao (1):
  lustre: dne: dir migration in non-recursive mode

Oleg Drokin (1):
  lustre: update version to 2.14.56

Qian Yingjin (1):
  lustre: llite: set ra_pages of backing_dev_info with 0

Sebastien Buisson (3):
  lustre: sec: filename encryption - digest support
  lustre: sec: no encryption key migrate/extend/resync/split
  lustre: sec: fix handling of encrypted file with long name

Serguei Smirnov (1):
  lnet: socklnd: expect two control connections maximum

 fs/lustre/include/cl_object.h           |   2 +
 fs/lustre/include/lustre_net.h          |   2 +-
 fs/lustre/include/obd.h                 |   4 +-
 fs/lustre/llite/crypto.c                | 175 +++++++++++++++++++++++++++-----
 fs/lustre/llite/dir.c                   |  20 +++-
 fs/lustre/llite/file.c                  |  66 ++++++++----
 fs/lustre/llite/llite_internal.h        |  25 ++++-
 fs/lustre/llite/llite_lib.c             | 127 +++++++++++++++++++++--
 fs/lustre/llite/namei.c                 |  83 ++++++++-------
 fs/lustre/llite/rw26.c                  |   2 +-
 fs/lustre/llite/statahead.c             |   8 +-
 fs/lustre/llite/vvp_io.c                |   3 -
 fs/lustre/llite/xattr.c                 |   4 +-
 fs/lustre/lmv/lmv_obd.c                 |   5 +
 fs/lustre/lov/lov_io.c                  |   4 +
 fs/lustre/mdc/lproc_mdc.c               |  29 ++++++
 fs/lustre/mdc/mdc_lib.c                 |   2 +
 fs/lustre/mdc/mdc_locks.c               |   8 +-
 fs/lustre/mdc/mdc_request.c             |  13 ++-
 fs/lustre/osc/osc_io.c                  |   8 +-
 fs/lustre/osc/osc_request.c             |  42 ++++++--
 fs/lustre/ptlrpc/pack_generic.c         |   8 +-
 fs/lustre/ptlrpc/ptlrpc_internal.h      |   1 +
 fs/lustre/ptlrpc/ptlrpc_module.c        |   1 +
 fs/lustre/ptlrpc/sec_null.c             |   4 +-
 fs/lustre/ptlrpc/sec_plain.c            |   2 +-
 fs/lustre/ptlrpc/wiretest.c             |   6 ++
 include/uapi/linux/lustre/lustre_idl.h  |  16 ++-
 include/uapi/linux/lustre/lustre_user.h |   7 +-
 include/uapi/linux/lustre/lustre_ver.h  |   4 +-
 net/lnet/klnds/o2iblnd/o2iblnd.c        |  11 +-
 net/lnet/klnds/o2iblnd/o2iblnd.h        |  35 ++++---
 net/lnet/klnds/socklnd/socklnd.h        |   2 +-
 net/lnet/lnet/peer.c                    | 114 +++++++--------------
 34 files changed, 607 insertions(+), 236 deletions(-)

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
