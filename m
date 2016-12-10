From: James Simmons <jsimmons@infradead.org>
Date: Sat, 10 Dec 2016 13:05:56 -0500
Subject: [lustre-devel] [PATCH v2 0/5] Fix ups to make lustre_idl.h a proper
	UAPI header
Message-ID: <1481393161-22623-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons James Simmons <jsimmons@infradead.org>

From: James Simmons James Simmons <jsimmons@infradead.org>

Fix ups to make lustre_idl.h a proper UAPI header

The header lustre_idl.h is a UAPI header which contains extras
that don't belong. This patch set moves a bunch of very kernel
specific material out of the header. Lastly proper byteorder
functions are used so this file can build in user space as well.

Ben Evans (4):
  staging: lustre: obdclass: Create a header for obdo related functions
  staging: lustre: obdclass: style cleanup for obdo related functions
  staging: lustre: headers: sort headers affected by obdo move
  staging: lustre: headers: Move functions out of lustre_idl.h

James Simmons (1):
  staging: lustre: headers: use proper byteorder functions in lustre_idl.h

 .../lustre/lustre/include/lustre/lustre_idl.h      | 174 ++++-----------------
 drivers/staging/lustre/lustre/include/lustre_dlm.h |  13 ++
 .../staging/lustre/lustre/include/lustre_obdo.h    |  54 +++++++
 .../staging/lustre/lustre/include/lustre_swab.h    |   6 +
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |   6 +
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |  27 ++++
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |   6 +
 drivers/staging/lustre/lustre/obdclass/obdo.c      |  54 +++++++
 drivers/staging/lustre/lustre/osc/osc_io.c         |   2 +
 drivers/staging/lustre/lustre/osc/osc_request.c    |  16 +-
 10 files changed, 206 insertions(+), 152 deletions(-)
 create mode 100644 drivers/staging/lustre/lustre/include/lustre_obdo.h

--
1.8.3.1
