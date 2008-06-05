From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Thu, 05 Jun 2008 00:12:14 -0400
Subject: [Lustre-devel] hiding non-fatal communications errors
In-Reply-To: <20080604222008.GD2961@webber.adilger.int>
References: <018701c8c646$6a6d56a0$0281a8c0@ebpc>
	<C46C546F.57D1%peter.braam@sun.com>
	<20080604222008.GD2961@webber.adilger.int>
Message-ID: <E5C69299-B24B-439F-90F6-53398543C3B8@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Jun 4, 2008, at 6:20 PM, Andreas Dilger wrote:

> I suspect this could be adapted to allowing a fixed number of  
> retries for
> server-originated RPCs also.  In the case of LDLM blocking callbacks  
> sent
> to a client, a resend is currently harmless (either the client is  
> already
> processing the callback, or the lock was cancelled).

We need to be careful here and decide on a good strategy on when to  
resend.
E.g. recent case at ORNL (even if a bit pathologic) is they pound  
through
thousands of clients to 4 OSSes via 2 routers. That creates request  
waiting
lists on OSSes well into tens of thousands. When we block on a lock  
and send
blocking AST to the client, it quickly turns around and puts in his  
data...
at the end of our list that takes hundreds of seconds (more than  
obd_timeout,
obviously). No matter how much you resend, it won't help.
Now a good argument is before we kill such clients (or do any sort of  
resend),
perhaps it makes sense to check incoming queue to see if there is  
anything?
On the other hand that would be like half of request scheduler,  
probably, and
with such queues, it would take ages, I guess.
BTW, AT code changes lock waiting from obd_timeout to obd_timeout/2,  
why is that?
(when AT is disabled). All this is bug 15332.

Or was the resend meant just for initial RPC where we do not get a  
confirmation
soon? Yes, there it makes sense to retry soon, but this case above  
needs to be
still considered, since currently we do not retry writeouts too, which  
has as
much of a bad effect on dirty client caches, and of course all the  
above is very
true in such cases too.
Also without lnet patch in 15332, where small messages are prioritized  
on routers,
it is way too easy to timeout ast response because of router  
congestion and no
amount of resending would help then.

Bye,
     Oleg
