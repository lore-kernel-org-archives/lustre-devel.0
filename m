From: Nikitas Angelinas <nikitas_angelinas@xyratex.com>
Date: Tue, 14 May 2013 16:23:08 +0100
Subject: [Lustre-devel] Interested in contributing to Lustre
In-Reply-To: <CDB7BB21.BC1B%spitzcor@cray.com>
References: <E0341800-5675-434B-9F1F-AB01C7B3950C@intel.com>
	<CDB7BB21.BC1B%spitzcor@cray.com>
Message-ID: <CAPj2jnnf2qVGMdYSNn_v2dgoSkvE_=XyHGEbTAvMF+fRHQ90Vw@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

In addition to the document Oleg has pointed out (which imho is probably
the best resource for a newcomer developer to start with), and the link
that Cory has provided which also includes documentation on some more
recent additions to the source (and is also a good source of information
for newcomers imo), some older HLDs can be found at
http://wiki.lustre.org/index.php/Architecture_-_Lustre_HLDs, and some newer
HLDs/architectural docs at
https://wiki.hpdd.intel.com/display/PUB/Whamcloud+Designs.

The Operations Manual is also quite useful i think, at
https://wiki.hpdd.intel.com/display/PUB/Documentation.

Added to all this, there are quite a few presentation slides and av
recordings from previous LUG/LAD or other events around the web that you
might find useful.

As Oleg has hinted, some of the information you may come across might be a
bit stale, as it applies to previous versions of the source, so please keep
in mind that whole subsystems that are referenced in a document you are
reading may have been completely replaced (by newer and better versions).
But don't let this be an issue, please ask here if something does not make
sense; people are usually quite keen to help.



Cheers,
Nikitas


On 14 May 2013 15:58, Cory Spitz <spitzcor@cray.com> wrote:

> Same disclaimer applies for http://wiki.lustre.org/lid/agi/agi.html.
>
> The OpenSFS CDWG has discussed bringing these documents up-to-date.
> Nothing concrete yet though.
>
> Thanks,
> -Cory
>
>
> On 5/14/13 1:49 AM, "Drokin, Oleg" <oleg.drokin@intel.com> wrote:
>
> >Additionally there's this pretty good (though stale in many parts now,
> >but still some other parts are ok and high level is certainly ok)
> >Lustre internals book: users.nccs.gov/~fwang2/papers/lustre_report.pdf?
> >
> >On May 13, 2013, at 5:34 PM, Prakash Surya wrote:
> >
> >> I wish you luck in your endeavour!
> >>
> >> Here are some links which might prove useful to you:
> >>
> >> * https://jira.hpdd.intel.com - New issues are opened here
> >>
> >> * http://review.whamcloud.com - New patches are reviewed here
> >>
> >> * https://wiki.hpdd.intel.com/display/PUB/Submitting+Changes - Some
> >>   info on the development cycle used by the Lustre project.
> >>
> >> Unfortunately, there isn't nearly enough documentation as there should
> >> be in the Lustre tree (especially for new comers), so feel free to ask
> >> questions.
> >>
> >> As far as potential projects, in my opinion, the project list you
> >> linked to is a bit dated. There are *many* open issues which need to be
> >> fixed, so I would suggest finding something that interests you on the
> >> JIRA bug tracker that I linked to above, since that is a more up to date
> >> source of information.
> >>
> >> If you are completely new, a good place to start is just downloading the
> >> git tree, building, and running the unit tests locally to get familiar
> >> with the project. Then you can start to modify the source and explore
> >> some of the areas that interest you.
> >>
> >> --
> >> Cheers, Prakash
> >>
> >> On Fri, May 10, 2013 at 06:03:27PM -0400, twanjari at andrew.cmu.eduwrote:
> >>> Hi all,
> >>>
> >>> I am a grad student at Carnegie Mellon University. I had my course
> >>>work in
> >>> advanced storage systems in previous semester, and I am interested to
> >>>work
> >>> on Lustre. I prefer to take up a project that could be completed in a
> >>> duration of a month or two.
> >>>
> >>> Since I am a novice w.r.t. my familiarity with Lustre code base, I seek
> >>> your opinion to choose a project from the list:
> >>> http://wiki.lustre.org/index.php/Lustre_Project_List
> >>>
> >>> My preferences (in order) are:
> >>> 1. fallocate() API - https://bugzilla.lustre.org/show_bug.cgi?id=15064
> >>> 2. kernel patch removal -
> >>>https://bugzilla.lustre.org/show_bug.cgi?id=21524
> >>> 3. ioctl() number cleanups -
> >>> https://bugzilla.lustre.org/show_bug.cgi?id=20731
> >>> I am also open to other suggestion.
> >>>
> >>> Any suggestions regarding code walkthrough or documentation to help
> >>> ramping up are also welcome.
> >>>
> >>> Thanks,
> >>> Tejas Wanjari
> >>>
> >>> _______________________________________________
> >>> Lustre-devel mailing list
> >>> Lustre-devel at lists.lustre.org
> >>> http://lists.lustre.org/mailman/listinfo/lustre-devel
> >> _______________________________________________
> >> Lustre-devel mailing list
> >> Lustre-devel at lists.lustre.org
> >> http://lists.lustre.org/mailman/listinfo/lustre-devel
> >
> >_______________________________________________
> >Lustre-devel mailing list
> >Lustre-devel at lists.lustre.org
> >http://lists.lustre.org/mailman/listinfo/lustre-devel
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>

-- 


------------------------------
For additional information including the registered office and the treatment of Xyratex confidential information please visit www.xyratex.com

------------------------------
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20130514/5e6a529b/attachment.htm>
