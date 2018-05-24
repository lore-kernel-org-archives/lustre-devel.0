From: James Simmons <jsimmons@infradead.org>
Date: Thu, 24 May 2018 04:47:39 +0100 (BST)
Subject: [lustre-devel] The last task, netlink support for Lustre
Message-ID: <alpine.LFD.2.21.1805240441160.21947@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


So I'm reaching the finish line for the general breakage lustre
as that I worked on for the Intel branch. The last task is to
look at replacing the libcfs ioctl generic interface with the
netlink api. Al Viro has asked about using this API instead of
the strange redirection stuff Lustre does. Some real benefits to
moving to it. So the question is which interface to use. I see
direct use of netlink like the RDMA api uses. The second approach
is using the generic netlink API. That has the benefit of using
the libnl library. Lastly I see the connectors interface but
I don't see an advantage to using that interface.
