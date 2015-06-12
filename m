From: John Suykerbuyk <john.suykerbuyk@seagate.com>
Date: Fri, 12 Jun 2015 16:49:54 -0600
Subject: [lustre-devel] lustre design docs
In-Reply-To: <D1A0B005.F7226%andreas.dilger@intel.com>
References: <69BD0579-A188-4012-8926-3F55CF5E1BF9@seagate.com>
	<9EE73FB1-18B8-4ADC-86BE-1C059358F798@cray.com>
	<D1A0B005.F7226%andreas.dilger@intel.com>
Message-ID: <CA+sy+eTsv7UjX3ZLaC-ft=KHfjsdXtH8aew87RBFgvrM0=qskw@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Can you guys point me to where I should create my Lustre Quick Start Guide
(on KVM)?

It's my hope that someone will be able to take this and a machine capable
of hosting KVM virtual machines, and without anything but the publicly
accessible repositories, assemble and play around with a small (3 node)
Lustre virtual cluster.

- John "S"

On Fri, Jun 12, 2015 at 3:53 PM, Dilger, Andreas <andreas.dilger@intel.com>
wrote:

> I agree - there are a lot of documents spread across many places (old
> wiki, new wiki, opensfs wiki, HPDD wiki, old CVS "lustre-doc" repo, etc).
> Just getting those into a central location would be a good start.
>
> Obviously many of those documents are outdated, but I think even those
> would be valuable as long as it is clear at the top of the document what
> state it is in (e.g. having the date of origin and a description of the
> status like obsolete, stale, useful, up-to-date, etc).
>
> I think Richard has been uploading some of our more recent design docs to
> the new wiki, so that would be as good a place to start as any.
>
> Cheers, Andreas
>
> On 2015/06/12, 3:04 PM, "Justin Miller" <jmiller@cray.com> wrote:
>
> >I think a central document repository is a good idea, and would be a
> >valuable asset. The plan you outline to collect the documents and
> >metadata first and then convert the most useful documents to a
> >maintainable format makes a lot of sense. In addition to the benefits you
> >identify, it may also allow for the collection of some interesting
> >metrics.
> >
> >I?d be happy to help with this project.
> >
> >- Justin Miller
> >
> >
> >On 5/20/15, 1:06 PM, "lustre-devel on behalf of Vitaly Fertman"
> ><lustre-devel-bounces@lists.lustre.org on behalf of
> >vitaly.fertman at seagate.com> wrote:
> >
> >>Hi All,
> >>
> >>there was an idea to publish existing design docs on opensfs wiki.
> >>is centralised design repository interesting at all?
> >>
> >>currently the existing designs are not in the wiki format, mostly pdf,
> >>so this is
> >>not an ideal doc repository we want to have: not changeable, not
> >>maintainable,
> >>could be outdated, etc, but could be published very quickly.
> >>
> >>however, this is not the final step but just a beginning. at the same
> >>time, we may get
> >>some benefits immediately:
> >>- all the docs are gathered in one centralised place, faster doc search;
> >>- the fully documented product (although maybe not very up-to-date
> >>initially) ?
> >>attractive for many readers, especially newbies;
> >>- a quick jump to unknown code having a design, faster than reading the
> >>source code;
> >>
> >>after that, having these docs already published, next steps could be:
> >>- docs to be split on those which are to be maintained and left
> >>untouched;
> >>- a procedure of converting to be maintained docs to wiki format could
> >>be organised;
> >>- a procedure of updating converted docs to be organised;
> >>etc.
> >>
> >>would be valuable? thoughts?
> >>
> >>?
> >>Vitaly?
> >>_______________________________________________
> >>lustre-devel mailing list
> >>lustre-devel at lists.lustre.org
> >>http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
> >_______________________________________________
> >lustre-devel mailing list
> >lustre-devel at lists.lustre.org
> >http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
> >
>
>
> Cheers, Andreas
> --
> Andreas Dilger
>
> Lustre Software Architect
> Intel High Performance Data Division
>
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150612/2987d9d6/attachment.htm>
