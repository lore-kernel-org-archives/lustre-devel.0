From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Tue, 15 Sep 2015 13:37:26 -0700
Subject: [lustre-devel] adding IOCTL for ping
In-Reply-To: <D21DABBC.C8F%jevans@cray.com>
References: <D21DABBC.C8F%jevans@cray.com>
Message-ID: <55F88186.50803@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Maybe there is just not enough detail in the proposal, but I am not 
seeing why associating this with NIDs is the right way to go.  I believe 
that the RAS work that would use the gossip protocol dealt, at least in 
part, with higher level concepts like targets.  The existing ptlrpc 
pinger pings targets, not NIDs.  That is one of the problematic design 
points of the existing system, that when N OSTs live on the same node 
clients need to send N pings to the same node.

Chris

On 09/15/2015 08:04 AM, Ben Evans wrote:
> Would there be any interest in adding an IOCTL to update the ping
> time/status for a particular NID?
>
> This should allow for implementation of a pinger in userspace which
> updates the kernel on the status of various NIDs, and if I understand
> the ping code well enough, would greatly curtail any pings that is sent
> by the kernel.
>
> This might allow for things like Eric?s gossip implementation to simply
> bolt on top of Lustre without any internal kernel changes, or for
> integration of external monitoring systems to tell Lustre that failovers
> have occurred, etc.
>
> -Ben Evans
>
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
