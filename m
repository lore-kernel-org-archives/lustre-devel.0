From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Fri, 6 Nov 2015 14:18:30 -0800
Subject: [lustre-devel] Should we have fewer releases?
In-Reply-To: <563CB0EF.5050005@cea.fr>
References: <D25FA9D2.89BFF%spitzcor@cray.com> <563A6351.4080407@llnl.gov>
	<D25FC1DB.89C48%spitzcor@cray.com> <563BCDDE.9060103@llnl.gov>
	<563CB0EF.5050005@cea.fr>
Message-ID: <563D2736.1010402@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I agree that the lack of public stable branches is an issue for many. 
But I also think that the topic of stable branches is somewhat 
orthogonal to the discussion about the development cycle on the master 
branch.  We can make these decisions about changing master's development 
process without knowing what we are going to do about stable branches in 
the future.

That said, there are some advantages to the three month release cycle 
that I propose that would help those who are hurting the most by the 
loss of the stable branches.

Assuming that we make these two changes:

1) Releases happen every three months on schedule
2) Releases are decouple from major releases (we don't hold up major 
releases for unfinished features, and it is fine to have a major release 
with no major feature)

Then the people most hurt by the lack of stable branches and the least 
able to purchase support contracts will see these benefits:

1) Less time to wait for a major release with relevant bugs fixes
2) Less reluctance to track the major releases

It is really in Lustre's best interest in general for us to move our 
development model in a direction that makes everyone less afraid of 
trying new versions of Lustre.  We don't have a good reputation there, 
but I think that is fixable if we make an effort.

Chris

