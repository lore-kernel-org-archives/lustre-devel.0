From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 10 Feb 2016 13:00:17 -0500
Subject: [lustre-devel] [PATCH 0/5] Few misc Lustre fixes
Message-ID: <1455127222-2557752-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This patchset fixes some minor Lustre problems and also
updates the internal version.

Please consider.

Oleg Drokin (5):
  staging/lustre/obdecho: Remove always true condition
  staging/lustre/obdecho: Better handle invalid create requests
  staging/lustre: Adjust import state history output format
  staging/lustre: Update internal client version.
  staging/lustre: Remove unused LUSTRE_VERSION_ALLOWED_OFFSET define

 drivers/staging/lustre/lustre/include/lustre_ver.h     | 18 ++++++------------
 .../staging/lustre/lustre/obdclass/lprocfs_status.c    | 14 +++++++-------
 drivers/staging/lustre/lustre/obdecho/echo_client.c    | 15 +++++----------
 3 files changed, 18 insertions(+), 29 deletions(-)

-- 
2.1.0
