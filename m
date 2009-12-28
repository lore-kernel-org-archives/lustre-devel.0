From: Mag Gam <magawake@gmail.com>
Date: Sun, 27 Dec 2009 19:49:01 -0500
Subject: [Lustre-devel] Fwd: The Lustre community and GIT
In-Reply-To: <0BF036E2-E2A0-4612-B567-4C78794B0C45@clusterstor.com>
References: <2b20c7140912130831t658c2790hb38c3752c18ec128@mail.gmail.com>
	<2b20c7140912131047qf0417f1mf3f3d9a8fc751dc0@mail.gmail.com>
	<5F225623-87E0-4A91-988C-8B789B63E46D@sun.com>
	<0BF036E2-E2A0-4612-B567-4C78794B0C45@clusterstor.com>
Message-ID: <1cbd6f830912271649n188095dcp9c65d96bd16eb71e@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I though majority of the lustre development and support was from Sun.
This is news to us.

Nevertheless I am glad Sun did this conversion.

Couple of questions:

1) What will happen to the Wiki? It still has a lot of Sun stuff on it (logo)
2) Will we still keep bugzilla.lustre.org?
3) Will there ever be a git over http? This is important for people
who are behind firewalls.

Also, it would be nice to have the RPMs on the Wiki instead of
registering with Sun.




