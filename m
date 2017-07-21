From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Fri, 21 Jul 2017 11:11:35 +0530
Subject: [lustre-devel] [PATCH v2 0/3] Constify lustre attribute_group
	structures.
Message-ID: <1500615698-21001-1-git-send-email-arvind.yadav.cs@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, di.wang@intel.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

ttribute_groups are not supposed to change at runtime. All functions
working with attribute_groups provided by <linux/sysfs.h> work
with const attribute_group. So mark the non-const structs as const.

Arvind Yadav (3):
  [PATCH v2 1/3] staging: lustre: constify attribute_group structures.
  [PATCH v2 2/3] staging: lustre: ldlm: constify attribute_group structures.
  [PATCH v2 3/3] staging: lustre: obdclass: linux: constify attribute_group structures.

 drivers/staging/lustre/lustre/include/lprocfs_status.h      | 4 ++--
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c             | 2 +-
 drivers/staging/lustre/lustre/lmv/lproc_lmv.c               | 2 +-
 drivers/staging/lustre/lustre/lov/lproc_lov.c               | 2 +-
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c               | 2 +-
 drivers/staging/lustre/lustre/obdclass/linux/linux-module.c | 2 +-
 drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c | 2 +-
 drivers/staging/lustre/lustre/obdclass/lprocfs_status.c     | 2 +-
 drivers/staging/lustre/lustre/osc/lproc_osc.c               | 2 +-
 9 files changed, 10 insertions(+), 10 deletions(-)

--
1.9.1
