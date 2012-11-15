From: Ned Bass <bass6@llnl.gov>
Date: Wed, 14 Nov 2012 17:26:53 -0800
Subject: [Lustre-devel] [Lustre-discuss] [wc-discuss] Seeking
 contributors for Lustre User Manual
In-Reply-To: <CCC97D94.2646%andreas.dilger@intel.com>
References: <50A42E95.6030602@qmul.ac.uk>
	<CCC97D94.2646%andreas.dilger@intel.com>
Message-ID: <20121115012653.GP31700@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Nov 15, 2012 at 12:12:40AM +0000, Dilger, Andreas wrote:
>
> I would prefer to see a fix immediately rather than someone filing a
> ticket to describe the fix, since the documentation fix should be
> self-describing.  However, if there is a problem that isn't immediately
> resolved then a Jira ticket should be submitted in order to track the
> defect and allow assigning the work to someone.

LUDOC-11 seems to be a catch-all issue for submitting fixes to minor
problems like typos.  However it sounds like you're saying we can bypass
Jira altogether for such patches.  That would be nice; linking to a
ticket with no useful content doesn't serve any purpose that I can see.

The "Making changes to the Lustre Manual source" article currently
instructs the reader to "file an LUDOC bug for change tracking in Jira"
as the first step.  To avoid discouraging submission of minor fixes,
perhaps a more lightweight process for that case should be covered
first.  In particular, say either that minor fixes should reference
LUDOC-11 in the summary, or just omit the Jira reference altogether,
whichever is appropriate.

Ned
