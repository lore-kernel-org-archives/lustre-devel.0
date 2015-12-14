From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 14 Dec 2015 15:38:40 +0300
Subject: [lustre-devel] [PATCH 5/7] staging: lustre: Less checks in
 mgc_process_recover_log() after error detection
In-Reply-To: <566EB03E.2000007@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<566D7952.7090401@users.sourceforge.net>
	<20151214110003.GV5284@mwanda>
	<566EB03E.2000007@users.sourceforge.net>
Message-ID: <20151214123840.GX5284@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Dec 14, 2015 at 01:04:14PM +0100, SF Markus Elfring wrote:
> >> A few checks would be performed by the mgc_process_recover_log() function
> >> even if it is known already that the passed variable "pages" contained
> >> a null pointer.
> >>
> >> * Let us return directly if a call of the kcalloc() function failed.
> >>
> >> * Move assignments for the variables "eof" and "req" behind
> >>   this memory allocation.
> > 
> > Why?
> 
> The positions of their initialisation depends on the selected exception 
> handling implementation, doesn't it?
> 
> Can you accept the proposed changes around the affected memory allocations?
> 

Just leave it as-is if there is no reason.

> 
> > Then in the next patch it moves again.
> 
> This detail is a matter of patch granularity.
> 
> 
> > It's like cup shuffle to read these patches sometimes.
> 
> Do you prefer to stash any changes together for a bigger update step?

Yes.  Patches 5 and 6 would be easier to review if they were folded into
one patch.

regards,
dan carpenter
