Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id BE6D7C77B70
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:13:52 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWGh1CXXz1y6F;
	Sun,  9 Apr 2023 05:13:32 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWGd12JGz1wY2
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:13:29 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C53B31008269;
 Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B456E2AB; Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:12:40 -0400
Message-Id: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/40] lustre: backport OpenSFS changes from
 March XX, 2023
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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

Merge in the patches landed to the OpenSFS tree.

Alex Deiter (1):
  lustre: enc: file names encryption when using secure boot

Amir Shehata (2):
  lnet: Lock primary NID logic
  lnet: don't delete peer created by Lustre

Andreas Dilger (1):
  lustre: tgt: skip free inodes in OST weights

Andrew Perepechko (2):
  lustre: lov: fiemap improperly handles fm_extent_count=0
  lustre: llite: SIGBUS is possible on a race with page reclaim

Andriy Skulysh (1):
  lustre: osc: page fault in osc_release_bounce_pages()

Aurelien Degremont (2):
  lustre: llite: fix relatime support
  lustre: ptlrpc: clarify AT error message

Chris Horn (3):
  lnet: Peers added via kernel API should be permanent
  lnet: memory leak in copy_ioc_udsp_descr
  lnet: lnet_parse_route uses wrong loop var

Cyril Bordage (2):
  lnet: o2iblnd: Fix key mismatch issue
  lnet: remove crash with UDSP

Etienne AUJAMES (1):
  lustre: llog: fix processing of a wrapped catalog

Hongchao Zhang (1):
  lustre: quota: fix insane grant quota

James Simmons (1):
  lustre: llite: replace lld_nfs_dentry flag with opencache handling

Lai Siyao (2):
  lustre: llite: match lock in corresponding namespace
  lustre: uapi: add DMV_IMP_INHERIT connect flag

Li Dongyang (1):
  lustre: fid: clean up OBIF_MAX_OID and IDIF_MAX_OID

Mikhail Pershin (1):
  lustre: client: -o network needs add_conn processing

Mr NeilBrown (1):
  lustre: ldlm: remove client_import_find_conn()

Oleg Drokin (1):
  lustre: update version to 2.15.54

Patrick Farrell (1):
  lustre: clio: Remove cl_page_size()

Qian Yingjin (4):
  lustre: protocol: basic batching processing framework
  lustre: readahead: add stats for read-ahead page count
  lustre: llite: check truncated page in ->readpage()
  lustre: llite: check read page past requested

Sebastien Buisson (4):
  lustre: enc: align Base64 encoding with RFC 4648 base64url
  lustre: sec: fid2path for encrypted files
  lustre: sec: Lustre/HSM on enc file with enc key
  lustre: fileset: check fileset for operations by fid

Sergey Cheremencev (2):
  lustre: quota: enforce project quota for root
  lustre: tgt: add qos debug

Serguei Smirnov (1):
  lnet: add 'force' option to lnetctl peer del

Timothy Day (2):
  lnet: libcfs: remove unused hash code
  lustre: ptlrpc: fix clang build errors

Vitaly Fertman (2):
  lustre: ldlm: BL_AST lock cancel still can be batched
  lustre: llite: dir layout inheritance fixes

