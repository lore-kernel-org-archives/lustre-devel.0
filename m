From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Mon, 17 Oct 2016 23:45:30 +0200
Subject: [lustre-devel] [PATCH 0/2] staging: lustre: replace and remove
	class_devno_max
Message-ID: <cover.1476739569.git.mahfouz.saif.elyazal@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, lustre-devel@lists.lustre.org, linux-kernel@vger.kernel.org

class_devno_max is an inline function that is written with
the sole purpose of returning the value of MAX_OBD_DEVICES.
Since no computations are made by the class_devno_max, 
replace it with MAX_OBD_DEVICES.

Aya Mahfouz (2):
  staging: lustre: replace uses of class_devno_max by MAX_OBD_DEVICES
  staging: lustre: remove class_devno_max

 drivers/staging/lustre/lustre/include/obd_class.h  |  5 -----
 drivers/staging/lustre/lustre/obdclass/class_obd.c |  6 +++---
 drivers/staging/lustre/lustre/obdclass/genops.c    | 22 +++++++++++-----------
 .../lustre/lustre/obdclass/linux/linux-module.c    |  6 +++---
 4 files changed, 17 insertions(+), 22 deletions(-)

-- 
2.5.0


-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
