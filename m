From: NeilBrown <neilb@suse.com>
Date: Fri, 25 May 2018 10:42:51 +1000
Subject: [lustre-devel] The last task, netlink support for Lustre
In-Reply-To: <alpine.LFD.2.21.1805240441160.21947@casper.infradead.org>
References: <alpine.LFD.2.21.1805240441160.21947@casper.infradead.org>
Message-ID: <871se0y390.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, May 24 2018, James Simmons wrote:

> So I'm reaching the finish line for the general breakage lustre
> as that I worked on for the Intel branch. The last task is to
> look at replacing the libcfs ioctl generic interface with the
> netlink api. Al Viro has asked about using this API instead of
> the strange redirection stuff Lustre does. Some real benefits to
> moving to it. So the question is which interface to use. I see
> direct use of netlink like the RDMA api uses. The second approach
> is using the generic netlink API. That has the benefit of using
> the libnl library. Lastly I see the connectors interface but
> I don't see an advantage to using that interface.

I'm sorry but I cannot help hear.  I never managed to work out what all
the excitement was about netlink.  I suspect it is a good idea as a lot
of clever people seem to like it, but I don't know what the good idea
is. :-(

I imagine ioctl to involved controlling things (io-control) while
I thought netlink was about getting information about things - a network
socket that delivers messages from the kernel to userspace.  So I don't
immediately see how netlink would replace ioctl.
Can you say more about what you know?  What does the libcfs ioctl do
that netlink would also be good for doing?

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180525/cd83b91d/attachment.sig>
