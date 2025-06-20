Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 3FD08C83030
	for <lustre-devel@archiver.kernel.org>; Mon, 30 Jun 2025 23:48:10 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4bWNBl0pjcz1xnq;
	Mon, 30 Jun 2025 16:47:59 -0700 (PDT)
Received: from mail-wr1-f49.google.com (mail-wr1-f49.google.com
 [209.85.221.49])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4bP7YP1Mp6z1wZ5
 for <lustre-devel@lists.lustre.org>; Fri, 20 Jun 2025 12:57:29 -0700 (PDT)
Received: by mail-wr1-f49.google.com with SMTP id
 ffacd0b85a97d-3a4e57d018cso347291f8f.1
 for <lustre-devel@lists.lustre.org>; Fri, 20 Jun 2025 12:57:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1750449446; x=1751054246; darn=lists.lustre.org;
 h=content-transfer-encoding:mime-version:references:in-reply-to
 :message-id:date:subject:cc:to:from:from:to:cc:subject:date
 :message-id:reply-to;
 bh=Lz0qCA8GcSzGSxbulpZ/xb61NH/l2Bo/NAWAqNL3zbM=;
 b=KcndcbVuQ82yluLpF5kE2u0G85muLs7zkYC52+xJCTRcsJDCx3aSAPmKam10IjrKRr
 3OjJE3O8qRpaUieSSa9SPc+hnZGzZZnlrlEbSR9uq5WxCsVbXFH/z+6FqYTlsgL5hQUg
 3xHJtm9f/Ffy/AwKIvKQE6s/feWphHq6BaC5PbXtmmgqXRmykD/2mFI01I7PeYZBzXw4
 UoWlF9UxdS7Ph7pu/vKYnHiuOsMiYDlCbpZuHOmV4iT0x07hdi53uJM7ALm5Pb6LgA8b
 pH6OM4OAEocpT2MRlVdG2hpR52xoOjql3RtS8tPah985J4R0fs8uillMSfMxO5KPCrTU
 3obw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1750449446; x=1751054246;
 h=content-transfer-encoding:mime-version:references:in-reply-to
 :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
 :subject:date:message-id:reply-to;
 bh=Lz0qCA8GcSzGSxbulpZ/xb61NH/l2Bo/NAWAqNL3zbM=;
 b=LU5ZfOTu93Uy0m5vAKAkf+rYeVILXKGGbd1G+xXyVPjiuhsi74TAj1sR/wvpcWG0q0
 xkN8yKiPA9+lwDo9WXfIi4f/sNsgem4423wb7WMK81Z8HWyXntbdVbjxzizKJvOkXFlk
 Yhq1pWkJJXysWmNs53jqXcyONxGQG9udKVe8zXR/RiqX1iSzMcUB0FYXiF8UGp0/lvsJ
 7edilUnUO10HkRVRXtph3janXluCujJSlxnKoo3cqOYCd27uT4h1R409zfrucCUlABNH
 agqGdR2WX6N2opptC4OUcIYrbAPgHZInOPvTsFeO5GNlBmYy7HxhBX92LJhwiobkri5C
 SENA==
X-Forwarded-Encrypted: i=1;
 AJvYcCVuGMcV7YfbDAmUIamPA8d8TYdYtJWzqukR0oRGwkVcn3b7K74UDpMxtR/hwDw+4wgz/nNRLwYWJqKAtLM=@lists.lustre.org
X-Gm-Message-State: AOJu0YwXRFNF0ceHmQxrH41Pu42iAPFVXOXBjnBLvyeuZPe7KxV4lBAc
 TqiKWtfugcVY57LKxtjrI3rF60ABPbTF/b1oplmDFsnhxby18zKJ6pUKNlGSpYUVuA==
X-Gm-Gg: ASbGncs524W071yanfc6I6sBQ49DHoN2KUkaJC/5u5oVovv/hvz7pY2OAiOaMk7gSj6
 e6u4d9LyZK8BUHbTcFjYjUaAU7zNlK7SDLP9hzeCNmNazMGhGKr+pBqYbxHRVawEUSFi4kC6xZg
 Vk1lVRiurq5SIq/hUAqgxRUI9VOq6tqsNmu5wuVz3TBe/T4jJS/JYbiIX6Wh9oSjk9t+J2gJgVH
 pjLhHttv/PtxTVaOjPQ+S2sSj5eg8leteo1TWWygSZHOhk7JfIiHrxjWCz8pPpfRnwwRmxzlWs4
 1EPsNqkXN4q69AiPnOL+OWRSvbAJCKFH1FPoYlZuKoD6vGJ1fPzr+i0HY69zGAoseMK2e/OXj9N
 /8kSX8hxLv1vMgdmDfMc25U/JjA==
X-Google-Smtp-Source: AGHT+IFDBpWBgJ4ugDaE+TjvvJcGO71yR1WcfjYpCJSMCunwVZ2W3hVGE+1KvgJ5cSl2Otn00hcF1Q==
X-Received: by 2002:a05:600c:c4ac:b0:441:c5ee:cdb4 with SMTP id
 5b1f17b1804b1-453659b8acemr15296985e9.4.1750449444249; 
 Fri, 20 Jun 2025 12:57:24 -0700 (PDT)
Received: from localhost (220.red-80-39-44.staticip.rima-tde.net.
 [80.39.44.220]) by smtp.gmail.com with ESMTPSA id
 5b1f17b1804b1-453646d7fe5sm34017705e9.16.2025.06.20.12.57.23
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Fri, 20 Jun 2025 12:57:23 -0700 (PDT)
From: Xose Vazquez Perez <xose.vazquez@gmail.com>
To: 
Cc: Xose Vazquez Perez <xose.vazquez@gmail.com>,
 LUSTRE DEVEL ML <lustre-devel@lists.lustre.org>
Date: Fri, 20 Jun 2025 21:57:19 +0200
Message-ID: <20250620195720.59870-2-xose.vazquez@gmail.com>
X-Mailer: git-send-email 2.49.0
In-Reply-To: <20250620195720.59870-1-xose.vazquez@gmail.com>
References: <20250620195720.59870-1-xose.vazquez@gmail.com>
MIME-Version: 1.0
X-Patchwork-Bot: notify
X-Mailman-Approved-At: Mon, 30 Jun 2025 16:47:47 -0700
Subject: [lustre-devel] [PATCH 2/2] lustre: replace FSF licences boilerplate
 with a SPDX-License-Identifier
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

Just that.

