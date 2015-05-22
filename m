From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 22 May 2015 18:39:29 +0300
Subject: [lustre-devel] [PATCH 1/3] staging:lustre: remove tcpip
 abstraction from libcfs
In-Reply-To: <4ebf8ca4e2dd466c8ff68291b6670515@EXCHCS32.ornl.gov>
References: <uja.ornl@gmail.com>
	<1432248378-28912-2-git-send-email-jsimmons@infradead.org>
	<20150522111536.GA19434@mwanda>
	<4ebf8ca4e2dd466c8ff68291b6670515@EXCHCS32.ornl.gov>
Message-ID: <20150522153929.GW22558@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, May 22, 2015 at 03:08:44PM +0000, Simmons, James A. wrote:
> >This patch does a lot of stuff all at once and it is hard to review.  It
> >could easily be broken into patches which are easy to review.
> 
> I have more very large patches. With breaking them up that means you are
> going to see hundreds of patches coming from me. 
> 

The problem here is that we have two upstreams which have diverged and
you're hopefully merging them into one upstream for the future.
Breaking things up into patches is a pain and it basically means you
have to do a lot of the work a second time.  It sucks for you and I
totally understand that...  :(

We regulary review 100+ patch series so that's not a big deal.

We still have to review a ball of code with it broken up or not broken
up but when it's broken up then I have scripts to strip out much of the
mechanical changes.

> >Ok in this next section we move functions around and rename them but
> >also introduce some bad changes in the new function.
> 
> Thanks for pointing out these bugs. We are still carrying these bugs in the
> OpenSFS branch. Once you approve these changes I will sync up lib-socket.c
> in the OpenSFS branch.
> 
> P.S
>       Does the 3rd patch look okay to you?

Yeah.  That looks fine.

regards,
dan carpenter
