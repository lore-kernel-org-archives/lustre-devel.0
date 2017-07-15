From: James Simmons <jsimmons@infradead.org>
Date: Sun, 16 Jul 2017 00:00:31 +0100 (BST)
Subject: [lustre-devel] [PATCH] staging: lustre: lustre: fix all braces
 issues reported by checkpatch
In-Reply-To: <1500133974.4457.79.camel@perches.com>
References: <1500133162-29310-1-git-send-email-jsimmons@infradead.org>
	<1500133974.4457.79.camel@perches.com>
Message-ID: <alpine.LFD.2.20.1707152359420.15994@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> On Sat, 2017-07-15 at 11:39 -0400, James Simmons wrote:
> > Cleanup all braces that was reported by checkpatch. The only
> > issue not fixed up is in mdc_lock.c. Removing the braces in
> > the case of mdc_lock.c will break the build.
> 
> what checkpatch warning in mdc_locks.c is that?
> 
> $ ./scripts/checkpatch.pl -f --terse --nosummary drivers/staging/lustre/lustre/mdc/mdc_locks.c?
> drivers/staging/lustre/lustre/mdc/mdc_locks.c:590: WARNING: line over 80 characters
> drivers/staging/lustre/lustre/mdc/mdc_locks.c:600: WARNING: line over 80 characters
> drivers/staging/lustre/lustre/mdc/mdc_locks.c:637: WARNING: line over 80 characters

For 4.11-xxx kernels I was seeing

WARNING: braces {} are not necessary for any arm of this statement
#914: FILE: drivers/staging/lustre/lustre/mdc/mdc_locks.c:914:
+       if (it->it_op & IT_CREAT) {
[...]
+       } else if (it->it_op == IT_OPEN) {
[...]
+       } else {
[...]

Now it doesn't show up.