Cc: LUSTRE DEVEL ML <lustre-devel@lists.lustre.org>
Signed-off-by: Xose Vazquez Perez <xose.vazquez@gmail.com>
---
 config/ac_pkg_swig.m4                    | 14 +------------
 config/ac_python_devel.m4                | 14 +------------
 contrib/scripts/gerrit_checkpatch.py     | 21 +------------------
 contrib/scripts/lioprof/README           | 10 +--------
 contrib/scripts/lioprof/launcher.sh      | 13 +-----------
 contrib/scripts/lioprof/parser.sh        | 13 +-----------
 lustre/autoMakefile.am                   | 22 +-------------------
 lustre/conf/Makefile.am                  | 22 +-------------------
 lustre/conf/resource/Lustre              | 10 +--------
 lustre/conf/resource/Makefile.am         | 22 +-------------------
 lustre/conf/resource/healthLNET          | 23 +--------------------
 lustre/conf/resource/healthLUSTRE        | 23 +--------------------
 lustre/doc/Makefile.am                   | 22 +-------------------
 lustre/ec/autoMakefile.am                | 22 +-------------------
 lustre/lov/lov_page.c                    | 22 +-------------------
 lustre/scripts/Makefile.am               | 22 +-------------------
 lustre/scripts/zfsobj2fid                | 13 +-----------
 lustre/tests/aheadmany.c                 | 22 +-------------------
 lustre/tests/badarea_io.c                | 22 +-------------------
 lustre/tests/check_fallocate.c           | 21 +------------------
 lustre/tests/check_fhandle_syscalls.c    | 21 +------------------
 lustre/tests/checkfiemap.c               | 23 +--------------------
 lustre/tests/checkstat.c                 | 22 +-------------------
 lustre/tests/chownmany.c                 | 22 +-------------------
 lustre/tests/clientapi/simple_test.c     | 22 +-------------------
 lustre/tests/createmany.c                | 22 +-------------------
 lustre/tests/createtest.c                | 22 +-------------------
 lustre/tests/directio.c                  | 22 +-------------------
 lustre/tests/euid_access.c               | 22 +-------------------
 lustre/tests/flock_deadlock.c            | 24 +---------------------
 lustre/tests/flocks_test.c               | 22 +-------------------
 lustre/tests/group_lock_test.c           | 22 +-------------------
 lustre/tests/io_uring_probe.c            | 19 +----------------
 lustre/tests/kbuild                      | 15 +-------------
 lustre/tests/listxattr_size_check.c      | 21 +------------------
 lustre/tests/ll_dirstripe_verify.c       | 22 +-------------------
 lustre/tests/ll_sparseness_verify.c      | 22 +-------------------
 lustre/tests/ll_sparseness_write.c       | 22 +-------------------
 lustre/tests/llapi_fid_test.c            | 22 +-------------------
 lustre/tests/llapi_root_test.c           | 22 +-------------------
 lustre/tests/lockahead_test.c            | 22 +-------------------
 lustre/tests/lov_getstripe_old.c         | 22 +-------------------
 lustre/tests/lseek_test.c                | 21 +------------------
 lustre/tests/mcreate.c                   | 22 +-------------------
 lustre/tests/memhog.c                    | 22 +-------------------
 lustre/tests/mirror_io.c                 | 26 +-----------------------
 lustre/tests/mmap_cat.c                  | 22 +-------------------
 lustre/tests/mmap_mknod_test.c           | 22 +-------------------
 lustre/tests/mmap_sanity.c               | 22 +-------------------
 lustre/tests/mpi/cascading_rw.c          | 22 +-------------------
 lustre/tests/mpi/createmany-mpi.c        | 22 +-------------------
 lustre/tests/mpi/lp_utils.c              | 22 +-------------------
 lustre/tests/mpi/lp_utils.h              | 22 +-------------------
 lustre/tests/mpi/parallel_grouplock.c    | 22 +-------------------
 lustre/tests/mpi/rr_alloc.c              | 25 +----------------------
 lustre/tests/mpi/write_append_truncate.c | 22 +-------------------
 lustre/tests/mpi/write_disjoint.c        | 22 +-------------------
 lustre/tests/mrename.c                   | 22 +-------------------
 lustre/tests/multifstat.c                | 22 +-------------------
 lustre/tests/multiop.c                   | 22 +-------------------
 lustre/tests/opendevunlink.c             | 22 +-------------------
 lustre/tests/opendirunlink.c             | 22 +-------------------
 lustre/tests/openfile.c                  | 22 +-------------------
 lustre/tests/openfilleddirunlink.c       | 22 +-------------------
 lustre/tests/openunlink.c                | 22 +-------------------
 lustre/tests/orphan_linkea_check.c       | 22 +-------------------
 lustre/tests/reads.c                     | 22 +-------------------
 lustre/tests/rename_many.c               | 22 +-------------------
 lustre/tests/runas.c                     | 22 +-------------------
 lustre/tests/rwv.c                       | 23 +--------------------
 lustre/tests/sendfile.c                  | 22 +-------------------
 lustre/tests/sendfile_grouplock.c        | 22 +-------------------
 lustre/tests/small_write.c               | 22 +-------------------
 lustre/tests/smalliomany.c               | 26 +-----------------------
 lustre/tests/statmany.c                  | 22 +-------------------
 lustre/tests/statone.c                   | 22 +-------------------
 lustre/tests/statx.c                     | 19 +----------------
 lustre/tests/swap_lock_test.c            | 22 +-------------------
 lustre/tests/tchmod.c                    | 22 +-------------------
 lustre/tests/test_brw.c                  | 22 +-------------------
 lustre/tests/truncate.c                  | 22 +-------------------
 lustre/tests/unlinkmany.c                | 22 +-------------------
 lustre/tests/utime.c                     | 22 +-------------------
 lustre/tests/write_time_limit.c          | 22 +-------------------
 lustre/tests/writemany.c                 | 22 +-------------------
 lustre/tests/writeme.c                   | 22 +-------------------
 lustre/utils/callvpe.c                   | 20 +-----------------
 lustre/utils/callvpe.h                   | 20 +-----------------
 lustre/utils/check_iam.c                 | 22 +-------------------
 lustre/utils/debug.c                     | 22 +-------------------
 lustre/utils/gss/lgss_keyring.c          | 22 +-------------------
 lustre/utils/gss/lgss_null_utils.c       | 22 +-------------------
 lustre/utils/gss/lgss_sk.c               | 22 +-------------------
 lustre/utils/gss/lgss_sk_utils.c         | 22 +-------------------
 lustre/utils/gss/lsupport.c              | 22 +-------------------
 lustre/utils/gss/lsupport.h              | 23 +--------------------
 lustre/utils/gss/sk_utils.c              | 22 +-------------------
 lustre/utils/gss/sk_utils.h              | 22 +-------------------
 lustre/utils/l_foreign_symlink.c         | 22 +-------------------
 lustre/utils/l_getidentity.c             | 22 +-------------------
 lustre/utils/l_getsepol.c                | 21 +------------------
 lustre/utils/l_tunedisk.c                | 22 +-------------------
 lustre/utils/lctl.c                      | 22 +-------------------
 lustre/utils/lctl_thread.c               | 22 +-------------------
 lustre/utils/lctl_thread.h               | 19 +----------------
 lustre/utils/lfs.c                       | 22 +-------------------
 lustre/utils/lfs_project.c               | 22 +-------------------
 lustre/utils/lfs_project.h               | 22 +-------------------
 lustre/utils/lhsmtool_posix.c            | 22 +-------------------
 lustre/utils/libhsm_scanner.c            | 22 +-------------------
 lustre/utils/libhsm_scanner.h            | 22 +-------------------
 lustre/utils/libiam.c                    | 22 +-------------------
 lustre/utils/libmount_utils_ldiskfs.c    | 22 +-------------------
 lustre/utils/libmount_utils_zfs.c        | 22 +-------------------
 lustre/utils/ll_decode_filter_fid.c      | 22 +-------------------
 lustre/utils/ll_decode_linkea.c          | 22 +-------------------
 lustre/utils/llog_reader.c               | 22 +-------------------
 lustre/utils/llsom_sync.c                | 22 +-------------------
 lustre/utils/llverdev.c                  | 22 +-------------------
 lustre/utils/lr_reader.c                 | 22 +-------------------
 lustre/utils/lshowmount.c                | 22 +-------------------
 lustre/utils/lsnapshot.c                 | 22 +-------------------
 lustre/utils/lustre_cfg.c                | 22 +-------------------
 lustre/utils/lustre_lfsck.c              | 22 +-------------------
 lustre/utils/lustre_param.c              | 22 +-------------------
 lustre/utils/lustre_rsync.c              | 22 +-------------------
 lustre/utils/lustre_rsync.h              | 22 +-------------------
 lustre/utils/lustreapi_internal.h        | 19 +----------------
 lustre/utils/mkfs_lustre.c               | 22 +-------------------
 lustre/utils/mount_lustre.c              | 22 +-------------------
 lustre/utils/mount_utils.c               | 22 +-------------------
 lustre/utils/mount_utils.h               | 22 +-------------------
 lustre/utils/nidlist.c                   | 22 +-------------------
 lustre/utils/nidlist.h                   | 22 +-------------------
 lustre/utils/obd.c                       | 22 +-------------------
 lustre/utils/obdctl.h                    | 22 +-------------------
 lustre/utils/ofd_access_batch.c          | 21 +------------------
 lustre/utils/ofd_access_log_reader.c     | 21 +------------------
 lustre/utils/pid_file.c                  | 20 +-----------------
 lustre/utils/pid_file.h                  | 20 +-----------------
 lustre/utils/portals.c                   | 15 +-------------
 lustre/utils/wirecheck.c                 | 22 +-------------------
 lustre/utils/wirehdr.c                   | 22 +-------------------
 lustre/utils/wiretest.c                  | 22 +-------------------
 144 files changed, 144 insertions(+), 2933 deletions(-)

diff --git a/config/ac_pkg_swig.m4 b/config/ac_pkg_swig.m4
index 6a60abce55..ad84f024de 100644
--- a/config/ac_pkg_swig.m4
+++ b/config/ac_pkg_swig.m4
@@ -1,3 +1,4 @@
+# SPDX-License-Identifier: GPL-2.0+
 # ===========================================================================
 #       https://www.gnu.org/software/autoconf-archive/ax_pkg_swig.html
 # ===========================================================================
@@ -37,19 +38,6 @@
 #   Copyright (c) 2008 Andrew Collier
 #   Copyright (c) 2011 Murray Cumming <murrayc@openismus.com>
 #
-#   This program is free software; you can redistribute it and/or modify it
-#   under the terms of the GNU General Public License as published by the
-#   Free Software Foundation; either version 2 of the License, or (at your
-#   option) any later version.
-#
-#   This program is distributed in the hope that it will be useful, but
-#   WITHOUT ANY WARRANTY; without even the implied warranty of
-#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
-#   Public License for more details.
-#
-#   You should have received a copy of the GNU General Public License along
-#   with this program. If not, see <https://www.gnu.org/licenses/>.
-#
 #   As a special exception, the respective Autoconf Macro's copyright owner
 #   gives unlimited permission to copy, distribute and modify the configure
 #   scripts that are the output of Autoconf when processing the Macro. You
diff --git a/config/ac_python_devel.m4 b/config/ac_python_devel.m4
index 935056cc4c..3b4e7948bf 100644
--- a/config/ac_python_devel.m4
+++ b/config/ac_python_devel.m4
@@ -1,3 +1,4 @@
+# SPDX-License-Identifier: GPL-3.0+
 # ===========================================================================
 #     https://www.gnu.org/software/autoconf-archive/ax_python_devel.html
 # ===========================================================================
@@ -46,19 +47,6 @@
 #   Copyright (c) 2009 Horst Knorr <hk_classes@knoda.org>
 #   Copyright (c) 2013 Daniel Mullner <muellner@math.stanford.edu>
 #
-#   This program is free software: you can redistribute it and/or modify it
-#   under the terms of the GNU General Public License as published by the
-#   Free Software Foundation, either version 3 of the License, or (at your
-#   option) any later version.
-#
-#   This program is distributed in the hope that it will be useful, but
-#   WITHOUT ANY WARRANTY; without even the implied warranty of
-#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
-#   Public License for more details.
-#
-#   You should have received a copy of the GNU General Public License along
-#   with this program. If not, see <https://www.gnu.org/licenses/>.
-#
 #   As a special exception, the respective Autoconf Macro's copyright owner
 #   gives unlimited permission to copy, distribute and modify the configure
 #   scripts that are the output of Autoconf when processing the Macro. You
