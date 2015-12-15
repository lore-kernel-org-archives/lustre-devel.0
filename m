From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 15 Dec 2015 16:00:34 +0100
Subject: [lustre-devel] staging: lustre: Less checks in
 mgc_process_recover_log() after error detection
In-Reply-To: <20151215114240.GB5284@mwanda>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<566D7952.7090401@users.sourceforge.net> <20151214110003.GV5284@mwanda>
	<566EB03E.2000007@users.sourceforge.net> <20151214123840.GX5284@mwanda>
	<566EB9D7.9090904@users.sourceforge.net> <20151214135750.GY5284@mwanda>
	<566EFFB3.708@users.sourceforge.net> <20151215114240.GB5284@mwanda>
Message-ID: <56702B12.6000805@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

> If you were a lustre dev then I would accept these renames definitely.

I find this information interesting.
Would any more contributors like to share their opinion?


> I do not think I have been unfair to you.

This view is correct in principle.


> There was no element of surprise.

I am trying to discuss further "special" update suggestions
where the topic focus might evolve to new directions.
I got the impression that you had some difficulties already
with my previous proposals. So I am unsure about the general
change acceptance from you alone.

You pointed out that you are maintainer for this software area.
I was not so aware about this detail while I noticed that
you are very active Linux software developer.
(You are not mentioned in the file "MAINTAINERS" for example.)


> Part of the reason we have CodingStyle is so that we can tell people
> "That's not in CodingStyle, that's just your own opinion so don't redo
> code just because you have a different opinion from the maintainer."

I find this description reasonable.

But I see some challenges to improve the coding style specification.
I would appreciate if some items can become less ambiguous and imprecise.
I assume that a few recommendations from the script "checkpatch.pl"
should also be mentioned there.

>
>> Are you generally willing to change the exception handling for
>> the memory allocations in the function "mgc_process_recover_log"
>> at all?
> I like the first patch in this series.

Thanks for a bit of positive feedback.


> I do not like the renames.

I guess that this design aspect can be clarified a bit more.


> I don't care too much about patches 5 and 6 except that they should be
> folded together and you should not move "req" and "eof" around.

I can understand this concern better than your first response
for these update steps.

I might send an adjusted patch series a few days later.


> Mostly I wish you would just focus on fixing bugs instead of these sorts
> of patches.

How often are deviations from the coding style also just ordinary bugs?

It seems that changes for this area are occasionally not so attractive
in comparison to software improvements for components
which are more popular.

Regards,
Markus
