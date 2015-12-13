From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 13 Dec 2015 14:48:35 +0100
Subject: [lustre-devel] [PATCH 0/7] staging-Lustre: Fine-tuning for some
 function implementations
In-Reply-To: <566ABCD9.1060404@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
Message-ID: <566D7733.1030102@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 13 Dec 2015 14:40:14 +0100

Several update suggestions were taken into account
from static source code analysis.

Markus Elfring (7):
  Delete unnecessary goto statements in six functions
  Rename a jump label for ptlrpc_req_finished() calls
  Rename a jump label for a kfree(key) call
  Delete an unnecessary variable initialisation in mgc_process_recover_log()
  Less checks in mgc_process_recover_log() after error detection
  A few checks less in mgc_process_recover_log() after error detection
  Rename a jump label for module_put() calls

 drivers/staging/lustre/lustre/llite/file.c         |  26 ++---
 drivers/staging/lustre/lustre/llite/lloop.c        |   8 +-
 drivers/staging/lustre/lustre/llite/namei.c        |  13 +--
 drivers/staging/lustre/lustre/llite/xattr.c        |  20 ++--
 drivers/staging/lustre/lustre/mdc/mdc_request.c    | 124 ++++++++++-----------
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |  53 ++++-----
 drivers/staging/lustre/lustre/osc/osc_request.c    |  52 ++++-----
 drivers/staging/lustre/lustre/ptlrpc/llog_client.c |  22 ++--
 8 files changed, 152 insertions(+), 166 deletions(-)

-- 
2.6.3
