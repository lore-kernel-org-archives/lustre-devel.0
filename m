From: Shraddha <shraddha.6596@gmail.com>
Date: Wed, 16 Dec 2015 23:10:14 +0530
Subject: [lustre-devel] [PATCH 0/3] Staging: lustre: Remove unused code
Message-ID: <1450287617-7682-1-git-send-email-shraddha.6596@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Shraddha Barke <shraddha.6596@gmail.com>

Remove unused functions.

Shraddha Barke (3):
  Staging: lustre: include: Remove unused llog_backup declaration
  Staging: lustre: include: Remove unused md_should_create
  Staging: lustre: lnet: Remove functions LNetEQWait and LNetEQGet

 drivers/staging/lustre/include/linux/lnet/api.h    |  6 ------
 drivers/staging/lustre/lnet/lnet/lib-eq.c          | 18 ------------------
 drivers/staging/lustre/lustre/include/lustre_log.h |  3 ---
 drivers/staging/lustre/lustre/include/lustre_mds.h |  6 ------
 4 files changed, 33 deletions(-)

-- 
2.1.4
