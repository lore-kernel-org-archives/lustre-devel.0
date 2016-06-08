From: Binoy Jayan <binoy.jayan@linaro.org>
Date: Wed,  8 Jun 2016 13:20:40 +0530
Subject: [lustre-devel] [PATCH 0/2] *** staging: lustre: Replace semaphore
	lock with mutex ***
Message-ID: <1465372242-7116-1-git-send-email-binoy.jayan@linaro.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, lustre-devel@lists.lustre.org
Cc: Binoy Jayan <binoy.jayan@linaro.org>, driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>

Hi,

These are a set of patches which removes semaphores from:

drivers/staging/lustre  (lnet)

These are part of a bigger effort to eliminate all semaphores 
from the linux kernel.

They build correctly (individually and as a whole).

Thanks,
Binoy


Binoy Jayan (2):
  staging: lustre: lloop_device: Replace semaphore lo_sem with
    completion
  staging: lustre: lnet: Replace semaphore ln_rc_signal with completion

 drivers/staging/lustre/include/linux/lnet/lib-types.h |  3 ++-
 drivers/staging/lustre/lnet/lnet/router.c             |  9 +++++----
 drivers/staging/lustre/lustre/llite/lloop.c           | 14 +++++++-------
 3 files changed, 14 insertions(+), 12 deletions(-)

-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project
