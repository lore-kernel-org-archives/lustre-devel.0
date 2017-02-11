From: James Simmons <jsimmons@infradead.org>
Date: Sat, 11 Feb 2017 12:12:36 -0500
Subject: [lustre-devel] [PATCH 0/3] staging: lustre: llite: fixups for
	ll_migrate()
Message-ID: <1486833159-16251-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

This patch series covers all the current fixes for the function
ll_migrate(). Originally only the first patch was submitted but
it was pointed out other flaws existed in the code. Two more
patches that cover those flaws are included in this patch set.
These patches are order dependent.

Niu Yawei (1):
  staging: lustre: llite: check reply status in ll_migrate()

wang di (2):
  staging: lustre: llite: check request != NULL in ll_migrate
  staging: lustre: llite: root inode checking for migration

 drivers/staging/lustre/lustre/llite/file.c | 63 ++++++++++++++++--------------
 1 file changed, 34 insertions(+), 29 deletions(-)

--
1.8.3.1