diff --git a/contrib/scripts/gerrit_checkpatch.py b/contrib/scripts/gerrit_checkpatch.py
index 1563413abb..e156fe031c 100755
--- a/contrib/scripts/gerrit_checkpatch.py
+++ b/contrib/scripts/gerrit_checkpatch.py
@@ -1,24 +1,5 @@
 #!/usr/bin/env python3
-#
-# GPL HEADER START
-#
-# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
-#
-# This program is free software; you can redistribute it and/or modify
-# it under the terms of the GNU General Public License version 2 only,
-# as published by the Free Software Foundation.
-#
-# This program is distributed in the hope that it will be useful, but
-# WITHOUT ANY WARRANTY; without even the implied warranty of
-# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-# General Public License version 2 for more details (a copy is included
-# in the LICENSE file that accompanied this code).
-#
-# You should have received a copy of the GNU General Public License
-# version 2 along with this program; If not, see
-# http://www.gnu.org/licenses/gpl-2.0.html
-#
-# GPL HEADER END
+# SPDX-License-Identifier: GPL-2.0-only
 #
 # Copyright (c) 2014, Intel Corporation.
 #
diff --git a/contrib/scripts/lioprof/README b/contrib/scripts/lioprof/README
index ce1725e408..37ae890e19 100644
--- a/contrib/scripts/lioprof/README
+++ b/contrib/scripts/lioprof/README
@@ -1,18 +1,10 @@
+# SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
 # This file is provided under a dual BSD/GPLv2 license.  When using or
 # redistributing this file, you may do so under either license.
 #
-# GPL LICENSE SUMMARY
 #
 # Copyright(c) 2016 Intel Corporation.
 #
-# This program is free software; you can redistribute it and/or modify
-# it under the terms of version 2 of the GNU General Public License as
-# published by the Free Software Foundation.
-#
-# This program is distributed in the hope that it will be useful, but
-# WITHOUT ANY WARRANTY; without even the implied warranty of
-# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-# General Public License for more details.
 #
 # Contact Information:
 # Cong Xu, cong.xu@intel.com
diff --git a/contrib/scripts/lioprof/launcher.sh b/contrib/scripts/lioprof/launcher.sh
index 938b19acec..856564ed40 100755
--- a/contrib/scripts/lioprof/launcher.sh
+++ b/contrib/scripts/lioprof/launcher.sh
@@ -1,20 +1,9 @@
 #!/bin/bash
+# SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
 #
-# This file is provided under a dual BSD/GPLv2 license.  When using or
-# redistributing this file, you may do so under either license.
-#
-# GPL LICENSE SUMMARY
 #
 # Copyright(c) 2016 Intel Corporation.
 #
-# This program is free software; you can redistribute it and/or modify
-# it under the terms of version 2 of the GNU General Public License as
-# published by the Free Software Foundation.
-#
-# This program is distributed in the hope that it will be useful, but
-# WITHOUT ANY WARRANTY; without even the implied warranty of
-# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-# General Public License for more details.
 #
 # Contact Information:
 # Cong Xu, cong.xu@intel.com
diff --git a/contrib/scripts/lioprof/parser.sh b/contrib/scripts/lioprof/parser.sh
index 5eee9e346a..c7bedfc147 100755
--- a/contrib/scripts/lioprof/parser.sh
+++ b/contrib/scripts/lioprof/parser.sh
@@ -1,20 +1,9 @@
 #!/bin/bash
+# SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
 #
-# This file is provided under a dual BSD/GPLv2 license.  When using or
-# redistributing this file, you may do so under either license.
-#
-# GPL LICENSE SUMMARY
 #
 # Copyright(c) 2016 Intel Corporation.
 #
-# This program is free software; you can redistribute it and/or modify
-# it under the terms of version 2 of the GNU General Public License as
-# published by the Free Software Foundation.
-#
-# This program is distributed in the hope that it will be useful, but
-# WITHOUT ANY WARRANTY; without even the implied warranty of
-# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-# General Public License for more details.
 #
 # Contact Information:
 # Cong Xu, cong.xu@intel.com
diff --git a/lustre/autoMakefile.am b/lustre/autoMakefile.am
index 688fabdda4..51548c17f8 100644
--- a/lustre/autoMakefile.am
+++ b/lustre/autoMakefile.am
@@ -1,24 +1,4 @@
-#
-# GPL HEADER START
-#
-# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
-#
-# This program is free software; you can redistribute it and/or modify
-# it under the terms of the GNU General Public License version 2 only,
-# as published by the Free Software Foundation.
-#
-# This program is distributed in the hope that it will be useful, but
-# WITHOUT ANY WARRANTY; without even the implied warranty of
-# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-# General Public License version 2 for more details (a copy is included
-# in the LICENSE file that accompanied this code).
-#
-# You should have received a copy of the GNU General Public License
-# version 2 along with this program; If not, see
-# http://www.gnu.org/licenses/gpl-2.0.html
-#
-# GPL HEADER END
-#
+# SPDX-License-Identifier: GPL-2.0-only
 
 #
 # Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
diff --git a/lustre/conf/Makefile.am b/lustre/conf/Makefile.am
index 2708a04966..dde11330c6 100644
--- a/lustre/conf/Makefile.am
+++ b/lustre/conf/Makefile.am
@@ -1,24 +1,4 @@
-#
-# GPL HEADER START
-#
-# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
-#
-# This program is free software; you can redistribute it and/or modify
-# it under the terms of the GNU General Public License version 2 only,
-# as published by the Free Software Foundation.
-#
-# This program is distributed in the hope that it will be useful, but
-# WITHOUT ANY WARRANTY; without even the implied warranty of
-# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-# General Public License version 2 for more details (a copy is included
-# in the LICENSE file that accompanied this code).
-#
-# You should have received a copy of the GNU General Public License
-# version 2 along with this program; If not, see
-# http://www.gnu.org/licenses/gpl-2.0.html
-#
-# GPL HEADER END
-#
+# SPDX-License-Identifier: GPL-2.0-only
 
 #
 # Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
diff --git a/lustre/conf/resource/Lustre b/lustre/conf/resource/Lustre
index 6971a86180..7eb02346c9 100755
--- a/lustre/conf/resource/Lustre
+++ b/lustre/conf/resource/Lustre
@@ -1,20 +1,12 @@
 #!/bin/bash
+# SPDX-License-Identifier: GPL-2.0
 #
-# License:      GNU General Public License (GPL)v2
 # Description:  Manages Lustre server on a shared storage
 # Written by:   Gabriele Paciucci, Nathaniel Clark
 # Release Date: 28 February 2017
 # Release Version: 1.0.1
 # Copyright (c) 2017, Intel Corporation
 #
-# This program is free software; you can redistribute it and/or modify
-# it under the terms and conditions of the GNU General Public License,
-# version 2, as published by the Free Software Foundation.
-#
-# This program is distributed in the hope it will be useful, but
-# WITHOUT ANY WARRANTY; without even the implied warranty of
-# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
-# General Public License for more details.
 #
 #
 # usage: ./Lustre {start|stop|status|monitor|validate-all|meta-data}
diff --git a/lustre/conf/resource/Makefile.am b/lustre/conf/resource/Makefile.am
index aa5119d815..04b752d577 100644
--- a/lustre/conf/resource/Makefile.am
+++ b/lustre/conf/resource/Makefile.am
@@ -1,24 +1,4 @@
-#
-# GPL HEADER START
-#
-# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
-#
-# This program is free software; you can redistribute it and/or modify
-# it under the terms of the GNU General Public License version 2 only,
-# as published by the Free Software Foundation.
-#
-# This program is distributed in the hope that it will be useful, but
-# WITHOUT ANY WARRANTY; without even the implied warranty of
-# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-# General Public License version 2 for more details (a copy is included
-# in the LICENSE file that accompanied this code).
-#
-# You should have received a copy of the GNU General Public License
-# version 2 along with this program; If not, see
-# http://www.gnu.org/licenses/gpl-2.0.html
-#
-# GPL HEADER END
-#
+# SPDX-License-Identifier: GPL-2.0-only
 
 #
 # Copyright (c) 2018 Whamcloud
diff --git a/lustre/conf/resource/healthLNET b/lustre/conf/resource/healthLNET
index 8631478b6a..b45b9dc683 100755
--- a/lustre/conf/resource/healthLNET
+++ b/lustre/conf/resource/healthLNET
@@ -1,11 +1,11 @@
 #!/bin/bash
+# SPDX-License-Identifier: GPL-2.0
 #
 #
 #	LNet OCF RA
 #
 
 
-# License:      GNU General Public License (GPL)v2
 # Description:  Manages ZFS and Lustre on a shared storage
 # Written by:   Gabriele Paciucci
 # Release Date: 01 November 2016
@@ -14,27 +14,6 @@
 # Copyright (c) 2009 Andrew Beekhof
 # Copyright (c) 2016, Intel Corporation
 
-
-#
-# This program is free software; you can redistribute it and/or modify
-# it under the terms of version 2 of the GNU General Public License as
-# published by the Free Software Foundation.
-#
-# This program is distributed in the hope that it would be useful, but
-# WITHOUT ANY WARRANTY; without even the implied warranty of
-# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
-#
-# Further, this software is distributed without any warranty that it is
-# free of the rightful claim of any third person regarding infringement
-# or the like.  Any license provided herein, whether implied or
-# otherwise, applies only to this software file.  Patent licenses, if
-# any, provided herein do not apply to combinations of this program with
-# other software, or any other product whatsoever.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program.  If not, see <http://www.gnu.org/licenses/>.
-#
-
 #######################################################################
 # Initialization:
 
