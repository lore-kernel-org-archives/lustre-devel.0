From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Wed, 14 Oct 2015 00:19:25 +0200
Subject: [lustre-devel] [PATCH 0/7] staging: lustre: remove uses and
 definition of container_of0
Message-ID: <cover.1444774232.git.mahfouz.saif.elyazal@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

container_of0 can be replaced by the Linux kernel macro container_of.
The only difference is that container_of0 tries to evade type casting
when the pointer is erroneous or null. All uses of container_of0 have
been replaced by container_of and then the macro was removed in the last
patch.

Aya Mahfouz (7):
  staging: lustre: lcommon_cl.c: replace container_of0 by container_of
  staging: lustre: llite_nfs.c: replace container_of0 by container_of
  staging: lustre: lu_object.c: replace container_of0 by container_of
  staging: lustre: echo_client.c: replace container_of0 by container_of
  staging: lustre: osc_io.c: replace container_of0 by container_of
  staging: lustre: osc_object.c: replace container_of0 by container_of
  staging: lustre: remove container_of0 and __container_of

 drivers/staging/lustre/include/linux/libcfs/libcfs.h | 11 -----------
 drivers/staging/lustre/lustre/lclient/lcommon_cl.c   | 10 +++++-----
 drivers/staging/lustre/lustre/llite/llite_nfs.c      |  2 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c   |  6 +++---
 drivers/staging/lustre/lustre/obdecho/echo_client.c  |  2 +-
 drivers/staging/lustre/lustre/osc/osc_io.c           |  4 ++--
 drivers/staging/lustre/lustre/osc/osc_object.c       |  2 +-
 7 files changed, 13 insertions(+), 24 deletions(-)

-- 
2.4.2


-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
