From: Peter Braam <Peter.Braam@Sun.COM>
Date: Thu, 05 Jun 2008 04:09:41 -0700
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <20080605083957.GQ6283@lore>
Message-ID: <C46D1785.5811%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Quota are determined by the owner of the file, not by the uid of the
process.

We have been propagating owners / gid of files from MDS to OSS for this
reason.

I don't understand the issue.

Peter


> 
> I've discussed with Fanyong and imo, the uid mapping issue is clearly a
> showstopper for now. On HEAD, the client-side uid/gid packed by GSS is
> translated to a sevice-side uid/gid. This mapping exists on the MDS, but not
> on the OSSs. The problem is that for quotas, OSSs must be aware of this
> mapping.
> We should find a solution to this problem (not straightforward) which needs to
> be addressed anyway even for DMU support.
> 
> In general, I don't think that much of this work will be "throw away".
> 
> Cheers,
> Johann
