From: Nicolas Williams <Nicolas.Williams@sun.com>
Date: Tue, 7 Jul 2009 11:50:41 -0500
Subject: [Lustre-devel] Recovering opens by reconstruction
In-Reply-To: <op.uwph1qacatmt0c@garden>
References: <20090702223944.GR15302@Sun.COM> <op.uwh9t2mnatmt0c@garden>
	<20090703215528.GY15302@Sun.COM> <op.uwi7j3uaatmt0c@garden>
	<20090706173441.GL15302@Sun.COM> <op.uwpaclw3atmt0c@garden>
	<20090707152105.GM5073@webber.adilger.int>
	<op.uwph1qacatmt0c@garden>
Message-ID: <20090707165041.GG15302@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Jul 07, 2009 at 08:42:52PM +0400, Mikhail Pershin wrote:
> On Tue, 07 Jul 2009 19:21:05 +0400, Andreas Dilger <adilger@sun.com> wrote:
> >This actually has a second benefit in that we don't have to keep huge
> >lists of open RPCs in the replay list that will be skipped each time we
> >are trying to cancel committed RPCs.  For HPCS we need to handle 100k
> >opens on a single client, and cancelling RPCs from the replay list is
> >an O(n^2) operation since it does a list walk to find just-committed  
> >RPCs.

This seems like a problem that could be solved anyways, but then, having
to cache these RPCs forever is a waste of resources.

> Absolutely, all benefits are clear and I fully agree but all of them are  
> not in reply signature context. I was just afraid that inside replay  
> signature task such big changes will defer replay signature itself. But if  
> we have time to make it in right way then it is good.

Adding replay signature renewal just to avoid this restructuring seems
equally bad.  Not adding replay signature renewal and not bothering with
rekeying is OK in the short-term, but eventually it'd become a problem.
Given all the other benefits of doing committed open state recovery by
reconstruction, it seems like a good idea to just do it.

> >It would be possible to flag the unlink RPCs with a special flag (maybe
> >just OBD_MD_FLEASIZE/OBD_MD_FLCOOKIE) to distinguish between unlinks
> >that also destroy the objects, and unlinks that cause open-unlinked  
> >files.
> >For replayed unlinks that cause objects to be destroyed we know that
> >there are no other clients holding the file open after that point and
> >we don't have to put the inode into PENDING at all.
> 
> I've just thought about the same, it is quite obvious solution here.

An excellent idea.  Replay signatures would have to cover that bit.
I'll add that to the HLD.

Nico
-- 