diff --git a/lustre/conf/resource/healthLUSTRE b/lustre/conf/resource/healthLUSTRE
index a184892460..4138a6024e 100755
--- a/lustre/conf/resource/healthLUSTRE
+++ b/lustre/conf/resource/healthLUSTRE
@@ -1,10 +1,10 @@
 #!/bin/bash
+# SPDX-License-Identifier: GPL-2.0
 #
 #
 #	HealthLUSTRE OCF RA
 #
 
-# License:      GNU General Public License (GPL)v2
 # Description:  Manages ZFS and Lustre on a shared storage
 # Written by:   Gabriele Paciucci
 # Release Date: 01 November 2016
@@ -12,27 +12,6 @@
 # Copyright (c) 2009 Andrew Beekhof
 # Copyright (c) 2016, Intel Corporation
 
-#
-# This program is free software; you can redistribute it and/or modify
-# it under the terms of version 2 of the GNU General Public License as
-# published by the Free Software Foundation.
-#
-# This program is distributed in the hope that it would be useful, but
-# WITHOUT ANY WARRANTY; without even the implied warranty of
-# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
-#
-# Further, this software is distributed without any warranty that it is
-# free of the rightful claim of any third person regarding infringement
-# or the like.  Any license provided herein, whether implied or
-# otherwise, applies only to this software file.  Patent licenses, if
-# any, provided herein do not apply to combinations of this program with
-# other software, or any other product whatsoever.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program.
-# If not, see <http://www.gnu.org/licenses/gpl-2.0.html>
-#
-
 #######################################################################
 # Initialization:
 
diff --git a/lustre/doc/Makefile.am b/lustre/doc/Makefile.am
index e7a6cf1fae..3be9685959 100644
--- a/lustre/doc/Makefile.am
+++ b/lustre/doc/Makefile.am
@@ -1,24 +1,4 @@
-#
-# GPL HEADER START
-#
-# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
-#
-# This program is free software; you can redistribute it and/or modify
-# it under the terms of the GNU General Public License version 2 only,
-# as published by the Free Software Foundation.
-#
-# This program is distributed in the hope that it will be useful, but
-# WITHOUT ANY WARRANTY; without even the implied warranty of
-# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-# General Public License version 2 for more details (a copy is included
-# in the LICENSE file that accompanied this code).
-#
-# You should have received a copy of the GNU General Public License
-# version 2 along with this program; If not, see
-# http://www.gnu.org/licenses/gpl-2.0.html
-#
-# GPL HEADER END
-#
+# SPDX-License-Identifier: GPL-2.0-only
 
 #
 # Copyright (c) 2001, 2010, Oracle and/or its affiliates. All rights reserved.
diff --git a/lustre/ec/autoMakefile.am b/lustre/ec/autoMakefile.am
index 10ccc187ff..d004f06e5d 100644
--- a/lustre/ec/autoMakefile.am
+++ b/lustre/ec/autoMakefile.am
@@ -1,24 +1,4 @@
-#
-# GPL HEADER START
-#
-# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
-#
-# This program is free software; you can redistribute it and/or modify
-# it under the terms of the GNU General Public License version 2 only,
-# as published by the Free Software Foundation.
-#
-# This program is distributed in the hope that it will be useful, but
-# WITHOUT ANY WARRANTY; without even the implied warranty of
-# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-# General Public License version 2 for more details (a copy is included
-# in the LICENSE file that accompanied this code).
-#
-# You should have received a copy of the GNU General Public License
-# version 2 along with this program; If not, see
-# http://www.gnu.org/licenses/gpl-2.0.html
-#
-# GPL HEADER END
-#
+# SPDX-License-Identifier: GPL-2.0-only
 
 #
 # Copyright (c) 2021 Intel and/or its affiliates. All rights reserved.
diff --git a/lustre/lov/lov_page.c b/lustre/lov/lov_page.c
index 86f5aec38f..33b11cd54c 100644
--- a/lustre/lov/lov_page.c
+++ b/lustre/lov/lov_page.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/scripts/Makefile.am b/lustre/scripts/Makefile.am
index ce32c8bb89..8c7f322847 100644
--- a/lustre/scripts/Makefile.am
+++ b/lustre/scripts/Makefile.am
@@ -1,24 +1,4 @@
-#
-# GPL HEADER START
-#
-# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
-#
-# This program is free software; you can redistribute it and/or modify
-# it under the terms of the GNU General Public License version 2 only,
-# as published by the Free Software Foundation.
-#
-# This program is distributed in the hope that it will be useful, but
-# WITHOUT ANY WARRANTY; without even the implied warranty of
-# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-# General Public License version 2 for more details (a copy is included
-# in the LICENSE file that accompanied this code).
-#
-# You should have received a copy of the GNU General Public License
-# version 2 along with this program; If not, see
-# http://www.gnu.org/licenses/gpl-2.0.html
-#
-# GPL HEADER END
-#
+# SPDX-License-Identifier: GPL-2.0-only
 
 #
 # Copyright (c) 1999, 2010, Oracle and/or its affiliates. All rights reserved.
diff --git a/lustre/scripts/zfsobj2fid b/lustre/scripts/zfsobj2fid
index a76095e1de..1f97eccfda 100755
--- a/lustre/scripts/zfsobj2fid
+++ b/lustre/scripts/zfsobj2fid
@@ -1,4 +1,5 @@
 #!/usr/bin/env python3
+# SPDX-License-Identifier: GPL-2.0
 
 # Copyright (c) 2014, Lawrence Livermore National Security, LLC.
 # Produced at the Lawrence Livermore National Laboratory.
@@ -7,18 +8,6 @@
 #
 # This file is part of lustre-tools-llnl.
 #
-# This program is free software; you can redistribute it and/or modify it
-# under the terms of the GNU General Public License (as published by the
-# Free Software Foundation) version 2, dated June 1991.
-#
-# This program is distributed in the hope that it will be useful, but WITHOUT
-# ANY WARRANTY; without even the IMPLIED WARRANTY OF
-# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-# terms and conditions of the GNU General Public License for more details.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 
 # Given a zfs dataset for a Lustre OST and the object number of a file
 # in that dataset, this script will call zdb to retreive the Lustre FID
diff --git a/lustre/tests/aheadmany.c b/lustre/tests/aheadmany.c
index d01d3fb8f2..3ee5b0710a 100644
--- a/lustre/tests/aheadmany.c
+++ b/lustre/tests/aheadmany.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2023, Whamcloud DDN Storage Corporation.
  */
diff --git a/lustre/tests/badarea_io.c b/lustre/tests/badarea_io.c
index d91067b78e..010582d7a2 100644
--- a/lustre/tests/badarea_io.c
+++ b/lustre/tests/badarea_io.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2014, Intel Corporation.
  * Use is subject to license terms.
diff --git a/lustre/tests/check_fallocate.c b/lustre/tests/check_fallocate.c
index b689f065ec..f942a84ca4 100644
--- a/lustre/tests/check_fallocate.c
+++ b/lustre/tests/check_fallocate.c
@@ -1,23 +1,4 @@
-/* GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 
 /*
  * Copyright (C) 2014, DataDirect Networks, Inc.
diff --git a/lustre/tests/check_fhandle_syscalls.c b/lustre/tests/check_fhandle_syscalls.c
index b8642c92af..c472fa626b 100644
--- a/lustre/tests/check_fhandle_syscalls.c
+++ b/lustre/tests/check_fhandle_syscalls.c
@@ -1,23 +1,4 @@
-/* GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 
 /*
  * Copyright (C) 2013, DataDirect Networks, Inc.
diff --git a/lustre/tests/checkfiemap.c b/lustre/tests/checkfiemap.c
index 65abc62fb9..7d5db54000 100644
--- a/lustre/tests/checkfiemap.c
+++ b/lustre/tests/checkfiemap.c
@@ -1,25 +1,4 @@
-/* GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see http://www.gnu.org/licenses
- *
- * Please  visit http://www.xyratex.com/contact if you need additional
- * information or have any questions.
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 
 /*
  * Copyright 2013 Xyratex Technology Limited
diff --git a/lustre/tests/checkstat.c b/lustre/tests/checkstat.c
index 4cc845eda8..cec92cf03e 100644
--- a/lustre/tests/checkstat.c
+++ b/lustre/tests/checkstat.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/chownmany.c b/lustre/tests/chownmany.c
index 2a910da6a6..35f6cedd74 100644
--- a/lustre/tests/chownmany.c
+++ b/lustre/tests/chownmany.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/clientapi/simple_test.c b/lustre/tests/clientapi/simple_test.c
index 2197933473..ed6fe9c4be 100644
--- a/lustre/tests/clientapi/simple_test.c
+++ b/lustre/tests/clientapi/simple_test.c
@@ -1,24 +1,4 @@
-/*
- *  GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 
 /*
  * Copyright (c) 2013, Intel Corporation.
diff --git a/lustre/tests/createmany.c b/lustre/tests/createmany.c
index 6d497fbe9a..382f52d302 100644
--- a/lustre/tests/createmany.c
+++ b/lustre/tests/createmany.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/createtest.c b/lustre/tests/createtest.c
index a39fbbc922..4d975a3439 100644
--- a/lustre/tests/createtest.c
+++ b/lustre/tests/createtest.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/directio.c b/lustre/tests/directio.c
index 32a76fd678..d442670501 100644
--- a/lustre/tests/directio.c
+++ b/lustre/tests/directio.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/euid_access.c b/lustre/tests/euid_access.c
index 744dd75971..7389932261 100644
--- a/lustre/tests/euid_access.c
+++ b/lustre/tests/euid_access.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2020, Whamcloud.
  */
