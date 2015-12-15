From: Joe Perches <joe@perches.com>
Date: Tue, 15 Dec 2015 10:55:11 -0800
Subject: [lustre-devel] staging: lustre: Delete unnecessary goto
 statements in six functions
In-Reply-To: <567060C3.5070608@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<566D7830.9060000@users.sourceforge.net>
	<1450189676.3551.1.camel@perches.com> <20151215144133.GC5284@mwanda>
	<1450191751.3551.14.camel@perches.com> <20151215174844.GE5284@mwanda>
	<1450203011.4142.4.camel@perches.com>
	<56705B71.6090307@users.sourceforge.net>
	<1450204451.4142.19.camel@perches.com>
	<567060C3.5070608@users.sourceforge.net>
Message-ID: <1450205711.4142.23.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, 2015-12-15 at 19:49 +0100, SF Markus Elfring wrote:
> > I think there should _not_ be a hardened rule.
> I guess that it can become hard to achieve consensus on a precise rule.

Consensus isn't unanimity.

> I imagine that your feedback
> can cause further software development troubles if the acceptance for
> this update suggestion will really depend on the number of blank lines
> before a jump label.

<shrug>

The author of any particular bit of code can do
whatever they want.

Localized consistency is probably more valuable than
global consistency.
