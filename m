From: melanie gao <Melanie.Gao@Sun.COM>
Date: Mon, 08 Mar 2010 08:50:37 +0800
Subject: [Lustre-devel] build numbering for future Lustre releases
Message-ID: <4B9449DD.3070909@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

hello Lustre users,

My name is Melanie Gao.  I'm a program manager in the Lustre team and
will be managing the release that comes after 2.0.

We're making some changes to the way we number Lustre builds and I
wanted to give you a heads-up.  Here's a summary of the changes:

1. The first build of a release will be called 2.x.0.001.  So for
example for a Lustre 2.1 release, the first build would be 2.1.0.001.

2. We will increment the dot-dot-dot numbers monotonically (by one's
instead of by ten's).  That is to say, the builds will be numbered as
follows:
2.1.0.001
2.1.0.002
2.1.0.003

3. We will append "alpha" or "beta" at the end of every build so that
it's clear that it's not the GA build.  If the build is a milestone
build we'll append "alpha1" or "beta1".  That is to say, the builds will
be numbered as follows:
2.1.0.001.alpha (not a milestone)
2.1.0.002.alpha (not a milestone)
2.1.0.003.alpha1 (first alpha milestone build)
2.1.0.004.alpha (not a milestone)
2.1.0.005.alpha2 (second alpha milestone build)
...
2.1.0.012.beta1 (first beta milestone build)
2.1.0.013.beta (not a milestone)
2.1.0.014.beta2  (second beta milestone build)

4. The final GA build will have nothing appended at the end but we
will make it clear when we release it that it's the GA build.  Assuming
build 35 was the GA build for Lustre 2.1, the final build number
would be 2.1.0.035.

We are making changes to lustre-version.ac to accommodate these
changes.  You can see the progress of this work under bug #22234.

If you have any questions please respond to this email and I'll be happy
to answer them.

kind regards,
melanie
