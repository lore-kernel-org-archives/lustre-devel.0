From: James Simmons <jsimmons@infradead.org>
Date: Wed, 24 Jul 2019 22:43:59 -0400
Subject: [lustre-devel] [PATCH 0/8] lustre: some old patches from whamcloud
 tree
Message-ID: <1564022647-17351-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Some old patches missing from the linux lustre client. I suspect
these weren't port since they most are likely server side only
but I want to make sure. Also we are missing patch:

http://review.whamcloud.com/20939 from LU-8319 but I don't know
if that is needed anymore with the earlier changes done.
Feedback welcomed.

Andreas Dilger (1):
  lustre: seq: make seq_proc_write_common() safer

Gregoire Pichon (1):
  lustre: tests: testcases for multiple modify RPCs feature

Jeremy Filizetti (1):
  lustre: ldlm: Don't check opcode with NULL rq_reqmsg

Li Wei (1):
  lustre: ptlrpc: Fix an rq_no_reply assertion failure

Wang Di (1):
  lustre: fld: retry fld rpc until the import is closed

wang di (3):
  lustre: fld: resend seq lookup RPC if it is on LWP
  lustre: fld: retry fld rpc even for ESHUTDOWN
  lustre: fld: fld client lookup should retry

 fs/lustre/fid/lproc_fid.c       | 12 +++++++-----
 fs/lustre/fld/fld_request.c     | 42 ++++++++++++++++++++++++++++++++++++++---
 fs/lustre/include/obd_support.h |  2 ++
 fs/lustre/ldlm/ldlm_lib.c       |  7 +++++++
 fs/lustre/ptlrpc/service.c      | 10 ++++++++++
 5 files changed, 65 insertions(+), 8 deletions(-)

-- 
1.8.3.1
