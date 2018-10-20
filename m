From: James Simmons <jsimmons@infradead.org>
Date: Sat, 20 Oct 2018 19:52:16 +0100 (BST)
Subject: [lustre-devel] [PATCH 20/28] lustre: obdclass: deprecate
 OBD_GET_VERSION ioctl
In-Reply-To: <87a7ncc8a0.fsf@notabene.neil.brown.name>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
 <1539543498-29105-21-git-send-email-jsimmons@infradead.org>
 <87a7ncc8a0.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1810201947290.16676@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On Sun, Oct 14 2018, James Simmons wrote:
> >  
> > +		if (!warned) {
> > +			warned = true;
> > +			CWARN("%s: ioctl(OBD_GET_VERSION) is deprecated, use llapi_get_version_string() and/or relink\n",
> > +			      current->comm);
> > +		}
> 
> Is there a good reason not to use WARN_ON_ONCE() here?

Oh that is much nicer. Didn't know about it. Shall I submit a new
patch or will it be changed when applied to lustre-testing?