diff --git a/lustre/tests/flock_deadlock.c b/lustre/tests/flock_deadlock.c
index 91a1d9af7c..fcb2956e54 100644
--- a/lustre/tests/flock_deadlock.c
+++ b/lustre/tests/flock_deadlock.c
@@ -1,26 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see http://www.gnu.org/licenses
- *
- * Please  visit http://www.xyratex.com/contact if you need additional
- * information or have any questions.
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 
 /*
  * Copyright 2012 Xyratex Technology Limited
diff --git a/lustre/tests/flocks_test.c b/lustre/tests/flocks_test.c
index ae2b90a5a0..1d59dc74ee 100644
--- a/lustre/tests/flocks_test.c
+++ b/lustre/tests/flocks_test.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/group_lock_test.c b/lustre/tests/group_lock_test.c
index 1c3a10ff6b..7b4b0d14b2 100644
--- a/lustre/tests/group_lock_test.c
+++ b/lustre/tests/group_lock_test.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 
 /*
  * Copyright 2014, 2015 Cray Inc, all rights reserved.
diff --git a/lustre/tests/io_uring_probe.c b/lustre/tests/io_uring_probe.c
index f96715fa7b..d78de4955a 100644
--- a/lustre/tests/io_uring_probe.c
+++ b/lustre/tests/io_uring_probe.c
@@ -1,21 +1,4 @@
-/*
- * LGPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * All rights reserved. This program and the accompanying materials
- * are made available under the terms of the GNU Lesser General Public License
- * (LGPL) version 2.1 or (at your discretion) any later version.
- * (LGPL) version 2.1 accompanies this distribution, and is available at
- * http://www.gnu.org/licenses/lgpl-2.1.html
- *
- * This library is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
- * Lesser General Public License for more details.
- *
- * LGPL HEADER END
- */
+// SPDX-License-Identifier: LGPL-2.1-or-later
 /*
  * Copyright (c) 2022, DDN/Whamcloud Storage Corporation.
  */
diff --git a/lustre/tests/kbuild b/lustre/tests/kbuild
index 4630d82331..3c96e53b1f 100755
--- a/lustre/tests/kbuild
+++ b/lustre/tests/kbuild
@@ -1,4 +1,5 @@
 #! /bin/sh
+# SPDX-License-Identifier: GPL-2.0
 
 #
 #  lustre/lustre/tests/kbuild
@@ -9,20 +10,6 @@
 #
 #  This file is part of Lustre, http://www.lustre.org.
 #
-#         Lustre is free  software; you can  redistribute it and/or  modify it
-#         under the terms of  version 2 of  the GNU General Public License  as
-#         published by the Free Software Foundation.
-#
-#         Lustre  is distributed  in the  hope  that it  will  be useful,  but
-#         WITHOUT  ANY   WARRANTY; without  even    the  implied  warranty  of
-#         MERCHANTABILITY or FITNESS FOR   A PARTICULAR PURPOSE.  See the  GNU
-#         General Public License for more details.
-#
-#         You  should have received a copy  of the  GNU General Public License
-#         along with  Lustre; if not, write to  the Free  Software Foundation,
-#         Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
-#
-#
 #  kbuild is a swiss-army linux kernel build script. Its purpose is to run
 #  automated kernel builds on given target file system (presumably Lustre) to
 #  measure file system performance and, occasionally, correctness.
diff --git a/lustre/tests/listxattr_size_check.c b/lustre/tests/listxattr_size_check.c
index b9eafb1b54..bdbee953a4 100644
--- a/lustre/tests/listxattr_size_check.c
+++ b/lustre/tests/listxattr_size_check.c
@@ -1,24 +1,5 @@
+// SPDX-License-Identifier: GPL-2.0-only
 /*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
-
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License version 2 for more details.  A copy is
- * included in the COPYING file that accompanied this code.
-
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
- *
- * GPL HEADER END
- *
  * Copyright (c) 2013, Intel Corporation.
  *
  * lustre/tests/listxattr_size_check.c
diff --git a/lustre/tests/ll_dirstripe_verify.c b/lustre/tests/ll_dirstripe_verify.c
index e6d4472d3e..920c25880f 100644
--- a/lustre/tests/ll_dirstripe_verify.c
+++ b/lustre/tests/ll_dirstripe_verify.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/ll_sparseness_verify.c b/lustre/tests/ll_sparseness_verify.c
index 4dbf589160..7f67071650 100644
--- a/lustre/tests/ll_sparseness_verify.c
+++ b/lustre/tests/ll_sparseness_verify.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/ll_sparseness_write.c b/lustre/tests/ll_sparseness_write.c
index f0b822c682..60451af950 100644
--- a/lustre/tests/ll_sparseness_write.c
+++ b/lustre/tests/ll_sparseness_write.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/llapi_fid_test.c b/lustre/tests/llapi_fid_test.c
index 4195f8192d..a69bfbed4e 100644
--- a/lustre/tests/llapi_fid_test.c
+++ b/lustre/tests/llapi_fid_test.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 
 /*
  * Copyright 2014 Cray Inc, all rights reserved.
diff --git a/lustre/tests/llapi_root_test.c b/lustre/tests/llapi_root_test.c
index 319bcb2fba..e51911dc89 100644
--- a/lustre/tests/llapi_root_test.c
+++ b/lustre/tests/llapi_root_test.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 
 /*
  * The purpose of this test is to check Lustre API root fd cache.
diff --git a/lustre/tests/lockahead_test.c b/lustre/tests/lockahead_test.c
index 6f4af9bf01..8b0f6885b3 100644
--- a/lustre/tests/lockahead_test.c
+++ b/lustre/tests/lockahead_test.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 
 /*
  * Copyright 2016 Cray Inc. All rights reserved.
diff --git a/lustre/tests/lov_getstripe_old.c b/lustre/tests/lov_getstripe_old.c
index c7fed91882..03c3fa4a44 100644
--- a/lustre/tests/lov_getstripe_old.c
+++ b/lustre/tests/lov_getstripe_old.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2021, DDN Storage Corporation.
  */
