From: James Simmons <jsimmons@infradead.org>
Date: Thu, 29 Oct 2015 19:28:20 -0400
Subject: [lustre-devel] [PATCH 0/3] make nidstring.c kernel style compliant
Message-ID: <1446161303-798-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Last patch set to make nidstring.c and nidstr.h both report
no errors with checkpatch and removal of the remaining white
spaces.

James Simmons (3):
  staging: lustre: checkpatch cleanups for nidstring.c
  staging: lustre: white space cleanups for nidstring.c
  staging: lustre: checkpatch cleanups for nidstr.h

 drivers/staging/lustre/include/linux/lnet/nidstr.h |    9 ++-
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |   98 +++++++++++---------
 2 files changed, 60 insertions(+), 47 deletions(-)
