From: Richard P Wagner <rpwagner@sdsc.edu>
Date: Wed, 14 Nov 2012 20:01:48 +0000
Subject: [Lustre-devel] Document Database Re: [Lustre-discuss]
 [wc-discuss] Seeking contributors for Lustre User Manual
In-Reply-To: <F6F6CD0F-3F76-4798-B7F2-90692BAB6AF5@fnal.gov>
References: <CCC2E817.24EA%andreas.dilger@intel.com>
	<39D7B2E1-4DEE-4E13-9F35-A4E0B2C149C6@xyratex.com>
	<20121113212642.GN31700@llnl.gov>,
	<F6F6CD0F-3F76-4798-B7F2-90692BAB6AF5@fnal.gov>
Message-ID: <91DB696E4F98904491C1D176DD6F8FDC1493DF35@XMAIL-MBX-BH2.AD.UCSD.EDU>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


________________________________________
From: Alex Kulyavtsev [aik at fnal.gov]
Sent: Wednesday, November 14, 2012 11:47 AM
To: Ned Bass
Cc: Nathan Rutman; <wc-discuss@whamcloud.com>; <lustre-discuss@lists.lustre.org>; lustre-devel at lists.lustre.org
Subject: Document Database Re: [Lustre-discuss] [wc-discuss] Seeking contributors for Lustre User Manual

On Nov 13, 2012, at 3:26 PM, Ned Bass wrote:

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

http://www.docbook.org ?

Sphinx http://sphinx-doc.org/?

All the multiple format benefits, with none of the XML. And I agree wholeheartedly that Wikis are not the best home for complex documentation.

--Rick

> - Consistency of formatting and navigation elements
> - A review process for proposed changes that assures a high standard of quality
- ability to track changes between document versions to incrementally update 'higher level' documents

>
> However, there are some short articles that probably do belong in the
> wiki that could be poached from the manual, i.e. installation and
> configuration procedures, etc.
Right.
And also the other way around: detailed articles on wiki written by developers can be later 'harvested' by professional writer into manual chapter, referencing to wiki for details.
Lowering entry bar is vital to encourage developers to write or update documentation.

DB:
In addition to wiki and "manual" it will be nice to have Document Database, where conference reports, RFCs, RFP, HLD, DLD, ... can be committed, updated and later searched.
Something like DocDB
        http://sourceforge.net/projects/docdb-v/
Document format can be any.
DocDB has been created to keep track of documentation in large collaboration - BTeV experiment -  and then used by several others. DocDB has ability to manage access rights to some documents.

I think we need all three - wiki, DocDB and manuals, they serve different purpose.

KB:
Right now lustre support tips and hints are living on lustre-discuss list. It is tedious to search emails (no tags,no links), and when the answer found, there is no guarantee it is still relevant.
It can be useful to accumulate tips and best practices in Knowledge Base and have mechanisms to update it, e.g. instead of answering directly to the list create entry in KB and post the ref. to the list.

Alex.

>
> Ned
> _______________________________________________
> Lustre-discuss mailing list
> Lustre-discuss at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-discuss