On Sat, Dec 26, 2009 at 10:01 AM, Peter Braam
<peter.braam@clusterstor.com> wrote:
>
>
> Sent from my iPhone
>
> On Dec 15, 2009, at 14:05, Andreas Dilger <adilger@sun.com> wrote:
>
>> Hello Peter,
>>
>> As previously announced, we have already made the initial Lustre
>> repository available to everyone this week at git.lustre.org. ?This
>> repository contains all of the main development and release branches
>> and their history. ?It's where all of the Sun developers and
>> maintaners will get their sources from, and it will continue to be
>> available under the GPL v2 license as it always has been.
>>
>> Sun's policy of prioritizing stability, not just for releases but also
>> to underpin development, makes safeguarding the quality of this
>> repository paramount. ?Everyone contributing to the Lustre sources -
>> not just internal Sun engineers but also external contributors like
>> LLNL, CEA, ORNL and DDN - is therefore subject to the same gatekeeping
>> procedures and must follow the same patch submission, testing and
>> landing processes. ?These are further detailed in the wiki pages that
>> were in the original announcement:
>>
>> http://wiki.lustre.org/index.php/Accessing_Lustre_Code
>> http://wiki.lustre.org/index.php/Submitting_Patches
>>
>>
>
> Sun is no longer supporting the Lustre community (storage OEMs and
> others have been refused further support). ?The model you describe
> won't apply much longer I think. ?People will be looking for different
> arrangements.
>
> Peter
>
>
>
>> For people not familiar with Git, it should be clarified that
>> limiting commits to the Sun Prime repository does not in any way
>> restrict access to the Lustre code, or the ability of non-Sun
>> developers to share their own Git clone with the Lustre community.
>> Developers will be able to host their own Lustre clones (essentially
>> full repositories) as and where they wish. ?The major advantage of
>> Git is that anyone can pull from any repository, or in fact from a
>> number of different repositories at the same time - this choice is
>> left to the user.
>>
>> This is the same model used by the Linux kernel, and has proven to
>> work well with Git. ?Each kernel developer hosts their own clone(s)
>> at git.kernel.org, or at some other site like repo.or.cz, or github.com
>> , and when they have changes to submit upstream they send an email
>> (usually containing both the patch, and the git URL to pull from) to
>> the subsystem maintainer, or to Linus directly, requesting that he
>> pull their changes. ?This pull request is normally only sent after
>> the patch has been reviewed, possibly multiple times, ?by the
>> appropriate subsystem maintainers. ?Each developer has full control
>> over their own clone, and in fact it is rare that more than one
>> person has push access to a clone.
>>
>> The fact that there are many different clones (some more important,
>> and others less so) in no way implies that the kernel is being
>> forked, but rather that this is the standard way in which to use Git
>> to exchange changes. ?The location at which a clone is hosted also
>> has no bearing on its usefulness.
>>
>>
>>
>> To answer your specific concerns in more detail,
>>
>> On 2009-12-13, at 11:47, Peter Braam wrote:
>>> 1. We need a public repository, where non Sun community members can
>>> commit.
>>>
>>> a. ?There are Lustre users than have their own branches. ?LLNL has
>>> probably the best tested branch among all users. ?DDN's customers
>>> have a version of Lustre that includes patches not yet in Sun's
>>> releases. ?It would be very valuable if these kind of releases
>>> could be collected in a publicly accessible GIT repository.
>>
>> That is true even today - most of the patches that are in the DDN
>> branches were initially developed by Sun and are already in the
>> publicly-available Lustre CVS, and many of the LLNL patches have or
>> are being landed for the 1.8.2 release.
>>
>> As you know, there will always be a delta of patches that are not in
>> an official release, and will be available in the next one. ?With
>> the increase in testing to improve the quality of new releases
>> compared to the past, releases are by necessity less frequent.
>> Should anyone have a desire for more bleeding-edge code, they have
>> always been able fetch the current branch before its release,
>> regardless of whether this is Git or CVS. ?We maintain a number of
>> different branches (b1_8 for incremental development,
>> b_release_1_8_1 for critical fixes on the 1.8.1 release, etc) these
>> are already available to the public.
>>
>>> I doubt that Sun will give commit rights to external entities (this
>>> is not unreasonable, Sun needs to control what code enters its
>>> repositories). ?Hence I think that the community would be better
>>> served with a GIT repository in a public place, like github, that
>>> can give such access.
>>
>> While CVS was very restrictive in terms of managing external commit
>> permissions due to its monolithic repository, some external
>> contributors have had commit access to CVS prior our migration to
>> Git, based on need. ?With the migration to Git there is no need to
>> manage such access ourselves, as developers are able to host their
>> clones wherever they want. ?The git.lustre.org repository will
>> remain the canonical source for Sun releases, and we will be happy
>> to pull fixes into this repository that meet the quality guidelines
>> stated above. ?I for one would welcome external inspectors on
>> patches, and we continue to work with external sites to do scale
>> testing of Lustre.
>>
>>> My group at ClusterStor has reserved the "lustre" project at Github
>>> and we will give keys to any and all organizations that wish to
>>> make serious contributions to Lustre. ?I was in particular hoping
>>> that LLNL would be willing to commit their releases to that public
>>> place.
>>
>>
>> Note that with Git and github.com there is no need to give keys to
>> anyone, and in fact that would seem to be detrimental to
>> ClusterStor, because the "lustre" clone you have reserved is within
>> your company's private hosting space (i.e. http://github.com/clusterstor/lustre
>> ). ?With Github (or Git in general) it is possible for anyone to
>> make their own clone or mirror of a repository at any time, no keys
>> or permission required, and it will appear ashttp://github.com/
>> {user}/lustre or whatever they want to call it.
>>
>>> b. ?Everyone is uncertain about what Sun will do with Lustre
>>> (proprietary Solaris / ZFS server releases and discontinued support
>>> for Linux servers have been mentioned to me several times now). ?A
>>> public repository with the open code will be valuable for the
>>> community and promote continued development and access.
>>
>> I agree that a public repository is important, and we will continue
>> to host one at git.lustre.org as we have in the past for CVS, and it
>> can and should be cloned as needed. ?As you are hopefully aware,
>> with Git every checkout has a full copy of the repository, including
>> all history, so the code is already very "open" and "public".
>> Lustre is, and will continue to be, available as GPL software.
>>
>> We definitely welcome external contributions to Lustre, which have
>> in the past been done by a small number of people outside of Sun. ?I
>> don't think the choice of CVS or Git or hosting site has ever been a
>> limiting factor in this regard. ?We look forward to contributions of
>> fixes, designs, and features, from ClusterStor, as we would with any
>> Lustre contributor.
>>
>>> 2. We need MUCH more in the repository than Sun is putting into it.
>>>
>>> There are many development branches and sometimes abandoned
>>> projects that still have a lot of value. ?For example, there is a
>>> nearly complete OS X client port - what if someone wanted to pick
>>> that up? ?Similarly, there are projects like size on MDS or the
>>> network request scheduler that may need help from the community to
>>> get finished or re-prioritized.
>>
>> All of the Lustre history is still available in CVS, as it has
>> always been. ?As far as I know (I've never checked it out myself)
>> even the OS/X client port is publicly available today, which was not
>> true a few years ago.
>>
>> Due to the convoluted branch, repository, and tag abuse that was
>> used to manage the Lustre code in CVS, there is a non-zero effort
>> required to migrate any of the branches in CVS to Git. ?Rather than
>> bring all of the old detritus along into Git, only the main
>> development/production branches are being automatically migrated
>> initially.
>>
>> Now that the Git migration is complete, the Sun maintainers of non-
>> release features (HSM, SOM, CMD, NRS, etc) will be creating Git
>> clones and landing their work into them as time permits.
>>
>> If anyone wants to import one of the other CVS branches (e.g. OS/X),
>> all they will need to do is create a patch from that branch and then
>> commit this into their own Git clone.
>>
>>> It is unclear to me if these kind of branches can be found in the
>>> publicly available CVS.
>>
>> Yes, they can, as they always have been. ?The CVS repository will
>> remain available indefinitely for spelunking expeditions should the
>> need arise. ?Note that the full history that leads to the current
>> release branches (b1_6, b1_8, HEAD) is available in Git, so there is
>> at least a trail of breadcrumbs leading to where we are today.
>>
>>> If they can, a collection of relevant branches, broadly along the
>>> lines of what I mention above, should be placed in the public GIT
>>> repository.
>>
>> For currently-active branches this was already our plan. ?For
>> historical and inactive branches, and we welcome any contributions
>> that bring these ancient CVS branches back to life. ?Nikita is
>> probably best positioned to know what needs to be imported from the
>> OS/X branch in CVS, and if there are other particular branches that
>> contain important work we'll be happy to discuss them with you. ?It
>> will of course be possible to create Git clones for these old
>> branches as needed.
>>
>>> 3. Brian's email message seems to indicate that Sun's git
>>> repository will be used for Sun development. ?In the past there
>>> were two CVS repositories - a read-only one that was publicly
>>> accessible and when I last controlled the group it was updated very
>>> frequently with all open source code (presently, it seems to only
>>> contain releases, not the development stream of commits).
>>
>> That's not correct. ?The public cvs.lustre.org repository in fact
>> contains all of the Lustre commits and all of the history. ?I just
>> did a checkout and there are in fact tags and branches for the pre-
>> release 1.8.2 builds, lprocfs rewrite, CMD, etc. that are very much
>> works in progress.
>>
>> One of the very last commits on CVS HEAD was on Thursday before CVS
>> went read-only, from a patch submitted by LLNL:
>>
>> revision 1.593
>> date: 2009/12/10 13:52:51; ?author: dzogin; ?state: Exp; ?lines: +5 -0
>> Branch HEAD
>> b=21259
>> i=andrew.perepechko
>> i=alexey.lyashkov
>> ----------------------------------------------------------------------
>> Description: Allow non-root access for "lfs check".
>> Details ? ?: Added a check in obd_class_ioctl() for
>> OBD_IOC_PING_TARGET.
>>
>>
>>> It is unclear how Sun can manage development with this git
>>> repository given that parts of its work are proprietary (like the
>>> Windows port) or unreleased (like the ZFS work). ?Can we get more
>>> insight in what Brian is alluding to?
>>
>> I'm not sure what "alluding" you are alluding to?
>>
>> Of course, if there is any proprietary code developed it will just
>> not be pushed to the public git.lustre.org repository. ?I expect
>> that any proprietary or unreleased code that ClusterStor is already
>> or will develop will similarly not be posted publicly until you are
>> ready to do so.
>>
>> Sun's current in-progress code will very likely reside in separate
>> clones at git.lustre.org, but will not be merged into the Sun Prime
>> repository for an official release until it is inspected, tested,
>> and has permission to land. ?Pulls into the Sun Prime repository
>> will be done by the release manager for each branch, as previously
>> stated. ?The Lustre engineers at ClusterStor are already familiar
>> with this process and have already had their first patch pass
>> inspections and it is ready for landing.
>>
>> That is one of the major benefits of Git over CVS - that there ISN'T
>> a single repository, and in fact every clone has a full copy of the
>> history and can be used by anyone. ?There is no need to have all of
>> the development done in branches on a single repository, but rather
>> to keep projects in their own clones.
>>
>> That allows developers to do local commits on their machines, to
>> push it to their public clone if they want to share their work and/
>> or make an offsite backup, and people are free to choose which clone
>> one they use. ?Sun's Prime repository used for releases will only
>> contain stable Lustre code. ?This is the Git usage model for the
>> Linux kernel, and think it is a good one to follow for Lustre as
>> well. ?You are free to manage your clones in some other way.
>>
>> Cheers, Andreas
>> --
>> Andreas Dilger
>> Sr. Staff Engineer, Lustre Group
>> Sun Microsystems of Canada, Inc.
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>
