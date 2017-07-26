From: James Simmons <jsimmons@infradead.org>
Date: Wed, 26 Jul 2017 11:37:57 -0400
Subject: [lustre-devel] [PATCH 0/2] staging: lustre: lov: fix sparse errors
	for fiemap
Message-ID: <1501083479-23069-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

The following error was reported by Dan Carpenter <dan.carpenter@oracle.com>

lov_object_fiemap() has following static checker warning:
drivers/staging/lustre/lustre/lov/lov_object.c:1241 lov_object_fiemap()
warn: signed overflow undefined. 'fm_start + fm_length < fm_start'

This patch set resolves those issues.

Bobi Jam (2):
  staging: lustre: lov: use u64 instead of loff_t in lov_object_fiemap()
  staging: lustre: lov: refactor lov_object_fiemap()

 drivers/staging/lustre/lustre/lov/lov_object.c | 461 +++++++++++++------------
 1 file changed, 235 insertions(+), 226 deletions(-)

-- 
1.8.3.1
