From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Date: Wed, 3 Jun 2015 22:12:55 +0530
Subject: [lustre-devel] [PATCH v3 4/7] staging:lustre: rename tcpip
 handling functions to lnet_* prefix
In-Reply-To: <60d0f4468f1b401ea3643d5efcdb0b2d@EXCHCS32.ornl.gov>
References: <1433341954-654-1-git-send-email-jsimmons@infradead.org>
	<1433341954-654-5-git-send-email-jsimmons@infradead.org>
	<20150603163323.GA5314@sudip-PC>
	<60d0f4468f1b401ea3643d5efcdb0b2d@EXCHCS32.ornl.gov>
Message-ID: <20150603164255.GC5314@sudip-PC>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Jun 03, 2015 at 04:38:36PM +0000, Simmons, James A. wrote:
> >On Wed, Jun 03, 2015 at 10:32:31AM -0400, James Simmons wrote:
> >> With all the TCPIP handling done in the lnet layer we should
> >> rename all the functions with the prefix lnet_*. One other
> >> change done was changing the remove argument of lnet_sock_getaddr
> >> from a int to a bool.
> >> 
> >> Signed-off-by: James Simmons <jsimmons@infradead.org>
> >checkpatch is complaining about unrecognized email address.
> 
> For some reason git format will mangle some of email addresses on me.
> Any idea why it does that?
sorry, no. maybe you need to report it as bug to git.

regards
sudip
> 
