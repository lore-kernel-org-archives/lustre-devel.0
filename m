From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 14 Nov 2012 03:21:01 +0000
Subject: [Lustre-devel] [wc-discuss] Seeking contributors for Lustre
	User Manual
In-Reply-To: <20121113212642.GN31700@llnl.gov>
References: <CCC2E817.24EA%andreas.dilger@intel.com>
	<39D7B2E1-4DEE-4E13-9F35-A4E0B2C149C6@xyratex.com>
	<20121113212642.GN31700@llnl.gov>
Message-ID: <C0AA90B2-FE89-4290-8640-D55EF49AF618@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2012-11-13, at 14:26, Ned Bass <bass6@llnl.gov> wrote:

> On Tue, Nov 13, 2012 at 11:48:35AM -0800, Nathan Rutman wrote:
>> Would it be easier to move the manual back to a Wiki?  The low hassle
>> factor of wikis has always been a draw for contribution.  The openSFS
>> site is up and running with MediaWiki now (wiki.opensfs.org).
> 
> Easier? Yes, probably. Better? I personally don't think so.  Wikis are
> great collaboration tools for informally sharing information, but I
> don't think the paradigm scales well for documents of this size and
> complexity. And a wiki isn't the right tool for producing a formal
> professional-quality document, which is what I think the Lustre manual
> should strive to be.
> 
> True, we would lower the bar for contributions, but for that we would
> sacrifice the following features that I consider essential.
> 
> - Ability to export to multiple formats (pdf, html, epub) from one source
> - Consistency of formatting and navigation elements
> - A review process for proposed changes that assures a high standard of quality

Ned, these are the reasons we never moved the manual to a wiki in the first place.  The original manual at Oracle was in FrameMaker format and only two people could edit it. When we regenerated the manual again, it was converted into Docbook XML.

Since Docbook is a relatively lightweight plain text markup language, and we have good tools for validating the syntax along with WYSIWYG editing, so it is hopefully a good tradeoff between ease of editing and the feature set needed to produce the manual. 

The other major drawback of a wiki is that it only works online, so it can't (easily?) be saved to read on a plane or in a secure facility. 

> However, there are some short articles that probably do belong in the
> wiki that could be poached from the manual, i.e. installation and
> configuration procedures, etc.

Sure, and some of these exist (Richard's "Getting Started With Lustre" page). Definitely there could be a lot more effort out into this, however. 

> Ned
