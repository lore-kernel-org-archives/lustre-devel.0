From: Ricardo M. Correia <Ricardo.M.Correia@Sun.COM>
Date: Wed, 28 May 2008 15:29:02 +0100
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <C461688A.5460%peter.braam@sun.com>
References: <C461688A.5460%peter.braam@sun.com>
Message-ID: <1211984942.11750.29.camel@localhost>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Ter, 2008-05-27 at 07:28 +0800, Peter Braam wrote:

> > Going aside, if I were designing quota from the scratch right now, I
> > would implement it completely inside of Lustre. All that is needed for
> > such an implementation is a set of call-backs that local file-system
> > invokes when it allocates/frees blocks (or inodes) for a given
> > object. Lustre would use these call-backs to transactionally update
> > local quota in its own format. That would save us a lot of hassle we
> > have dealing with the changing kernel quota interfaces, uid re-mappings,
> > and subtle differences between quota implementations on a different file
> > systems.
> 
> ======> IMPORTANT: get in touch with Jeff Bonwick now, let's get quota
> implemented in this way in DMU then.


I think this was proposed by Alex before, but AFAIU the conclusion is
that this was not possible to do with ZFS (or at least, not easy to do).

The problem is that ZFS uses delayed allocations, i.e., allocations
occur long after a transaction group has been closed, and therefore we
can't transactionally keep track of allocated space because by the time
the callbacks were called we are not allowed to write to the transaction
group anymore, since another 2 txgs could have been opened already.

Since this couldn't be done transactionally, if the node crashes, there
would be no way of knowing how many blocks had been allocated on the
latest (actually, the latest 2) committed transaction groups..

Regards,
Ricardo
--

Ricardo Manuel Correia
Lustre Engineering

Sun Microsystems, Inc.
Portugal
Phone +351.214134023 / x58723
Mobile +351.912590825
Email Ricardo.M.Correia at Sun.COM
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080528/a7e653b2/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 6g_top.gif
Type: image/gif
Size: 1257 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080528/a7e653b2/attachment.gif>
