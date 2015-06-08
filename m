From: Antonio Murdaca <antoniomurdaca@gmail.com>
Date: Mon,  8 Jun 2015 21:48:40 +0200
Subject: [lustre-devel] [PATCH v2 0/1] staging: lustre: cleanup not needed
	else clauses
Message-ID: <1433792921-10920-1-git-send-email-runcom@linux.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This patch applies cleanly to staging-next tree

Antonio Murdaca (1):
  staging: lustre: cleanup not needed else clauses

 drivers/staging/lustre/lustre/fid/fid_request.c        |  5 ++---
 drivers/staging/lustre/lustre/include/lprocfs_status.h |  3 +--
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c          |  3 +--
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c         | 11 ++++++-----
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c         |  3 +--
 drivers/staging/lustre/lustre/lov/lov_request.c        |  3 +--
 drivers/staging/lustre/lustre/mdc/mdc_request.c        |  8 ++++----
 drivers/staging/lustre/lustre/obdclass/cl_object.c     |  6 ++----
 drivers/staging/lustre/lustre/obdclass/llog_cat.c      |  6 ++----
 drivers/staging/lustre/lustre/osc/osc_lock.c           |  3 +--
 drivers/staging/lustre/lustre/osc/osc_request.c        | 14 ++++++++------
 drivers/staging/lustre/lustre/ptlrpc/pinger.c          |  8 +++-----
 12 files changed, 32 insertions(+), 41 deletions(-)

-- 
2.4.3
