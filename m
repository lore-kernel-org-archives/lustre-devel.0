From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 15 Dec 2015 20:41:18 +0300
Subject: [lustre-devel] [PATCH 21/40] staging: lustre: improve LNet
	clean up code and API
In-Reply-To: <05bc05cb164b4d249f74683aef9c9d72@EXCHCS32.ornl.gov>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
	<1448062576-23757-22-git-send-email-jsimmons@infradead.org>
	<20151202125440.GS18797@mwanda>
	<05bc05cb164b4d249f74683aef9c9d72@EXCHCS32.ornl.gov>
Message-ID: <20151215174118.GD5284@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Dec 15, 2015 at 05:10:39PM +0000, Simmons, James A. wrote:
>I have been pondering if pushing bug fixes before style cleanups
> is the right thing to do.

Generally push the least controversial patches first so that if you
have to redo one patch, then the rest are already applied and don't need
to be changed.

> I pushed a bunch of bug fixes earlier and none got
> merged which either means Greg is just backed up and hasn't the time to
> merge them or  style issues are higher priority

I have no idea which patchset you are talking about so I can't comment.
Greg always (except if there is a mistake) applies things in first come
first serve order.  He doesn't sort them.

> Assuming these bug fixes are in scope of the staging tree. Should I
> continue to push this work first?

You've pushed a bunch of stuff.  I don't know which stuff has been
applied and which has not.  If no one replied to it and there isn't a
dire issue such as a compile failure or it doesn't apply then Greg is
likely to apply it.  He doesn't silently patches, so you will get an
email either way.

regards,
dan carpenter