diff --git a/lustre/tests/lseek_test.c b/lustre/tests/lseek_test.c
index 0a732930e3..ede5924de4 100644
--- a/lustre/tests/lseek_test.c
+++ b/lustre/tests/lseek_test.c
@@ -1,23 +1,4 @@
-/* GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 
 /*
  * Copyright (c) 2020, Whamcloud.
diff --git a/lustre/tests/mcreate.c b/lustre/tests/mcreate.c
index 62f8831d19..8d2019bfd3 100644
--- a/lustre/tests/mcreate.c
+++ b/lustre/tests/mcreate.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/memhog.c b/lustre/tests/memhog.c
index b7c47aa632..1b99349533 100644
--- a/lustre/tests/memhog.c
+++ b/lustre/tests/memhog.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/mirror_io.c b/lustre/tests/mirror_io.c
index f3734b22c7..aeb7e938b6 100644
--- a/lustre/tests/mirror_io.c
+++ b/lustre/tests/mirror_io.c
@@ -1,28 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
- *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2017, Intel Corporation. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/mmap_cat.c b/lustre/tests/mmap_cat.c
index 0fb1edb396..9050976eac 100644
--- a/lustre/tests/mmap_cat.c
+++ b/lustre/tests/mmap_cat.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2009, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/mmap_mknod_test.c b/lustre/tests/mmap_mknod_test.c
index d1be8de268..6f2041a061 100644
--- a/lustre/tests/mmap_mknod_test.c
+++ b/lustre/tests/mmap_mknod_test.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2009, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/mmap_sanity.c b/lustre/tests/mmap_sanity.c
index e06fd80de9..30f9b4d0c8 100644
--- a/lustre/tests/mmap_sanity.c
+++ b/lustre/tests/mmap_sanity.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/mpi/cascading_rw.c b/lustre/tests/mpi/cascading_rw.c
index d69fd234fc..6324d85939 100644
--- a/lustre/tests/mpi/cascading_rw.c
+++ b/lustre/tests/mpi/cascading_rw.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/mpi/createmany-mpi.c b/lustre/tests/mpi/createmany-mpi.c
index 3ef756647e..5e91319adf 100644
--- a/lustre/tests/mpi/createmany-mpi.c
+++ b/lustre/tests/mpi/createmany-mpi.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/mpi/lp_utils.c b/lustre/tests/mpi/lp_utils.c
index a7c402423b..2768caa1de 100644
--- a/lustre/tests/mpi/lp_utils.c
+++ b/lustre/tests/mpi/lp_utils.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/mpi/lp_utils.h b/lustre/tests/mpi/lp_utils.h
index 2963898cc2..d1a8429ba4 100644
--- a/lustre/tests/mpi/lp_utils.h
+++ b/lustre/tests/mpi/lp_utils.h
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/mpi/parallel_grouplock.c b/lustre/tests/mpi/parallel_grouplock.c
index f99e2de02c..44c908d25e 100644
--- a/lustre/tests/mpi/parallel_grouplock.c
+++ b/lustre/tests/mpi/parallel_grouplock.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/mpi/rr_alloc.c b/lustre/tests/mpi/rr_alloc.c
index c334b0debc..7b90eab72c 100644
--- a/lustre/tests/mpi/rr_alloc.c
+++ b/lustre/tests/mpi/rr_alloc.c
@@ -1,27 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see If not, see
- * http://www.gnu.org/licenses
- *
- * Please contact http://www.seagate.com/contacts/ or visit www.seagate.com
- * if you need additional information or have any questions.
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2017, Seagate Technology LLC
  *
diff --git a/lustre/tests/mpi/write_append_truncate.c b/lustre/tests/mpi/write_append_truncate.c
index 62966465e2..f726a9fccf 100644
--- a/lustre/tests/mpi/write_append_truncate.c
+++ b/lustre/tests/mpi/write_append_truncate.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/mpi/write_disjoint.c b/lustre/tests/mpi/write_disjoint.c
index 2b045fecff..88a1beda46 100644
--- a/lustre/tests/mpi/write_disjoint.c
+++ b/lustre/tests/mpi/write_disjoint.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/mrename.c b/lustre/tests/mrename.c
index 0ee16c504e..3264964623 100644
--- a/lustre/tests/mrename.c
+++ b/lustre/tests/mrename.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/multifstat.c b/lustre/tests/multifstat.c
index 9ed04dfb1d..801aee282c 100644
--- a/lustre/tests/multifstat.c
+++ b/lustre/tests/multifstat.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/multiop.c b/lustre/tests/multiop.c
index 4c5a7dc3c9..4528efcd63 100644
--- a/lustre/tests/multiop.c
+++ b/lustre/tests/multiop.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/opendevunlink.c b/lustre/tests/opendevunlink.c
index d2ce365f21..db6471b7bd 100644
--- a/lustre/tests/opendevunlink.c
+++ b/lustre/tests/opendevunlink.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/opendirunlink.c b/lustre/tests/opendirunlink.c
index 3d9d2bf0f2..2337840145 100644
--- a/lustre/tests/opendirunlink.c
+++ b/lustre/tests/opendirunlink.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/openfile.c b/lustre/tests/openfile.c
index eff1a8fde4..cc058a8d5f 100644
--- a/lustre/tests/openfile.c
+++ b/lustre/tests/openfile.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/openfilleddirunlink.c b/lustre/tests/openfilleddirunlink.c
index 90b3714715..03b62e21ea 100644
--- a/lustre/tests/openfilleddirunlink.c
+++ b/lustre/tests/openfilleddirunlink.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/openunlink.c b/lustre/tests/openunlink.c
index 36f4c805cb..87613617ca 100644
--- a/lustre/tests/openunlink.c
+++ b/lustre/tests/openunlink.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/orphan_linkea_check.c b/lustre/tests/orphan_linkea_check.c
index a6fcc88838..cde81640ad 100644
--- a/lustre/tests/orphan_linkea_check.c
+++ b/lustre/tests/orphan_linkea_check.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2014, 2015, Intel Corporation.
  * Use is subject to license terms.
diff --git a/lustre/tests/reads.c b/lustre/tests/reads.c
index 9b1e98ecdf..c2f52a4cdc 100644
--- a/lustre/tests/reads.c
+++ b/lustre/tests/reads.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/rename_many.c b/lustre/tests/rename_many.c
index 7522072b50..9b9bc60596 100644
--- a/lustre/tests/rename_many.c
+++ b/lustre/tests/rename_many.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/runas.c b/lustre/tests/runas.c
index 5cfc29913d..d20ef70356 100644
--- a/lustre/tests/runas.c
+++ b/lustre/tests/runas.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/rwv.c b/lustre/tests/rwv.c
index bc10d3f26d..77f040ee24 100644
--- a/lustre/tests/rwv.c
+++ b/lustre/tests/rwv.c
@@ -1,25 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/sendfile.c b/lustre/tests/sendfile.c
index 028f02cba8..9e681a469b 100644
--- a/lustre/tests/sendfile.c
+++ b/lustre/tests/sendfile.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/sendfile_grouplock.c b/lustre/tests/sendfile_grouplock.c
index e0b74ce8a3..adb239c008 100644
--- a/lustre/tests/sendfile_grouplock.c
+++ b/lustre/tests/sendfile_grouplock.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADDER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 
 /*
  * Copyright 2015 Cray Inc, all rights reserved.
diff --git a/lustre/tests/small_write.c b/lustre/tests/small_write.c
index 8d62a267be..7ab0227f3a 100644
--- a/lustre/tests/small_write.c
+++ b/lustre/tests/small_write.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/smalliomany.c b/lustre/tests/smalliomany.c
index 889f96b2d0..f85f3f6bb9 100644
--- a/lustre/tests/smalliomany.c
+++ b/lustre/tests/smalliomany.c
@@ -1,28 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
- *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/statmany.c b/lustre/tests/statmany.c
index bf58277313..6356f3e315 100644
--- a/lustre/tests/statmany.c
+++ b/lustre/tests/statmany.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/statone.c b/lustre/tests/statone.c
index f17f701bea..ac9148f406 100644
--- a/lustre/tests/statone.c
+++ b/lustre/tests/statone.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/statx.c b/lustre/tests/statx.c
index b0c23b310f..d7c25e45c5 100644
--- a/lustre/tests/statx.c
+++ b/lustre/tests/statx.c
@@ -1,21 +1,4 @@
-/*
- * LGPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * All rights reserved. This program and the accompanying materials
- * are made available under the terms of the GNU Lesser General Public License
- * (LGPL) version 2.1 or (at your discretion) any later version.
- * (LGPL) version 2.1 accompanies this distribution, and is available at
- * http://www.gnu.org/licenses/lgpl-2.1.html
- *
- * This library is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
- * Lesser General Public License for more details.
- *
- * LGPL HEADER END
- */
+// SPDX-License-Identifier: LGPL-2.1-or-later
 /*
  * Copyright (c) 2019, DDN Storage Corporation.
  */
diff --git a/lustre/tests/swap_lock_test.c b/lustre/tests/swap_lock_test.c
index ad8103ad53..0b35628711 100644
--- a/lustre/tests/swap_lock_test.c
+++ b/lustre/tests/swap_lock_test.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 
 /*
  * Copyright 2015 Cray Inc, all rights reserved.
diff --git a/lustre/tests/tchmod.c b/lustre/tests/tchmod.c
index b0bbc659f2..b77e29f7a4 100644
--- a/lustre/tests/tchmod.c
+++ b/lustre/tests/tchmod.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/test_brw.c b/lustre/tests/test_brw.c
index a15cbc12d7..a82754bde8 100644
--- a/lustre/tests/test_brw.c
+++ b/lustre/tests/test_brw.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/truncate.c b/lustre/tests/truncate.c
index 2e6e84026d..a818c37e75 100644
--- a/lustre/tests/truncate.c
+++ b/lustre/tests/truncate.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/unlinkmany.c b/lustre/tests/unlinkmany.c
index 9be360953d..dcd6561fa6 100644
--- a/lustre/tests/unlinkmany.c
+++ b/lustre/tests/unlinkmany.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/utime.c b/lustre/tests/utime.c
index 752dfcb97d..fe16a2e0e8 100644
--- a/lustre/tests/utime.c
+++ b/lustre/tests/utime.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/write_time_limit.c b/lustre/tests/write_time_limit.c
index dfcc75a42a..476398f5d6 100644
--- a/lustre/tests/write_time_limit.c
+++ b/lustre/tests/write_time_limit.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/writemany.c b/lustre/tests/writemany.c
index e0878de1a8..921f381177 100644
--- a/lustre/tests/writemany.c
+++ b/lustre/tests/writemany.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/tests/writeme.c b/lustre/tests/writeme.c
index 1ee7634055..8711d0c164 100644
--- a/lustre/tests/writeme.c
+++ b/lustre/tests/writeme.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/callvpe.c b/lustre/utils/callvpe.c
index 5c98a05ede..31b1a6aa57 100644
--- a/lustre/utils/callvpe.c
+++ b/lustre/utils/callvpe.c
@@ -1,23 +1,5 @@
+// SPDX-License-Identifier: LGPL-2.1-or-later
 /*
- * LGPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU Lesser General Public License as
- * published by the Free Software Foundation; either version 2.1 of the
- * License, or (at your option) any later version.
- *
- * This library is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
- * Lesser General Public License for more details.
- *
- * You should have received a copy of the GNU Lesser General Public
- * License along with this library. If not, see <http://www.gnu.org/licenses/>.
- *
- * LGPL HEADER END
- *
  * Copyright (c) 2018, Intel Corporation.
  */
 
diff --git a/lustre/utils/callvpe.h b/lustre/utils/callvpe.h
index d220dc01cd..468493ae99 100644
--- a/lustre/utils/callvpe.h
+++ b/lustre/utils/callvpe.h
@@ -1,23 +1,5 @@
+// SPDX-License-Identifier: LGPL-2.1-or-later
 /*
- * LGPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU Lesser General Public License as
- * published by the Free Software Foundation; either version 2.1 of the
- * License, or (at your option) any later version.
- *
- * This library is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
- * Lesser General Public License for more details.
- *
- * You should have received a copy of the GNU Lesser General Public
- * License along with this library. If not, see <http://www.gnu.org/licenses/>.
- *
- * LGPL HEADER END
- *
  * Copyright (c) 2018, Intel Corporation.
  */
 
