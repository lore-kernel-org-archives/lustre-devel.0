From: Mikhail Pershin <Mikhail.Pershin@Sun.COM>
Date: Tue, 07 Jul 2009 20:42:52 +0400
Subject: [Lustre-devel] Recovering opens by reconstruction
In-Reply-To: <20090707152105.GM5073@webber.adilger.int>
References: <20090702223944.GR15302@Sun.COM> <op.uwh9t2mnatmt0c@garden>
	<20090703215528.GY15302@Sun.COM> <op.uwi7j3uaatmt0c@garden>
	<20090706173441.GL15302@Sun.COM> <op.uwpaclw3atmt0c@garden>
	<20090707152105.GM5073@webber.adilger.int>
Message-ID: <op.uwph1qacatmt0c@garden>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, 07 Jul 2009 19:21:05 +0400, Andreas Dilger <adilger@sun.com> wrote:

> This actually has a second benefit in that we don't have to keep huge
> lists of open RPCs in the replay list that will be skipped each time we
> are trying to cancel committed RPCs.  For HPCS we need to handle 100k
> opens on a single client, and cancelling RPCs from the replay list is
> an O(n^2) operation since it does a list walk to find just-committed  
> RPCs.

Absolutely, all benefits are clear and I fully agree but all of them are  
not in reply signature context. I was just afraid that inside replay  
signature task such big changes will defer replay signature itself. But if  
we have time to make it in right way then it is good.

> Actually, the need to have separate recovery stages in HEAD is no longer
> needed.  The addition of extra replay stages was a result of fixing a bug
> in recovery where open file handles were not being replayed before  
> another client unlinked the file.  However, this has to be fixed for VBR  
> delayed
> recovery anyways, so we may as well fix this with a single mechanism
> instead of adding a separate recovery stage that requires waiting for
> all clients to join or be evicted before any recovery can start.
>
> The proper solution, as also needed by delayed recovery, is to move A
> to the PENDING list during replay and remove it at the end of replay.
> With 1.x we would have to also remove the inode from PENDING if some
> other node reuses that inode number, but since this extra recovery
> stage is only present in 2.0 and we will not implement delayed recovery
> for 1.x we can simply remove all unreferenced inodes from PENDING at
> the end of recovery (until delayed recovery is completed).

Exactly, that is what I meant and that is why I don't like another strict  
'stage'

>
> It would be possible to flag the unlink RPCs with a special flag (maybe
> just OBD_MD_FLEASIZE/OBD_MD_FLCOOKIE) to distinguish between unlinks
> that also destroy the objects, and unlinks that cause open-unlinked  
> files.
> For replayed unlinks that cause objects to be destroyed we know that
> there are no other clients holding the file open after that point and
> we don't have to put the inode into PENDING at all.

I've just thought about the same, it is quite obvious solution here.


-- 
Mikhail Pershin
Staff Engineer
Lustre Group
Sun Microsystems, Inc.
