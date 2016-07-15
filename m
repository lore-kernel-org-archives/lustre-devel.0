From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Fri, 15 Jul 2016 06:14:13 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: o2iblnd: iov fixes for
	kiblnd_send
In-Reply-To: <72A3B3D7-69A3-40D4-8B89-103EB342E894@intel.com>
References: <1468257501-20630-1-git-send-email-jsimmons@infradead.org>
	<72A3B3D7-69A3-40D4-8B89-103EB342E894@intel.com>
Message-ID: <20160715051413.GI14480@ZenIV.linux.org.uk>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>
Cc: James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Lustre Development List <lustre-devel@lists.lustre.org>

On Fri, Jul 15, 2016 at 01:01:35AM -0400, Oleg Drokin wrote:

> > +	} else {
> > +		iov_iter_kvec(&from, ITER_KVEC | WRITE,
> > +			      payload_iov, payload_niov,
> > +			      payload_nob + payload_offset);
> > +	}
> > 	iov_iter_advance(&from, payload_offset);
> 
> Ah, I guess we added it there to then subtract here?

Yes (and that actually fixes a real bug there).

> Do you mind if I just merge this change into Al's patch with you as another
> Signed-off-by line instead?
> Since we caught this early, probably no point in having a breakage point in
> the history as it might break a future bisect.

No objections from me.  FWIW, I'd rather have all of that go through your
tree - it's independent from everything else in vfs.git and pulls quite
a bit from yours, so...
