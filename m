From: James Simmons <jsimmons@infradead.org>
Date: Sat, 26 Mar 2016 15:40:44 -0400
Subject: [lustre-devel] [PATCH 00/12] Bring the libcfs crypto code up to date
Message-ID: <1459021256-23857-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Several important fixes for the crypto handling are missing for
the upstream client. This work integates those missing fixes.

Andreas Dilger (12):
  staging: lustre: libcfs: limit scope of libcfs_crypto.h
  staging: lustre: libcfs: add documentation for cfs_crypto_hash_*()
  staging: lustre: libcfs: rename some variables for crypto handling
  staging: lustre: libcfs: add new definitions for cfs_crypto api
  staging: lustre: libcfs: small alignment change for cfs_crypto_hash_*()
  staging: lustre: libcfs: start using enum cfs_crypto_hash_alg
  staging: lustre: libcfs: bug fixes for cfs_crypto_hash_final()
  staging: lustre: libcfs: return proper error code for cfs_crypto_hash_speed()
  staging: lustre: libcfs: allocate memory in cfs_crypto_performance_test()
  staging: lustre: libcfs: print crypto performance result only on success
  staging: lustre: libcfs: improve reporting error for crypto performance
  staging: lustre: libcfs: calculate crypto performance using pages

 .../staging/lustre/include/linux/libcfs/libcfs.h   |    1 -
 .../lustre/include/linux/libcfs/libcfs_crypto.h    |  136 ++++------
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |  274 +++++++++++++++-----
 drivers/staging/lustre/lustre/include/obd_cksum.h  |    1 +
 drivers/staging/lustre/lustre/osc/osc_request.c    |    5 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |   12 +-
 6 files changed, 270 insertions(+), 159 deletions(-)
