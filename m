From: Oleg Drokin <green@linuxhacker.ru>
Date: Wed, 16 Nov 2016 20:05:28 -0500
Subject: [lustre-devel] [PATCH 0/2] Lustre fixes
Message-ID: <1479344730-1131617-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

With multiple metadata RPCs code in now, these two fixes
become important.

Please consider.

Niu Yawei (2):
  staging/lustre/ptlrpc: track unreplied requests
  staging/lustre/ptlrpc: update imp_known_replied_xid on resend-replay

 .../staging/lustre/lustre/include/lustre_import.h  |   5 +
 drivers/staging/lustre/lustre/include/lustre_net.h |   3 +
 drivers/staging/lustre/lustre/obdclass/genops.c    |   2 +
 drivers/staging/lustre/lustre/ptlrpc/client.c      | 112 +++++++++++++++------
 drivers/staging/lustre/lustre/ptlrpc/import.c      |  34 +++++++
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |  29 +++++-
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |  24 +++++
 drivers/staging/lustre/lustre/ptlrpc/recover.c     |  14 +++
 8 files changed, 187 insertions(+), 36 deletions(-)

-- 
2.7.4