diff --git a/lustre/utils/check_iam.c b/lustre/utils/check_iam.c
index 4fe0d292fa..89b0f59490 100644
--- a/lustre/utils/check_iam.c
+++ b/lustre/utils/check_iam.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  *
  * User-level tool to check iam files sanity.
diff --git a/lustre/utils/debug.c b/lustre/utils/debug.c
index fa2494e1cf..57981c8be2 100644
--- a/lustre/utils/debug.c
+++ b/lustre/utils/debug.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/gss/lgss_keyring.c b/lustre/utils/gss/lgss_keyring.c
index 278aaa72fb..2cefbc1f1c 100644
--- a/lustre/utils/gss/lgss_keyring.c
+++ b/lustre/utils/gss/lgss_keyring.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/gss/lgss_null_utils.c b/lustre/utils/gss/lgss_null_utils.c
index 97e266a35b..fa5d552166 100644
--- a/lustre/utils/gss/lgss_null_utils.c
+++ b/lustre/utils/gss/lgss_null_utils.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (C) 2015, Trustees of Indiana University
  *
diff --git a/lustre/utils/gss/lgss_sk.c b/lustre/utils/gss/lgss_sk.c
index c43722c75d..356961b112 100644
--- a/lustre/utils/gss/lgss_sk.c
+++ b/lustre/utils/gss/lgss_sk.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (C) 2015, Trustees of Indiana University
  *
diff --git a/lustre/utils/gss/lgss_sk_utils.c b/lustre/utils/gss/lgss_sk_utils.c
index 4ee8a48854..21cf42abcb 100644
--- a/lustre/utils/gss/lgss_sk_utils.c
+++ b/lustre/utils/gss/lgss_sk_utils.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (C) 2015, Trustees of Indiana University
  *
diff --git a/lustre/utils/gss/lsupport.c b/lustre/utils/gss/lsupport.c
index 39a4d89aa7..6253f64dbd 100644
--- a/lustre/utils/gss/lsupport.c
+++ b/lustre/utils/gss/lsupport.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/gss/lsupport.h b/lustre/utils/gss/lsupport.h
index e4a3c03aad..f8bd6dcf3b 100644
--- a/lustre/utils/gss/lsupport.h
+++ b/lustre/utils/gss/lsupport.h
@@ -1,25 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2006, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/gss/sk_utils.c b/lustre/utils/gss/sk_utils.c
index 8ad0fece9a..634b70cd0d 100644
--- a/lustre/utils/gss/sk_utils.c
+++ b/lustre/utils/gss/sk_utils.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (C) 2015, Trustees of Indiana University
  *
diff --git a/lustre/utils/gss/sk_utils.h b/lustre/utils/gss/sk_utils.h
index 3889de9dea..6d960a8f20 100644
--- a/lustre/utils/gss/sk_utils.h
+++ b/lustre/utils/gss/sk_utils.h
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (C) 2015, Trustees of Indiana University
  *
diff --git a/lustre/utils/l_foreign_symlink.c b/lustre/utils/l_foreign_symlink.c
index 7bf7ec9a86..6444f3de44 100644
--- a/lustre/utils/l_foreign_symlink.c
+++ b/lustre/utils/l_foreign_symlink.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2020, Intel Corporation.
  */
diff --git a/lustre/utils/l_getidentity.c b/lustre/utils/l_getidentity.c
index 7bed26252f..b748605047 100644
--- a/lustre/utils/l_getidentity.c
+++ b/lustre/utils/l_getidentity.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/l_getsepol.c b/lustre/utils/l_getsepol.c
index 9e068528a1..3581657afe 100644
--- a/lustre/utils/l_getsepol.c
+++ b/lustre/utils/l_getsepol.c
@@ -1,23 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see http://www.gnu.org/licenses
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 
 /*
  * Copyright (c) 2016 DDN Storage
diff --git a/lustre/utils/l_tunedisk.c b/lustre/utils/l_tunedisk.c
index 50ee4022ea..182a798f68 100644
--- a/lustre/utils/l_tunedisk.c
+++ b/lustre/utils/l_tunedisk.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2018, Intel Corporation.
  */
diff --git a/lustre/utils/lctl.c b/lustre/utils/lctl.c
index 879f800d18..7b1b51084d 100644
--- a/lustre/utils/lctl.c
+++ b/lustre/utils/lctl.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/lctl_thread.c b/lustre/utils/lctl_thread.c
index 29b4e45fc7..1ab26f0b14 100644
--- a/lustre/utils/lctl_thread.c
+++ b/lustre/utils/lctl_thread.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * This file is part of Lustre, http://www.lustre.org/
  *
diff --git a/lustre/utils/lctl_thread.h b/lustre/utils/lctl_thread.h
index 1f269237fd..6d6860ac32 100644
--- a/lustre/utils/lctl_thread.h
+++ b/lustre/utils/lctl_thread.h
@@ -1,26 +1,9 @@
+// SPDX-License-Identifier: LGPL-2.1-or-later
 /*
- * LGPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
  * (C) Copyright 2012 Commissariat a l'energie atomique et aux energies
  *     alternatives
  *
  * Copyright (c) 2016, 2017, Intel Corporation.
- *
- * All rights reserved. This program and the accompanying materials
- * are made available under the terms of the GNU Lesser General Public License
- * (LGPL) version 2.1 or (at your discretion) any later version.
- * (LGPL) version 2.1 accompanies this distribution, and is available at
- * http://www.gnu.org/licenses/lgpl-2.1.html
- *
- *
- * This library is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
- * Lesser General Public License for more details.
- *
- * LGPL HEADER END
  */
 /*
  *
diff --git a/lustre/utils/lfs.c b/lustre/utils/lfs.c
index b844c15f24..44e6f76b18 100644
--- a/lustre/utils/lfs.c
+++ b/lustre/utils/lfs.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/lfs_project.c b/lustre/utils/lfs_project.c
index 8e03afcab6..1a8ff785de 100644
--- a/lustre/utils/lfs_project.c
+++ b/lustre/utils/lfs_project.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2017, DataDirect Networks Storage.
  * Copyright (c) 2017, Intel Corporation.
diff --git a/lustre/utils/lfs_project.h b/lustre/utils/lfs_project.h
index 01310a9b62..26ef71e8a9 100644
--- a/lustre/utils/lfs_project.h
+++ b/lustre/utils/lfs_project.h
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2017, DataDirect Networks Storage.
  * Copyright (c) 2017, Intel Corporation.
diff --git a/lustre/utils/lhsmtool_posix.c b/lustre/utils/lhsmtool_posix.c
index 7e02586307..0ba00e23c0 100644
--- a/lustre/utils/lhsmtool_posix.c
+++ b/lustre/utils/lhsmtool_posix.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.htm
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * (C) Copyright 2012 Commissariat a l'energie atomique et aux energies
  *     alternatives
diff --git a/lustre/utils/libhsm_scanner.c b/lustre/utils/libhsm_scanner.c
index c5f96ebdc0..95f021b39b 100644
--- a/lustre/utils/libhsm_scanner.c
+++ b/lustre/utils/libhsm_scanner.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; if not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2019, DDN Storage Corporation.
  */
diff --git a/lustre/utils/libhsm_scanner.h b/lustre/utils/libhsm_scanner.h
index 4dea572235..26fad5a096 100644
--- a/lustre/utils/libhsm_scanner.h
+++ b/lustre/utils/libhsm_scanner.h
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; if not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2019, DDN Storage Corporation.
  */
diff --git a/lustre/utils/libiam.c b/lustre/utils/libiam.c
index 7e5f363fcb..00af563880 100644
--- a/lustre/utils/libiam.c
+++ b/lustre/utils/libiam.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/libmount_utils_ldiskfs.c b/lustre/utils/libmount_utils_ldiskfs.c
index 01036dfd7f..a0f3204de9 100644
--- a/lustre/utils/libmount_utils_ldiskfs.c
+++ b/lustre/utils/libmount_utils_ldiskfs.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/libmount_utils_zfs.c b/lustre/utils/libmount_utils_zfs.c
index e9383cbdb0..fddb3ede7e 100644
--- a/lustre/utils/libmount_utils_zfs.c
+++ b/lustre/utils/libmount_utils_zfs.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
-
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License version 2 for more details.  A copy is
- * included in the COPYING file that accompanied this code.
-
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2012, 2017, Intel Corporation.
  * Use is subject to license terms.
diff --git a/lustre/utils/ll_decode_filter_fid.c b/lustre/utils/ll_decode_filter_fid.c
index e80417bdeb..14eb8a1736 100644
--- a/lustre/utils/ll_decode_filter_fid.c
+++ b/lustre/utils/ll_decode_filter_fid.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/ll_decode_linkea.c b/lustre/utils/ll_decode_linkea.c
index 9e84ff8595..14a8abc648 100644
--- a/lustre/utils/ll_decode_linkea.c
+++ b/lustre/utils/ll_decode_linkea.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; if not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2016, DDN Storage Corporation.
  */
diff --git a/lustre/utils/llog_reader.c b/lustre/utils/llog_reader.c
index dfe35afc3c..2f52569ab7 100644
--- a/lustre/utils/llog_reader.c
+++ b/lustre/utils/llog_reader.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/llsom_sync.c b/lustre/utils/llsom_sync.c
index e7ad28572c..953a0eb0d8 100644
--- a/lustre/utils/llsom_sync.c
+++ b/lustre/utils/llsom_sync.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; if not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2017, DDN Storage Corporation.
  */
