From: Craig Inches <craig@craiginches.com>
Date: Sat, 18 Jun 2016 22:25:27 +0100
Subject: [lustre-devel] [PATCH 0/3] staging: luster: cl_object.h Checkpatch
	Cleanup
Message-ID: <cover.1466279901.git.craig@craiginches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Fix three different issues from checkpatch:
Line over 80 Chars
Unsigned int prefered over unsigned
Macros with complex values should be enclosed in parenthesis

Craig Inches (3):
  checkpatch style issue: Line over 80 char
  Checkpatch style issue:
  Checkpatch error cleanup

 drivers/staging/lustre/lustre/include/cl_object.h | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

-- 
2.7.3
