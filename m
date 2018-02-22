From: NeilBrown <neilb@suse.com>
Date: Fri, 23 Feb 2018 09:09:33 +1100
Subject: [lustre-devel] [PATCH 0/3] Three lustre bugfixes
Message-ID: <151933726925.16436.9827896439357574011.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

First two patches fix bugs that have been prevented the test suite
from finished for me - now it completes with about 10% of tests
failing.

Third patch fixes a tiny bug I noticed while reviewing another recent
patch to the same file.

Thanks,
NeilBrown

---

NeilBrown (3):
      staging: lustre: lov: use correct env in lov_io_data_version_end()
      staging: lustre: lmv: correctly iput lmo_root
      staging: lustre: lnet/selftest: don't ignore status from lstcon_test_add


 drivers/staging/lustre/lnet/selftest/conctl.c |    2 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c   |    2 +-
 drivers/staging/lustre/lustre/lov/lov_io.c    |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

--
Signature
