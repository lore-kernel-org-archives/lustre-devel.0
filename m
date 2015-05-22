From: Simmons, James A. <simmonsja@ornl.gov>
Date: Fri, 22 May 2015 15:08:44 +0000
Subject: [lustre-devel] [PATCH 1/3] staging:lustre: remove
	tcpip	abstraction from libcfs
In-Reply-To: <20150522111536.GA19434@mwanda>
References: <uja.ornl@gmail.com>
	<1432248378-28912-2-git-send-email-jsimmons@infradead.org>
	<20150522111536.GA19434@mwanda>
Message-ID: <4ebf8ca4e2dd466c8ff68291b6670515@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>This patch does a lot of stuff all at once and it is hard to review.  It
>could easily be broken into patches which are easy to review.

I have more very large patches. With breaking them up that means you are
going to see hundreds of patches coming from me. 

>Ok in this next section we move functions around and rename them but
>also introduce some bad changes in the new function.

Thanks for pointing out these bugs. We are still carrying these bugs in the
OpenSFS branch. Once you approve these changes I will sync up lib-socket.c
in the OpenSFS branch.

P.S
      Does the 3rd patch look okay to you?
