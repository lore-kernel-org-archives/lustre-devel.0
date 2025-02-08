Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A2EB6C02199
	for <lustre-devel@archiver.kernel.org>; Sat,  8 Feb 2025 00:30:46 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YqWw10Kr3z1xJ0;
	Fri, 07 Feb 2025 16:30:41 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YqWvv4PWfz1x3n
 for <lustre-devel@lists.lustre.org>; Fri, 07 Feb 2025 16:30:35 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm2-e204-208.ccs.ornl.gov [160.91.203.3])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id E2D6417D1DE;
 Fri,  7 Feb 2025 19:30:32 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id D583B106BE14; Fri,  7 Feb 2025 19:30:32 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri,  7 Feb 2025 19:30:06 -0500
Message-ID: <20250208003027.180076-1-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 00/21] lustre: sync to OpenSFS branch June 28, 2023
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

Port the work done during the month of June on the OpenSFS tree
to the native client.

Arshad Hussain (1):
  lustre: llite: Fix style issues for dir.c

Bobi Jam (1):
  lustre: csdc: reserve connect bits for compressed layout

Chris Horn (1):
  lnet: udsp: lnetctl udsp improvements

Frank Sehr (1):
  lnet: report actual timeout used by lnd

James Simmons (1):
  lustre: llite: make lsm_sem nested for ll_update_dir_depth

Lai Siyao (1):
  lustre: llite: implicit default LMV inherit

Mr NeilBrown (1):
  lnet: libcfs: move percpt_lock into lnet

Oleg Drokin (2):
  lustre: osc: Ensure there's no eviction with long cache discard
  lustre: update version to 2.15.56

Patrick Farrell (3):
  lustre: osc: Don't include lock for srvlock
  lustre: clio: Trivial DIO cleanups
  lustre: osc: Add debug

Sebastien Buisson (1):
  lustre: gss: fix ptlrpc_gss automatic loading

Serguei Smirnov (3):
  lnet: socklnd: remove ksnr_myiface from ksock_conn_cb
  lnet: fix locking multiple NIDs of the MR peer
  lnet: ensure dev notification on lnd startup

Timothy Day (5):
  lustre: ptlrpc: replace OBD_ -> CFS_ macros
  lustre: misc: remove OBD_ -> CFS_ macros
  lustre: osc: remove OBD_ -> CFS_ macros
  lnet: libcfs: add unlikely to CFS_ macros
  lustre: misc: fix clang build errors

 fs/lustre/fid/fid_request.c                   |   2 +-
 fs/lustre/fld/fld_request.c                   |   2 +-
 fs/lustre/include/lustre_lmv.h                |  64 ++-
 fs/lustre/include/obd_support.h               |   1 +
 fs/lustre/llite/dcache.c                      |  11 +-
 fs/lustre/llite/dir.c                         | 372 +++++++++---------
 fs/lustre/llite/file.c                        |   9 +-
 fs/lustre/llite/llite_internal.h              |   9 +-
 fs/lustre/llite/llite_lib.c                   | 163 +++++++-
 fs/lustre/llite/llite_nfs.c                   |   2 +-
 fs/lustre/llite/namei.c                       |  58 ++-
 fs/lustre/llite/rw.c                          |   2 +-
 fs/lustre/llite/statahead.c                   |   6 +-
 fs/lustre/llite/vvp_page.c                    |   2 +-
 fs/lustre/mdc/mdc_lib.c                       |   7 +
 fs/lustre/mgc/mgc_request.c                   |   3 +-
 fs/lustre/obdclass/cl_io.c                    |  13 +-
 fs/lustre/obdclass/genops.c                   |   8 +-
 fs/lustre/obdclass/lprocfs_status.c           |   4 +-
 fs/lustre/osc/osc_cache.c                     |   5 +-
 fs/lustre/osc/osc_io.c                        |   2 +-
 fs/lustre/osc/osc_lock.c                      |  10 +-
 fs/lustre/osc/osc_object.c                    |  20 +-
 fs/lustre/osc/osc_page.c                      |   8 +-
 fs/lustre/osc/osc_request.c                   |  39 +-
 fs/lustre/ptlrpc/client.c                     |  20 +-
 fs/lustre/ptlrpc/import.c                     |  12 +-
 fs/lustre/ptlrpc/niobuf.c                     |  21 +-
 fs/lustre/ptlrpc/pack_generic.c               |   6 +-
 fs/lustre/ptlrpc/pinger.c                     |   2 +-
 fs/lustre/ptlrpc/ptlrpcd.c                    |   2 +-
 fs/lustre/ptlrpc/recover.c                    |   4 +-
 fs/lustre/ptlrpc/sec.c                        |  32 +-
 fs/lustre/ptlrpc/sec_plain.c                  |   4 +-
 fs/lustre/ptlrpc/service.c                    |  16 +-
 fs/lustre/ptlrpc/wiretest.c                   |  15 +-
 include/linux/libcfs/libcfs_cpu.h             |  62 ---
 include/linux/libcfs/libcfs_fail.h            |  66 ++--
 include/linux/lnet/lib-lnet.h                 |   5 +-
 include/linux/lnet/lib-types.h                |   3 +
 include/linux/lnet/lock.h                     |  64 +++
 include/uapi/linux/lnet/libcfs_ioctl.h        |   3 +-
 include/uapi/linux/lnet/lnet-dlc.h            |   2 +
 include/uapi/linux/lustre/lustre_idl.h        |   6 +-
 include/uapi/linux/lustre/lustre_user.h       |   6 +-
 include/uapi/linux/lustre/lustre_ver.h        |   4 +-
 net/lnet/klnds/o2iblnd/o2iblnd.c              |  76 ++--
 net/lnet/klnds/o2iblnd/o2iblnd_modparams.c    |   2 +
 net/lnet/klnds/socklnd/socklnd.c              | 145 +++----
 net/lnet/klnds/socklnd/socklnd.h              |   1 -
 net/lnet/klnds/socklnd/socklnd_cb.c           |   4 +-
 net/lnet/klnds/socklnd/socklnd_modparams.c    |   2 +
 net/lnet/libcfs/Makefile                      |   2 +-
 net/lnet/lnet/Makefile                        |   9 +-
 net/lnet/lnet/api-ni.c                        |  30 +-
 net/lnet/lnet/config.c                        |  32 ++
 .../{libcfs/libcfs_lock.c => lnet/lock.c}     |   5 +-
 net/lnet/lnet/peer.c                          |  59 ++-
 net/lnet/lnet/udsp.c                          |   3 +
 59 files changed, 913 insertions(+), 634 deletions(-)
 create mode 100644 include/linux/lnet/lock.h
 rename net/lnet/{libcfs/libcfs_lock.c => lnet/lock.c} (96%)

-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
