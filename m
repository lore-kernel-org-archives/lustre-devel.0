From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 17:01:48 -0500
Subject: [lustre-devel] [PATCH 05/27] staging: lustre: remove annoying
	message in parse_nidrange
In-Reply-To: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
References: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456956130-6110-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Li Xi <lixi@ddn.com>

From: Li Xi <lixi@ddn.com>

When setting TBF rules of jobid, parse_nidrange() prints warning
messages. However, this is unnecessary and annoying since paring
a TBF rule will always try to parse the jobid like a nid.

Signed-off-by: Li Xi <lixi@ddn.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7647
Reviewed-on: http://review.whamcloud.com/17916
Reviewed-by: Emoly Liu <emoly.liu@intel.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/nidstrings.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index 9d1c7fd..ebf468f 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -270,7 +270,6 @@ parse_nidrange(struct cfs_lstr *src, struct list_head *nidlist)
 
 	return 1;
 failed:
-	CWARN("can't parse nidrange: \"%.*s\"\n", tmp.ls_len, tmp.ls_str);
 	return 0;
 }
 
-- 
1.7.1
