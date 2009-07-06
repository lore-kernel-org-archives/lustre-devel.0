From: Nicolas Williams <Nicolas.Williams@sun.com>
Date: Mon, 6 Jul 2009 17:42:03 -0500
Subject: [Lustre-devel] Recovering opens by reconstruction
In-Reply-To: <20090706173441.GL15302@Sun.COM>
References: <20090702223944.GR15302@Sun.COM> <op.uwh9t2mnatmt0c@garden>
	<20090703215528.GY15302@Sun.COM> <op.uwi7j3uaatmt0c@garden>
	<20090706173441.GL15302@Sun.COM>
Message-ID: <20090706224203.GZ15302@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jul 06, 2009 at 12:34:41PM -0500, Nicolas Williams wrote:
> On Sat, Jul 04, 2009 at 11:10:41AM +0400, Mikhail Pershin wrote:
> > That is more regression than benefit, having such kind of 'barrier' during  
> > recovery leads to longer recovery with not balanced server load. There are  
> > couple improvements on the way already to make recovery of each client  
> > more independent from others if possible, e.g. the transaction-based  
> > recovery can be replaced with version-based only. So adding new barriers  
> > is not good case in this terms
> 
> I'm not sure why a new stage would necessarily slow recovery in a
> significant way.  The new stage would not involve any writes to disk
> (though it would involve reads, reads which could then be cached and
> benefit the transaction recovery phase).

Also, as Oleg explained to me, most open state is for files whose opens
committed long ago, so most open state is recovered before other
transactions.  Which means we already have a separate open state
recovery phase -- it just isn't explicit.  So the only thing that
changes in my proposal is that all committed open state will be
recovered by anonymous open by FID reconstruction instead of by replay,
with all other transactions (including as-yet uncommitted opens) will be
recovered by replay.

There would be no new timeouts, and there should be no other negative
impact on recovery time/performance.  Recovery performance should
actually be improved, when replay signatures are enabled, since there
would be no need to verify replay signatures for more open state
recovery.

Nico
-- 
