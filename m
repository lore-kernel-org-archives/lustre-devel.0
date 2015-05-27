From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 27 May 2015 18:24:31 +0300
Subject: [lustre-devel] [PATCH 5/6] staging:lustre: style cleanups for
 lib-socket.c
In-Reply-To: <dd9883629dd64028b5c4e6a33d17a431@EXCHCS32.ornl.gov>
References: <uja.ornl@gmail.com>
	<1432319552-10479-6-git-send-email-jsimmons@infradead.org>
	<20150525093737.GS4150@mwanda>
	<dd9883629dd64028b5c4e6a33d17a431@EXCHCS32.ornl.gov>
Message-ID: <20150527152431.GS11588@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, May 27, 2015 at 03:01:37PM +0000, Simmons, James A. wrote:
> >>On Fri, May 22, 2015 at 02:32:31PM -0400, James Simmons wrote:
> >> @@ -167,13 +164,14 @@ lnet_ipif_enumerate (char ***namesp)
> >>  		if (nalloc * sizeof(*ifr) > PAGE_CACHE_SIZE) {
> >>  			toobig = 1;
> >>  			nalloc = PAGE_CACHE_SIZE/sizeof(*ifr);
> >> -			CWARN("Too many interfaces: only enumerating first %d\n",
> >> -			      nalloc);
> >> +			CWARN("Too many interfaces: only enumerating "
> >> +			      "first %d\n", nalloc);
> >>  		}
> >
> >Don't split string literals, it makes them hard to grep for.
> 
> Will fix. The CWARN will go over 80 characters but from the recent emails that is more acceptable.
> If this is the only problem then this patch set it ready.

Normally the right thing to do here would be to send a fixed
[patch 5/6 v2] using the --in-reply-to option so that it appears as a
reply to the original [patch 5/6].

> I have more patch series that are dependent
> on this first one. Should I push the other patch series with a note that it is dependent on the tcpip
> cleanup or wait until it is merged? Also how does one find out when the patch has been merged?

You will get an email when these are merged.

This is the only issue, I had.  No one else has complained so that means
no one else has any objections.  Greg hasn't merged it yet and he might
find a problem with it, but it seems like a straight forward patchset
so that's unlikely.

The only issue is that this patchset was sent in a confusing way.  It
doesn't have a v2 tag and it was tacked on to the old thread.  Greg
tends to not waste time being confused and just deletes the whole thread
when that happens.

The notes that "This depends on XXX being applied." are kind of nice but
no one spends a lot of time worrying about that stuff.  Greg just
applies the patches in the order that they hit his inbox and they either
apply or he tells people to update and resend.

So send your follow on patches.  If everything applies then good.  If
not then you can resend, which is a few commands in git and not a big
deal.

regards,
dan carpenter
