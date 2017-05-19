From: Mathias Rav <mathiasrav@gmail.com>
Date: Thu, 18 May 2017 22:49:20 -0400
Subject: [lustre-devel] [PATCH v2 0/2] staging: lustre: lprocfs: Fix coding
	style issues
Message-ID: <20170519024922.15222-1-mathiasrav@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: mathiasrav@gmail.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

This patchset fixes two style issues in lprocfs_status.c related to
simple_strtoul and seq_printf (reported by checkpatch).

v1->v2:
  - Patch 1/2 now completely removes lprocfs_{rd,wr}_uint
  - Patch 2/2 unchanged

Mathias Rav (2):
      staging: lustre: Use kstrtouint_from_user in ldlm_rw_uint
      staging: lustre: lprocfs: Use seq_puts instead of seq_printf

 .../staging/lustre/lustre/ldlm/ldlm_resource.c    | 20 +++++++-
 .../lustre/lustre/obdclass/lprocfs_status.c       | 54 ++++-----------------
 2 files changed, 29 insertions(+), 45 deletions(-)
