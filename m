From: Johann Lombardi <johann@sun.com>
Date: Wed, 28 May 2008 10:06:13 +0200
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <C461688A.5460%peter.braam@sun.com>
References: <18490.63940.619731.992500@gargle.gargle.HOWL>
	<C461688A.5460%peter.braam@sun.com>
Message-ID: <20080528080613.GN3582@lore>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello Peter,

On Tue, May 27, 2008 at 07:28:10AM +0800, Peter Braam wrote:
> >> When a slave runs out of its local quota, it sends an acquire request to the
> >> quota master. As I said earlier, the quota master is the only one having a
> >> global overview of what has been granted to slaves. If the master can satisfy
> >> the request, it grants a qunit (can be a number of blocks or inodes) to the
> >> slave. The problem is that an OST can return "quota exceeded" (=EDQUOT)
> >> whereas
> >> another OST is still having quotas. There is currently no callback to claim
> >> back the quota space that has been granted to a slave.
>
> Hmm - the slave should release quota.

I don't think that the slave can make such a decision by itself since it does
not know that we are getting closer to the global quota limit. Only the master
is aware of this.
Actually, the scenario I described above can no longer happen - with recent
lustre versions at least - thanks to the dynamic qunit patch because the
master broadcasts to all the slaves the new qunit size when it is shrunk.

Cheers,
Johann
