From: Johann Lombardi <johann@sun.com>
Date: Wed, 04 Jun 2008 10:26:50 +0200
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <20080602232433.GS2961@webber.adilger.int>
References: <20080528080613.GN3582@lore> <C4682B4E.5615%peter.braam@sun.com>
	<20080602232433.GS2961@webber.adilger.int>
Message-ID: <20080604082650.GJ6283@lore>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jun 02, 2008 at 05:24:33PM -0600, Andreas Dilger wrote:
> Just a note - it isn't only shrinking of qunits that is possible, but also
> growth of qunits.  I think there was also work done to allow recall of
> qunits from the servers, but I'm not sure if it was landed into CVS.

Yes, this is included in the adaptive qunit patch. When qunit is shrunk,
the new value is broadcasted to the slaves which release the unused qunits.

> If we are significantly re-architecting quotas, I'd suggest that we also
> re-implement grants at the same time and use the DLM to do both of them.
> This way we can have grant + quota on a per-file basis (quota + grant are
> given to clients as part of extent lock LVB), and are also able to
> recall quota + grant.  We may not even want to have separate quota+grant,
> since we track the ownership of files on the OSTs and space allocation
> is done on a per-file basis.
>
> It would be possible, for example, to take a user's whole quota from
> the master, split it evenly into "num_osts * 2" chunks at mount time
> to pass to the OSTs, they further grant it to clients when they request
> extent locks, and then avoid ALL master->OST quota RPCs unless that user
> actually got close to exceeding their quota, either granting out some
> of the remaining "num_osts" qunits or recalling some of the outstanding
> quota (possibly via lock "conversion" to avoid revoking the quota lock).

I've been in favor of such an architecture too (see my previous emails).
The only "problem" is that it requires quite a lot of work.

Johann
