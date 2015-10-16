From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Sat, 17 Oct 2015 00:03:39 +0200
Subject: [lustre-devel] [PATCH 0/4] Remove uses and definition of IS_PO2
Message-ID: <cover.1445032901.git.mahfouz.saif.elyazal@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Concerned with the removal of IS_PO2 by replacing its uses
with is_power_of_2 and then removing the definition

Aya Mahfouz (4):
  staging: lustre: ldlm_extent.c: replace IS_PO2 by is_power_of_2
  staging: lustre: hash.c: replace IS_PO2 by is_power_of_2
  staging: lustre: workitem.c: replace IS_PO2 with is_power_of_2
  staging: lustre: remove IS_PO2 and __is_po2

 drivers/staging/lustre/include/linux/libcfs/libcfs.h | 7 -------
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c     | 5 ++++-
 drivers/staging/lustre/lustre/libcfs/hash.c          | 4 +++-
 drivers/staging/lustre/lustre/libcfs/workitem.c      | 4 +++-
 4 files changed, 10 insertions(+), 10 deletions(-)

-- 
2.4.2


-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
