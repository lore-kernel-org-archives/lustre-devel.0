From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Thu, 29 Oct 2015 02:52:50 +0200
Subject: [lustre-devel] [PATCH v3 0/5] Remove uses and definition of IS_PO2
Message-ID: <cover.1446079745.git.mahfouz.saif.elyazal@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Concerned with the removal of IS_PO2 by replacing its uses
with is_power_of_2 and then removing the definition.

The second version handled warnings indicated by kbuild test robot.
The third version handled checkpatch.pl warnings indicated by Sudip
Mukherjee.

Aya Mahfouz (5):
  staging: lustre: ldlm_extent.c: replace IS_PO2 by is_power_of_2
  staging: lustre: hash.c: Replace IS_PO2 by is_power_of_2
  staging: lustre: workitem.c: replace IS_PO2 by is_power_of_2
  staging: lustre: selftest.h: replace IS_PO2 by is_power_of_2
  staging: lustre: libcfs.h: remove IS_PO2 and __is_po2

 drivers/staging/lustre/include/linux/libcfs/libcfs.h | 7 -------
 drivers/staging/lustre/lnet/selftest/selftest.h      | 2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c     | 2 +-
 drivers/staging/lustre/lustre/libcfs/hash.c          | 3 ++-
 drivers/staging/lustre/lustre/libcfs/workitem.c      | 2 +-
 5 files changed, 5 insertions(+), 11 deletions(-)

-- 
2.4.2


-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
