From: Tyson Whitehead <twhitehead@gmail.com>
Date: Wed, 06 Sep 2017 12:04:04 -0400
Subject: [lustre-devel] [PATCH 0/2] LU-6808: ported to upstream staging
	driver
Message-ID: <9525089.uibW5qMffG@whitehead.beowulf.uwo.ca>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Please find enclosed in the next two emails the two patches for LU-6808 ported to the in-tree staging lustre client driver in the 4.12 release.

https://jira.hpdd.intel.com/browse/LU-6808

Fan Yong (1):
  LU-6808 ptlrpc: properly set "rq_xid" for 4MB IO

Niu Yawei (1):
  LU-6808 ptlrpc: no need to reassign mbits for replay

 drivers/staging/lustre/lustre/ptlrpc/client.c | 40 +++++++++++++++++++--------
 1 file changed, 29 insertions(+), 11 deletions(-)

-- 
2.14.0
