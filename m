From: Brian J. Murrell <Brian.Murrell@Sun.COM>
Date: Wed, 20 May 2009 14:41:21 -0400
Subject: [Lustre-devel] cvs question
In-Reply-To: <200905201939.16472.bs_lists@aakef.fastmail.fm>
References: <200905201939.16472.bs_lists@aakef.fastmail.fm>
Message-ID: <1242844881.22400.178.camel@pc.interlinx.bc.ca>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, 2009-05-20 at 19:39 +0200, Bernd Schubert wrote:
> Hello, 

Hi,

> cvs annotate lnet/libcfs/watchdog.c
> 
> 1.2          (eeb      09-Dec-04): static void lcw_cb(unsigned long data)
> 1.2          (eeb      09-Dec-04): {
> 1.2          (eeb      09-Dec-04):         struct lc_watchdog *lcw = (struct 
> lc_watchdog *)data;
> 1.2          (eeb      09-Dec-04):
> 1.2          (eeb      09-Dec-04):         ENTRY;
> 1.2          (eeb      09-Dec-04):
> 1.2          (eeb      09-Dec-04):         if (lcw->lcw_state != 
> LC_WATCHDOG_ENABLED) {
> 1.2          (eeb      09-Dec-04):                 EXIT;
> 1.2          (eeb      09-Dec-04):                 return;
> 1.2          (eeb      09-Dec-04):         }
> 1.2          (eeb      09-Dec-04):
> 1.2          (eeb      09-Dec-04):         lcw->lcw_state = 
> LC_WATCHDOG_EXPIRED;
> 1.2          (eeb      09-Dec-04):
> 1.6          (nathan   10-Feb-07):         /* NB this warning should appear on 
> the console, but may not get into
> 1.6          (nathan   10-Feb-07):          * the logs since we're running in 
> a softirq handler */
> 1.6          (nathan   10-Feb-07):
> 1.7          (nathan   26-Feb-07):         CWARN("Watchdog triggered for pid 
> %d: it was inactive for %lds\n",
> 1.7          (nathan   26-Feb-07):               (int)lcw->lcw_pid, 
> cfs_duration_sec(lcw->lcw_time));
> 1.6          (nathan   10-Feb-07):         lcw_dump(lcw);

Notice the revision numbers.  They are all off of HEAD, which on b1_6,
this file is almost certainly not.  Perhaps you need to add a "-r b1_6"
to your cvs annotate command.

b.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: application/pgp-signature
Size: 197 bytes
Desc: This is a digitally signed message part
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20090520/cc8f8ce7/attachment.pgp>
