From: James Simmons <jsimmons@infradead.org>
Date: Sun, 4 Nov 2018 21:29:47 +0000 (GMT)
Subject: [lustre-devel] [PATCH 04/28] lustre: ptlrpc: Do not assert when
 bd_nob_transferred != 0
In-Reply-To: <87pnw28xvx.fsf@notabene.neil.brown.name>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
 <1539543498-29105-5-git-send-email-jsimmons@infradead.org>
 <87va60cgjx.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1810212339590.6249@casper.infradead.org>
 <87pnw28xvx.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1811042054180.27308@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> >> On Sun, Oct 14 2018, James Simmons wrote:
> >> 
> >> > From: Doug Oucharek <dougso@me.com>
> >> >
> >> > There is a case in the routine ptlrpc_register_bulk() where we were
> >> > asserting if bd_nob_transferred != 0 when not resending.  There is
> >> > evidence that network errors can create a situation where
> >> > this does happen. So we should not be asserting!
> >> >
> >> > This patch changes that assert to an error return code of -EIO.
> >> >
> >> > Signed-off-by: Doug Oucharek <dougso@me.com>
> >> > WC-bug-id: https://jira.whamcloud.com/browse/LU-9828
> >> > Reviewed-on: https://review.whamcloud.com/28491
> >> > Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
> >> > Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
> >> > Reviewed-by: Oleg Drokin <green@whamcloud.com>
> >> > Signed-off-by: James Simmons <jsimmons@infradead.org>
> >> > ---
> >> >  drivers/staging/lustre/lustre/ptlrpc/niobuf.c | 8 ++++++--
> >> >  1 file changed, 6 insertions(+), 2 deletions(-)
> >> >
> >> > diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
> >> > index 27eb1c0..7e7db24 100644
> >> > --- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
> >> > +++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
> >> > @@ -139,8 +139,12 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
> >> >  	/* cleanup the state of the bulk for it will be reused */
> >> >  	if (req->rq_resend || req->rq_send_state == LUSTRE_IMP_REPLAY)
> >> >  		desc->bd_nob_transferred = 0;
> >> > -	else
> >> > -		LASSERT(desc->bd_nob_transferred == 0);
> >> > +	else if (desc->bd_nob_transferred != 0)
> >> > +		/* If the network failed after an RPC was sent, this condition
> >> > +		 * could happen.  Rather than assert (was here before), return
> >> > +		 * an EIO error.
> >> > +		 */
> >> > +		return -EIO;
> >> 
> >> This looks weird, and the justification is rather lame.
> >> I wonder if this is an attempt to fix the same problem that the smp_mb()
> >> in the previous patch was attempting to fix (and I'm not yet convinced
> >> that either is the correct fix).
> >
> > When the above condition happens the LASSERT ends up taking out the 
> > node with a panic which in turn kills the application running on the cluster.
> > When replaced with reporting an EIO error the node survives as well as the 
> > job. The job might fail at its IO but it wouldn't fail performing its work 
> > flow which is way more important.
> 
> Yes, a meaningless error is better than a crash, but a proper fix is
> better still.  As I said, my guess is that the memory barrier in the
> previous patch might have fixed the bug, so the LASSERT can remain.
> 
> Doug: is there any chance that this might be the case?

I got a hold of Doug and discussed this issue. So the answer is that the
original logs to track down the original problem no longer exist. So 
finding the original source of the problem can't be done at this point.
Would you be okay with a version of this patch with dump_stack() and
treat it as a debug patch. We really need to collect logs to figure out
the real problem. I will push a debug patch to OpenSFS branch since it
is more widely used.
