From: Mathias Rav <mathiasrav@gmail.com>
Date: Thu,  4 May 2017 12:13:37 -0400
Subject: [lustre-devel] [PATCH 0/2] staging: lustre: lprocfs: Fix coding
	style issues
Message-ID: <20170504161339.15901-1-mathiasrav@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

This patchset fixes two style issues in lprocfs_status.c related to
simple_strtoul and seq_printf (reported by checkpatch).

There's a slight change in lustre debugfs write semantics: Using kstrtox causes
EINVAL when the written number is followed by other (garbage) characters,
whereas previously the garbage would be ignored and such a write would succeed.

Mathias Rav (2):
      staging: lustre: lprocfs: Use kstrtouint_from_user
      staging: lustre: lprocfs: Use seq_puts

 .../lustre/lustre/obdclass/lprocfs_status.c        | 42 ++++++---------------
 1 file changed, 11 insertions(+), 31 deletions(-)
