From: Ricardo M. Correia <Ricardo.M.Correia@Sun.COM>
Date: Wed, 28 May 2008 16:14:02 +0100
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <18493.29199.765234.755534@gargle.gargle.HOWL>
References: <C461688A.5460%peter.braam@sun.com>
	<1211984942.11750.29.camel@localhost>
	<18493.29199.765234.755534@gargle.gargle.HOWL>
Message-ID: <1211987642.4740.10.camel@localhost>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Qua, 2008-05-28 at 18:54 +0400, Nikita Danilov wrote:

> But that problem has to be solved anyway to implement per-user quotas
> for ZFS, correct?


Indeed, but it's probably easier and more reliable to make the DMU
itself update an internal quota/space accounting DMU object when a txg
is syncing (updating internal objects during txg sync is something that
the DMU already does, e.g., for spacemaps) than allow arbitrary
modifications to a transaction group after it has been closed.


> One possible solution I see is to use something like ZIL to log
> operations in the context of current transaction group. This log can be
> replayed during mount to update quota file.


Hmm.. I'm not sure if it would be easy to figure out during replay how
many blocks were freed, especially considering things like snapshots,
clones and deferred frees (if frees are making a txg sync to take too
long to converge, the DMU will add them to a freelist object, instead of
freeing them immediately).

I agree that quotas could be implemented in Lustre (independent of the
backend filesystem), but IMHO I think it would make more sense for the
space accounting to be done in the DMU itself due to the complexities
associated with it's internal behaviour.

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
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080528/86bce9ae/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 6g_top.gif
Type: image/gif
Size: 1257 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080528/86bce9ae/attachment.gif>
