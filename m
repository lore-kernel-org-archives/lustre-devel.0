From: James Simmons <jsimmons@infradead.org>
Date: Wed, 23 Nov 2016 18:01:16 -0500
Subject: [lustre-devel] [PATCH 0/4] staging: lustre: obd: reserve connection
	flags
Message-ID: <1479942080-30166-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Reserve several OBD_CONNECT_* flags for future use.

Fan Yong (4):
  staging: lustre: obd: reserve connection flag OBD_CONNECT_SUBTREE
  staging: lustre: obd: reserve connection flag OBD_CONNECT_LOCK_AHEAD
  staging: lustre: obd: reserve connection flag OBD_CONNECT_OBDOPACK
  staging: lustre: obd: reserve connection flag OBD_CONNECT_FLAGS2

 .../lustre/lustre/include/lustre/lustre_idl.h      |    6 +++++-
 .../lustre/lustre/obdclass/lprocfs_status.c        |    5 ++++-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |    3 ++-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |   16 ++++++++++++----
 4 files changed, 23 insertions(+), 7 deletions(-)
