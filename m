From: Brian J. Murrell <brian.murrell@oracle.com>
Date: Wed, 24 Nov 2010 23:17:42 -0500
Subject: [Lustre-devel] Lustre tags
In-Reply-To: <4CED8F11.8090606@llnl.gov>
References: <4CED66BB.1010706@llnl.gov>
	<A76D5D7F-5FFD-4802-B298-2CAFCC0E9F98@oracle.com>
	<4CED8F11.8090606@llnl.gov>
Message-ID: <1290658662.18668.151.camel@pc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, 2010-11-24 at 14:17 -0800, Christopher J. Morrone wrote: 
> 

Christopher,

You probably realize all of this but to ensure that it's absolutely
clear...

> I hadn't done a fetch from prime in a couple of weeks, and when I just 
> did it I saw that v1_8_5_RC4 had been tagged 1.8.5.

Yes.  This signifies that our release candidate 4 of the 1.8.5 series
was what was released as the official 1.8.5.

> In that case, you 
> can see that the change to lustre-version.ac to make it 1.8.5 actually 
> happened several commits before the actual 1.8.5 tag.

That's right.  We have to change the version (lustre-version.ac) at the
start of the 1.8.5 release candidate testing phase so that when a
candidate is chosen, it can be released as it was created and tested and
not regenerated just for the purposes of final release.

Put another way, the exact same packages that were generated for the RC
and tested and passed our QA are then given to the users.  There is no
regeneration of packages after the chosen RC to produce "GA" packages.
This is to prevent any kind of silliness from being introduced into the
GA packages between the chosen RC and the GA release.

> I have no way of 
> knowing how long v1_8_5_RC4 was in existence before it became 1.8.5.

By "long" are you referring to linear time here?  Are you trying to
assess how much time elapsed while testing the final RC before it was
declared GA?

b.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: application/pgp-signature
Size: 198 bytes
Desc: This is a digitally signed message part
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20101124/d5149842/attachment.pgp>
