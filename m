From: NeilBrown <neilb@suse.com>
Date: Tue, 13 Feb 2018 08:30:47 +1100
Subject: [lustre-devel] [PATCH 0/5] RESEND dcache/namei fixes for lustre
Message-ID: <151847081541.26699.3911837371411314092.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

Hi,
 this is a resend of some patches I send in August 2017.
 They fix a couple of little bugs in the namei-related code
 and clean up other bits.
 Only change is that one patch was dropped as other dcache changes
 made it irrelevant.

 There will be compiler warnings about a 'const' until a patch that I
 sent to Al Viro - and which he acknowledged - lands in the tree.

Thanks,
NeilBrown


---

NeilBrown (5):
      staging: lustre: llite: handle DCACHE_PAR_LOOKUP in ll_dcompare
      staging: lustre: llite: use d_splice_alias for directories.
      staging: lustre: llite: remove directory-specific code from ll_find_alias()
      staging: lluste: llite: simplify ll_find_alias()
      staging: lustre: llite: refine ll_find_alias based on d_exact_alias


 drivers/staging/lustre/lustre/llite/dcache.c |   10 ++++
 drivers/staging/lustre/lustre/llite/namei.c  |   60 +++++++++++++-------------
 2 files changed, 39 insertions(+), 31 deletions(-)

--
Signature
