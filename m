From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Tue, 17 Nov 2015 22:06:02 +0200
Subject: [lustre-devel] [PATCH 0/2] Remove the last use and definition of
	IS_PO2
Message-ID: <cover.1447790571.git.mahfouz.saif.elyazal@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Concerned with the removal of IS_PO2 by replacing its use
with is_power_of_2 and then removing the definition.

Aya Mahfouz (2):
  staging: lustre: hash.c: Replace IS_PO2 by is_power_of_2
  staging: lustre: libcfs.h: remove IS_PO2 and __is_po2

 drivers/staging/lustre/include/linux/libcfs/libcfs.h | 7 -------
 drivers/staging/lustre/lustre/libcfs/hash.c          | 3 ++-
 2 files changed, 2 insertions(+), 8 deletions(-)

-- 
2.4.3


-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
