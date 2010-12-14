From: Brian J. Murrell <brian.murrell@oracle.com>
Date: Tue, 14 Dec 2010 11:57:02 -0500
Subject: [Lustre-devel] Cannot easily build from master source anymore
In-Reply-To: <4CF7ABC2.3000400@cea.fr>
References: <4CF6209A.6020401@cea.fr>
	<alpine.LFD.2.00.1012011944370.22096@casper.infradead.org>
	<DA432BB3-C1EC-433B-8936-923B98D7C446@oracle.com>
	<4CF7ABC2.3000400@cea.fr>
Message-ID: <1292345822.4080.46.camel@brian-laptop>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Aurelien,

On Thu, 2010-12-02 at 15:22 +0100, Aurelien Degremont wrote:
> >> Let me guess. 
> >>
> >> checking for stdint.h... yes
> >> checking for unistd.h... yes
> >> checking whether to configure just enough for make dist... no
> >> checking for buildid... configure: error: most recent tag found: v2_0_0 
> >> does not match current version 2.0.56.

Is this in fact the problem you run into?  You didn't actually say what
the problem you had was in your original posting, just that there was a
problem.  It's usually a good idea to at least print the error message
when you are reporting a failure.

> >> make: *** No rule to make target `rpms'.  Stop.
> >> make: *** No rule to make target `rpms'.  Stop.
> > 
> > My recollection from Brian's previous postings is that this is somehow related to an old "git" version being used.
> 
> We are using either git v1.5.5.6. Is this so old?

Hrm.  TBH, I don't think we've zeroed in on exactly which git version
resolved the problem, but you can use:

$ git describe --tags

To see what git thinks is the most recent tag in your source tree.  If
it's not a recent (i.e. it's v2_0_0) tag you likely have an old git.

> 
> > That said, I'd be happy to remove this as a requirement, and just stick with the version if there is a mismatch, printing only a warning if the git version is too old.
> 
> I think it will be a good idea

Hrm.  I suppose a configure option to either enforce the equality (i.e.
default to being lenient) or to allow inequality (i.e. default to being
strict) is certainly doable.  Personally, I'd prefer the latter since
it's what should happen and work fine when everything else (i.e. git) is
working fine.  Git being too old and not working properly seems to me
like something that should be handled as the exceptional case with a
option like "--with-old-git" or something.

In fact, if we can pinpoint the version (or even get close -- we can
refine it as we learn more) of git where the behaviour is corrected, we
can probably make it all implicit.  This is something I have been
considering as more and more evidence of old git installations is coming
to light.

Cheers,
b.
