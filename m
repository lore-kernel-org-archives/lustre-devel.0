From: Joe Perches <joe@perches.com>
Date: Sat, 15 Jul 2017 08:52:54 -0700
Subject: [lustre-devel] [PATCH] staging: lustre: lustre: fix all braces
 issues reported by checkpatch
In-Reply-To: <1500133162-29310-1-git-send-email-jsimmons@infradead.org>
References: <1500133162-29310-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1500133974.4457.79.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Sat, 2017-07-15 at 11:39 -0400, James Simmons wrote:
> Cleanup all braces that was reported by checkpatch. The only
> issue not fixed up is in mdc_lock.c. Removing the braces in
> the case of mdc_lock.c will break the build.

what checkpatch warning in mdc_locks.c is that?

$ ./scripts/checkpatch.pl -f --terse --nosummary drivers/staging/lustre/lustre/mdc/mdc_locks.c?
drivers/staging/lustre/lustre/mdc/mdc_locks.c:590: WARNING: line over 80 characters
drivers/staging/lustre/lustre/mdc/mdc_locks.c:600: WARNING: line over 80 characters
drivers/staging/lustre/lustre/mdc/mdc_locks.c:637: WARNING: line over 80 characters