Yang Sheng (1):
  lustre: ldlm: send the cancel RPC asap

 fs/lustre/include/cl_object.h            |   1 -
 fs/lustre/include/lu_object.h            |  14 +-
 fs/lustre/include/lustre_crypto.h        |   3 +
 fs/lustre/include/lustre_disk.h          |   3 +-
 fs/lustre/include/lustre_export.h        |   5 +
 fs/lustre/include/lustre_fid.h           |   6 +-
 fs/lustre/include/lustre_import.h        |   1 +
 fs/lustre/include/lustre_log.h           |  16 +
 fs/lustre/include/lustre_net.h           |  45 ++-
 fs/lustre/include/lustre_nrs.h           |  11 +-
 fs/lustre/include/lustre_nrs_delay.h     |  14 +-
 fs/lustre/include/lustre_req_layout.h    |  28 +-
 fs/lustre/include/lustre_swab.h          |   3 +
 fs/lustre/include/obd.h                  |  86 ++++-
 fs/lustre/include/obd_class.h            |  48 +++
 fs/lustre/include/obd_support.h          |   7 +-
 fs/lustre/ldlm/ldlm_lib.c                |  44 +--
 fs/lustre/ldlm/ldlm_lockd.c              |   8 +-
 fs/lustre/ldlm/ldlm_request.c            | 122 +++++--
 fs/lustre/llite/crypto.c                 |  35 +-
 fs/lustre/llite/dir.c                    | 122 +++++--
 fs/lustre/llite/file.c                   | 262 ++++++++++++--
 fs/lustre/llite/llite_internal.h         |  44 ++-
 fs/lustre/llite/llite_lib.c              |  10 +-
 fs/lustre/llite/llite_mmap.c             |  19 +
 fs/lustre/llite/llite_nfs.c              |  15 +-
 fs/lustre/llite/lproc_llite.c            |  65 +++-
 fs/lustre/llite/namei.c                  |  25 +-
 fs/lustre/llite/rw.c                     | 105 +++++-
 fs/lustre/llite/rw26.c                   |  16 +-
 fs/lustre/llite/super25.c                |   2 +
 fs/lustre/llite/vvp_io.c                 |  12 +-
 fs/lustre/llite/vvp_page.c               |  37 ++
 fs/lustre/lmv/lmv_internal.h             |  12 +
 fs/lustre/lmv/lmv_obd.c                  | 267 ++++++++++++--
 fs/lustre/lov/lov_object.c               |   7 +-
 fs/lustre/lov/lov_page.c                 |   2 +-
 fs/lustre/mdc/Makefile                   |   2 +-
 fs/lustre/mdc/mdc_batch.c                |  62 ++++
 fs/lustre/mdc/mdc_internal.h             |   3 +
 fs/lustre/mdc/mdc_request.c              |  14 +-
 fs/lustre/obdclass/cl_page.c             |  24 --
 fs/lustre/obdclass/llog.c                |  21 +-
 fs/lustre/obdclass/llog_cat.c            | 128 ++++---
 fs/lustre/obdclass/lu_tgt_descs.c        |  52 +--
 fs/lustre/obdclass/obd_config.c          |  17 -
 fs/lustre/osc/osc_cache.c                |   2 +-
 fs/lustre/osc/osc_quota.c                |   1 +
 fs/lustre/osc/osc_request.c              |   3 +
 fs/lustre/ptlrpc/Makefile                |   2 +-
 fs/lustre/ptlrpc/batch.c                 | 588 +++++++++++++++++++++++++++++++
 fs/lustre/ptlrpc/client.c                |  25 ++
 fs/lustre/ptlrpc/layout.c                | 126 ++++++-
 fs/lustre/ptlrpc/lproc_ptlrpc.c          |   1 +
 fs/lustre/ptlrpc/nrs_delay.c             |   2 +-
 fs/lustre/ptlrpc/pack_generic.c          |  27 +-
 fs/lustre/ptlrpc/sec_config.c            |   2 +-
 fs/lustre/ptlrpc/service.c               |  11 +-
 fs/lustre/ptlrpc/wiretest.c              |  14 +-
 include/linux/libcfs/libcfs_hash.h       |  18 -
 include/linux/lnet/lib-lnet.h            |   7 +-
 include/uapi/linux/lnet/lnet-dlc.h       |   4 +-
 include/uapi/linux/lustre/lustre_idl.h   |  96 ++++-
 include/uapi/linux/lustre/lustre_ostid.h |   4 +-
 include/uapi/linux/lustre/lustre_user.h  |   1 +
 include/uapi/linux/lustre/lustre_ver.h   |   4 +-
 net/lnet/klnds/o2iblnd/o2iblnd.c         |   5 +-
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c      |  17 +-
 net/lnet/lnet/api-ni.c                   |   6 +-
 net/lnet/lnet/config.c                   |   2 +-
 net/lnet/lnet/peer.c                     | 191 +++++++---
 net/lnet/lnet/udsp.c                     |  36 +-
 72 files changed, 2526 insertions(+), 514 deletions(-)
 create mode 100644 fs/lustre/mdc/mdc_batch.c
 create mode 100644 fs/lustre/ptlrpc/batch.c

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