diff --git a/lustre/utils/llverdev.c b/lustre/utils/llverdev.c
index 2e9158f66a..24e7e81824 100644
--- a/lustre/utils/llverdev.c
+++ b/lustre/utils/llverdev.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/lr_reader.c b/lustre/utils/lr_reader.c
index b4824ce615..99d3c0d8a2 100644
--- a/lustre/utils/lr_reader.c
+++ b/lustre/utils/lr_reader.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/lshowmount.c b/lustre/utils/lshowmount.c
index cddc2f9811..809cbaec51 100644
--- a/lustre/utils/lshowmount.c
+++ b/lustre/utils/lshowmount.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2009, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/lsnapshot.c b/lustre/utils/lsnapshot.c
index 2d93176c1b..f0777f56ec 100644
--- a/lustre/utils/lsnapshot.c
+++ b/lustre/utils/lsnapshot.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
-
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License version 2 for more details.  A copy is
- * included in the COPYING file that accompanied this code.
-
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2017, Intel Corporation.
  *
diff --git a/lustre/utils/lustre_cfg.c b/lustre/utils/lustre_cfg.c
index 0998b314aa..3423c6b428 100644
--- a/lustre/utils/lustre_cfg.c
+++ b/lustre/utils/lustre_cfg.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/lustre_lfsck.c b/lustre/utils/lustre_lfsck.c
index 5e4893299e..10c44e0030 100644
--- a/lustre/utils/lustre_lfsck.c
+++ b/lustre/utils/lustre_lfsck.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
-
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License version 2 for more details.  A copy is
- * included in the COPYING file that accompanied this code.
-
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2012, 2017, Intel Corporation.
  */
diff --git a/lustre/utils/lustre_param.c b/lustre/utils/lustre_param.c
index 926a156a0a..c22688a01f 100644
--- a/lustre/utils/lustre_param.c
+++ b/lustre/utils/lustre_param.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/lustre_rsync.c b/lustre/utils/lustre_rsync.c
index 9dae40508a..e6c2587034 100644
--- a/lustre/utils/lustre_rsync.c
+++ b/lustre/utils/lustre_rsync.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2009, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/lustre_rsync.h b/lustre/utils/lustre_rsync.h
index bb95cc1d3b..0032fdec1b 100644
--- a/lustre/utils/lustre_rsync.h
+++ b/lustre/utils/lustre_rsync.h
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2009, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/lustreapi_internal.h b/lustre/utils/lustreapi_internal.h
index e81d7f6faa..ae9f7772c4 100644
--- a/lustre/utils/lustreapi_internal.h
+++ b/lustre/utils/lustreapi_internal.h
@@ -1,26 +1,9 @@
+// SPDX-License-Identifier: LGPL-2.1-or-later
 /*
- * LGPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
  * (C) Copyright 2012 Commissariat a l'energie atomique et aux energies
  *     alternatives
  *
  * Copyright (c) 2016, 2017, Intel Corporation.
- *
- * All rights reserved. This program and the accompanying materials
- * are made available under the terms of the GNU Lesser General Public License
- * (LGPL) version 2.1 or (at your discretion) any later version.
- * (LGPL) version 2.1 accompanies this distribution, and is available at
- * http://www.gnu.org/licenses/lgpl-2.1.html
- *
- *
- * This library is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
- * Lesser General Public License for more details.
- *
- * LGPL HEADER END
  */
 /*
  *
diff --git a/lustre/utils/mkfs_lustre.c b/lustre/utils/mkfs_lustre.c
index e1f54c32ae..aec6e6d65c 100644
--- a/lustre/utils/mkfs_lustre.c
+++ b/lustre/utils/mkfs_lustre.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/mount_lustre.c b/lustre/utils/mount_lustre.c
index ad7be845c7..d281bafe72 100644
--- a/lustre/utils/mount_lustre.c
+++ b/lustre/utils/mount_lustre.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/mount_utils.c b/lustre/utils/mount_utils.c
index 08014fa787..346a03ce03 100644
--- a/lustre/utils/mount_utils.c
+++ b/lustre/utils/mount_utils.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/mount_utils.h b/lustre/utils/mount_utils.h
index 0f04381ee4..5a160f4c6c 100644
--- a/lustre/utils/mount_utils.h
+++ b/lustre/utils/mount_utils.h
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/nidlist.c b/lustre/utils/nidlist.c
index 4ca40d1992..a1cc99ebbc 100644
--- a/lustre/utils/nidlist.c
+++ b/lustre/utils/nidlist.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2009, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/nidlist.h b/lustre/utils/nidlist.h
index ab6adc39a0..6d378834a0 100644
--- a/lustre/utils/nidlist.h
+++ b/lustre/utils/nidlist.h
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2009, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/obd.c b/lustre/utils/obd.c
index 0f317a32a4..69ad462837 100644
--- a/lustre/utils/obd.c
+++ b/lustre/utils/obd.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/obdctl.h b/lustre/utils/obdctl.h
index d114f0b2d9..63c340f52d 100644
--- a/lustre/utils/obdctl.h
+++ b/lustre/utils/obdctl.h
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2002, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/ofd_access_batch.c b/lustre/utils/ofd_access_batch.c
index 378beb47f9..03adb96806 100644
--- a/lustre/utils/ofd_access_batch.c
+++ b/lustre/utils/ofd_access_batch.c
@@ -1,24 +1,5 @@
+// SPDX-License-Identifier: GPL-2.0-only
 /*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- *
  * Copyright 2020, DataDirect Networks Storage.
  *
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/lustre/utils/ofd_access_log_reader.c b/lustre/utils/ofd_access_log_reader.c
index b91051eafd..89dbd2de32 100644
--- a/lustre/utils/ofd_access_log_reader.c
+++ b/lustre/utils/ofd_access_log_reader.c
@@ -1,24 +1,5 @@
+// SPDX-License-Identifier: GPL-2.0-only
 /*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- *
  * Copyright 2020, DataDirect Networks Storage.
  *
  * This file is part of Lustre, http://www.lustre.org/
diff --git a/lustre/utils/pid_file.c b/lustre/utils/pid_file.c
index 2d19c70bde..9095368e6c 100644
--- a/lustre/utils/pid_file.c
+++ b/lustre/utils/pid_file.c
@@ -1,23 +1,5 @@
+// SPDX-License-Identifier: LGPL-2.1-or-later
 /*
- * LGPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU Lesser General Public License as
- * published by the Free Software Foundation; either version 2.1 of the
- * License, or (at your option) any later version.
- *
- * This library is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
- * Lesser General Public License for more details.
- *
- * You should have received a copy of the GNU Lesser General Public
- * License along with this library. If not, see <http://www.gnu.org/licenses/>.
- *
- * LGPL HEADER END
- *
  * Copyright 2020, DataDirect Networks Storage.
  */
 #include <stddef.h>
diff --git a/lustre/utils/pid_file.h b/lustre/utils/pid_file.h
index 97f5fec7da..9ab2d959ba 100644
--- a/lustre/utils/pid_file.h
+++ b/lustre/utils/pid_file.h
@@ -1,23 +1,5 @@
+// SPDX-License-Identifier: LGPL-2.1-or-later
 /*
- * LGPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU Lesser General Public License as
- * published by the Free Software Foundation; either version 2.1 of the
- * License, or (at your option) any later version.
- *
- * This library is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
- * Lesser General Public License for more details.
- *
- * You should have received a copy of the GNU Lesser General Public
- * License along with this library. If not, see <http://www.gnu.org/licenses/>.
- *
- * LGPL HEADER END
- *
  * Copyright 2020, DataDirect Networks Storage.
  */
 
diff --git a/lustre/utils/portals.c b/lustre/utils/portals.c
index 691a30b697..22c61ffb7b 100644
--- a/lustre/utils/portals.c
+++ b/lustre/utils/portals.c
@@ -1,23 +1,10 @@
+// SPDX-License-Identifier: GPL-2.0
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  *
  * Copyright (c) 2013, 2017, Intel Corporation.
  *
  *   This file is part of Lustre, https://wiki.whamcloud.com/
- *
- *   Portals is free software; you can redistribute it and/or
- *   modify it under the terms of version 2 of the GNU General Public
- *   License as published by the Free Software Foundation.
- *
- *   Portals is distributed in the hope that it will be useful,
- *   but WITHOUT ANY WARRANTY; without even the implied warranty of
- *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- *   GNU General Public License for more details.
- *
- *   You should have received a copy of the GNU General Public License
- *   along with Portals; if not, write to the Free Software
- *   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
- *
  */
 #include <errno.h>
 #include <getopt.h>
diff --git a/lustre/utils/wirecheck.c b/lustre/utils/wirecheck.c
index fe5c87c2fc..8a92ac9934 100644
--- a/lustre/utils/wirecheck.c
+++ b/lustre/utils/wirecheck.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/wirehdr.c b/lustre/utils/wirehdr.c
index d49a413eb0..97da36572f 100644
--- a/lustre/utils/wirehdr.c
+++ b/lustre/utils/wirehdr.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
diff --git a/lustre/utils/wiretest.c b/lustre/utils/wiretest.c
index 450ce924fb..e9e79b6d7d 100644
--- a/lustre/utils/wiretest.c
+++ b/lustre/utils/wiretest.c
@@ -1,24 +1,4 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
+// SPDX-License-Identifier: GPL-2.0-only
 /*
  * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
-- 
2.49.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
