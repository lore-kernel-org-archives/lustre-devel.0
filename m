Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 0F3D0C433FE
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Jan 2022 01:38:08 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 586C43B4792;
	Thu, 13 Jan 2022 17:38:08 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 85E6921FF8F
 for <lustre-devel@lists.lustre.org>; Thu, 13 Jan 2022 17:38:06 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id A555B10087C4;
 Thu, 13 Jan 2022 20:38:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 96281A8102; Thu, 13 Jan 2022 20:38:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 13 Jan 2022 20:37:39 -0500
Message-Id: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/24] lustre: update to OpenSFS Jan 13, 2022
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

Update native Linux lustre client with backport of the OpenSFS
work as of Jan 13, 2022

Alexander Zarochentsev (2):
  lustre: ptlrpc: make rq_replied flag always correct
  lustre: mgc: do not ignore target registration failure

Alexey Lyashkov (2):
  lustre: osc: don't have extra gpu call
  lnet: o2iblnd: cleanup

Andreas Dilger (1):
  lustre: mdc: GET(X)ATTR to READPAGE portal

Chris Horn (1):
  lnet: Skip router discovery on send path

Etienne AUJAMES (1):
  lnet: libcfs: set x->ls_len to 0 when x->ls_str is NULL

James Simmons (1):
  lustre: llite: make foreign symlinks aware of mount namespaces

Lai Siyao (4):
  lustre: lmv: set default LMV for "lfs mkdir -c 1"
  lustre: lmv: improve MDT QOS space balance
  lustre: llite: access striped directory with missing stripe
  lustre: llite: revalidate dentry if LOOKUP lock fetched

Lei Feng (1):
  lustre: uapi: set default max-inherit to 3

Li Dongyang (1):
  lustre: llite: add trusted.projid virtual xattr

Patrick Farrell (8):
  lustre: lov: Cache stripe offset calculation
  lnet: libcfs: Remove D_TTY
  lustre: llite: Add D_IOTRACE
  lustre: llite: Add start_idx debug
  lustre: llite: Switch pcc to lookup_one_len
  lustre: llite: Simplify cda_no_aio_complete use
  lustre: osc: Always set aio in anchor
  lustre: llite: Implement lower/upper aio

Serguei Smirnov (2):
  lnet: o2iblnd: treat cmid->device == NULL as an error
  lnet: socklnd: decrement connection counters on close

 fs/lustre/include/cl_object.h           |   7 +-
 fs/lustre/include/obd.h                 |   9 ++-
 fs/lustre/include/obd_class.h           |   7 +-
 fs/lustre/llite/dcache.c                |  19 ++++-
 fs/lustre/llite/dir.c                   |  45 ++++++++---
 fs/lustre/llite/file.c                  |  16 +++-
 fs/lustre/llite/llite_foreign_symlink.c |   8 +-
 fs/lustre/llite/llite_internal.h        |  14 +++-
 fs/lustre/llite/llite_lib.c             |   7 +-
 fs/lustre/llite/llite_mmap.c            |  13 +++-
 fs/lustre/llite/llite_nfs.c             |   2 +-
 fs/lustre/llite/namei.c                 |   6 +-
 fs/lustre/llite/pcc.c                   | 119 +++++++++++++++++++---------
 fs/lustre/llite/rw.c                    |  31 +++++---
 fs/lustre/llite/rw26.c                  |  34 ++++++--
 fs/lustre/llite/statahead.c             |   6 +-
 fs/lustre/llite/xattr.c                 |  15 ++++
 fs/lustre/llite/xattr_cache.c           |  15 ++++
 fs/lustre/lmv/lmv_intent.c              |   4 +-
 fs/lustre/lmv/lmv_obd.c                 | 133 ++++++++++++++++++--------------
 fs/lustre/lov/lov_cl_internal.h         |   9 ++-
 fs/lustre/lov/lov_io.c                  |   6 ++
 fs/lustre/lov/lov_page.c                |  57 ++++++++++----
 fs/lustre/mdc/mdc_request.c             |  14 +++-
 fs/lustre/mgc/mgc_request.c             |   5 +-
 fs/lustre/obdclass/cl_io.c              |  56 ++++++++++----
 fs/lustre/osc/osc_request.c             |   2 +-
 fs/lustre/ptlrpc/ptlrpc_internal.h      |   1 +
 include/uapi/linux/lnet/libcfs_debug.h  |   4 +-
 include/uapi/linux/lustre/lustre_idl.h  |   1 +
 include/uapi/linux/lustre/lustre_user.h |  16 ++--
 net/lnet/klnds/o2iblnd/o2iblnd.c        |  15 ++--
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c     |  43 ++++-------
 net/lnet/klnds/socklnd/socklnd.c        |  69 ++++++++++++++---
 net/lnet/libcfs/libcfs_string.c         |   1 +
 net/lnet/libcfs/tracefile.c             |  51 +-----------
 net/lnet/lnet/lib-move.c                |  23 ++++--
 37 files changed, 582 insertions(+), 301 deletions(-)

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