On 11/06/2015 05:53 AM, DEGREMONT Aurelien wrote:
> Hi
>
> You're right for most of your comments.
>
> However, you forgot one important thing: there is no more public
> maintenance releases.
> Your theory is correct if Lustre releases get bugfix only minor releases
> (i.e: 2.7.1, 2.7.2, ...) like it uses to have.
>
> HPC centers cannot upgrade Lustre release very often. Usually they pick
> one and stick to it for a while, doing at most one or two major upgrades
> during the computer life cycle (lets say 5 years).
> The more Lustre releases they will be, the more scattering of Lustre
> versions in production they will be. As there is no more bugfix release
> made, admins need to regroup their efforts on fewer releases to benefit
> from debugging and patches produced by others, on the same Lustre release.
>
> Regarding lengthening the release cycle, I clearly agree that having
> longer landing window won't help at all. That means that lengthening
> release cycle only mean lengthening the code freeze window.
>
>
> Aur?lien
>
> Le 05/11/2015 22:45, Christopher J. Morrone a ?crit :
>> Hi,
>>
>> I think that Cory meant to send his message to this list.  Please read
>> his comment at the end before reading my reply here.
>>
>> Peter Jones is summarized in those notes as saying that how long
>> releases take seems to depend on how much change was introduce into
>> the tree.  I agree; this is a causal relationship.
>>
>> I believe that if our six months releases are often late and take in
>> the 7-9 month range, then I think that planned nine month releases
>> will in actuality take 12+ months.
>>
>> It may not be the current advocate's reason for suggesting the longer
>> release cycle, but one argument I have heard many times is that a
>> longer cycle will reduce the amount of manpower needed to create
>> releases.  I don't think that is substantially true.  While there are
>> some fixed costs in creating a release, there is no real reason that
>> those fixed costs need be a dominant factor for manpower demands.  On
>> the other hand, required manpower is almost always going to be
>> strongly proportional to, and dominated by, the amount of change we
>> introduce.
>>
>> If we perform excellent, in-depth reviews on all code changes and we
>> also perform strong testing throughout the development cycle, then the
>> manpower centered around "release time" need not be very high.  But
>> right now our peer reviews aren't quite as in depth as they could be,
>> and community testing, while improving of late, is unpredictably
>> applied and concentrated near the end of the cycle. This guarantees a
>> large and unpredictable amount of development effort shortly before
>> the release date, often resulting in a missed release target.
>>
>> So lets think about what happens if we extend the development cycle,
>> including extending freeze dates.  Assuming only minor, gradual
>> improvements in code reviews and continuous testing (a very safe
>> assumption, I think), the amount of change introduced into the release
>> will be proportionally higher the longer we leave the landing window
>> open.  The greater the change, the larger the amount of effort needed
>> to stabilize the code after the fact.
>>
>> Furthermore, I would speculate that extending the release cycle and
>> putting off the testing and stabilization effort will actually require
>> a super linear increase in the time for that effort.
>>
>> Consider for instance that the longer we make the release cycle, the
>> more likely that bug authors have moved on to another task or project.
>> Since this is an open source project we don't have any way to order
>> the bug author back to work on her code.  Even if the original author
>> is available to work on the bug, she may need significant time to
>> shift gears and remember how the code she touched works before she can
>> make significant progress.  If the original author is not available,
>> then someone else needs to learn that portion of code and that has
>> even more obvious impact on time to solution and release.
>>
>> I think there are also other effects that will conspire (e.g.
>> unexpected change interactions) to make the testing and stabilization
>> period grow super-linearly with the increase in the landing window.
>>
>> Therefore, I would argue that lengthening the release cycle will
>> neither reduce our manpower needs nor result in more predictable
>> release dates.
>>
>> On the contrary, we need to go in the opposite direction to achieve
>> those goals.  We need to shorten the release cycle and have more
>> frequent releases.  I would recommend that we move to to a roughly
>> three month release cycle.  Some of the benefits might be:
>>
>> * Less change and accumulate before the release
>> * The penalty for missing a release landing window is reduced when
>> releases are more often
>> * Code reviewers have less pressure to land unfinished and/or
>> insufficiently reviewed and tested code when the penalty is reduced
>> * Less change means less to test and fix at release time
>> * Bug authors are more likely to still remember what they did and
>> participate in cleanup.
>> * Less time before bugs that slip through the cracks appear in a major
>> release
>> * Reduces developer frustration with long freeze windows
>> * Encourages developers to rally more frequently around the landing
>> windows instead of falling into a long period of silence and then
>> trying to shove a bunch of code in just before freeze. (They'll still
>> try to ram things in just before freeze, but with more frequent
>> landing windows the amount will be smaller and more manageable.)
>>
>> It was also mentioned in the LWG email that vendors believe that the
>> open source releases need to adhere to an advertised schedule.  Having
>> shorter release cycles with smaller and more manageable change will
>> directly contribute to Lustre releases happening on a more regular
>> schedule.
>>
>> Those same vendors tend to be concerned that they will not be able to
>> productise every single release if they happen on a three month
>> schedule.  It is important to recognize that a vendor's product
>> schedule need not be directly in sync with every community release. It
>> is actually quite common in the open source world for vendors to
>> select a version to productise, and skip over some community releases
>> to find the next version which they will productise.  Consider, for
>> instance, the Linux kernel.  RedHat selects a version of the kernel to
>> include in RHEL and then sticks with the base of code fore many
>> years.  They will backport changes as they see fit, but their base on
>> that release remains the same. The next kernel that they decide to
>> package in their product will skip over many of the upstream Linux
>> releases.
>>
>> Some Lustre vendors already operate this way, and the ones that do not
>> need to adapt to this common, successful open source model.
>>
>> Shortening the release cycle will help encourage and sustain an active
>> open source community of Lustre developers from a diverse set of
>> organizations.
>>
>> Conversely, lengthening the release cycle will result in less Lustre
>> stability and encourage stagnation.  It will make us less nimble, less
>> likely to meet the needs of our current user base, and slower to
>> expand into new markets.
>>
>> Lets start working through what process changes we will need to make
>> to shorten the development cycles and make lustre releases more often.
>>
>> Thanks,
>> Chris
>>
>> On 11/04/2015 01:16 PM, Cory Spitz wrote:
>>> Hello, Lustre developers.
>>>
>>> On today?s OpenSFS LWG teleconference call (notes at
>>> http://wiki.opensfs.org/LWG_Minutes_2015-11-04) I proposed that we
>>> change
>>> the Lustre release cadence from six months to nine months. Chris M.
>>> responded (below) that any discussion about development changes should
>>> happen here on lustre-devel.  I agree, developers need to be on-board.
>>>
>>> So what do you think about release changes?  What requirements do you
>>> have?  What issues would you have if OpenSFS changed the major release
>>> cadence to nine months?
>>>
>>> Thanks,
>>>
>>> -Cory
>>>
>>> On 11/4/15, 1:58 PM, "lwg on behalf of Christopher J. Morrone"
>>> <lwg-bounces at lists.opensfs.org on behalf of morrone2@llnl.gov> wrote:
>>>
>>>> On 11/04/2015 10:28 AM, Cory Spitz wrote:
>>>>
>>>>> Lustre release cadence
>>>>> We haven?t been good about hitting our 6 month schedules
>>>>> Cory proposed a 9 month cadence just to recognize reality. Certainly
>>>>> pros/cons to any scheme.  Should be up for discussion. How/when to
>>>>> decide?
>>>>
>>>> Any development change like that needs to be discussed on lustre-devel.
>>>>
>>>> Chris
>>>>
>>>> _______________________________________________
>>>> lwg mailing list
>>>> lwg at lists.opensfs.org
>>>> http://lists.opensfs.org/listinfo.cgi/lwg-opensfs.org
>>>
>>> _______________________________________________
>>> lustre-devel mailing list
>>> lustre-devel at lists.opensfs.org
>>> http://lists.opensfs.org/listinfo.cgi/lustre-devel-opensfs.org
>>>
>>
>> _______________________________________________
>> lustre-devel mailing list
>> lustre-devel at lists.lustre.org
>> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
> .
>
