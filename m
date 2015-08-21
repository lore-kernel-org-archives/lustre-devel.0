From: Di Natale, Giuseppe <dinatale2@llnl.gov>
Date: Fri, 21 Aug 2015 22:05:04 +0000
Subject: [lustre-devel] lctl conf_param vs set_param -P
Message-ID: <974262C966B9F640899A48EB96313E9A2B92D7@PRDEXMBX-08.the-lab.llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I just filed https://jira.hpdd.intel.com/browse/LU-7031 to keep track of the discussion on what to do regarding set_param -P so we don't lose it in the email chain.

Giuseppe
________________________________________
From: lustre-devel [lustre-devel-bounces at lists.lustre.org] on behalf of lustre-devel-request at lists.lustre.org [lustre-devel-request at lists.lustre.org]
Sent: Saturday, August 15, 2015 1:04 PM
To: lustre-devel at lists.lustre.org
Subject: lustre-devel Digest, Vol 103, Issue 2

Send lustre-devel mailing list submissions to
        lustre-devel at lists.lustre.org

To subscribe or unsubscribe via the World Wide Web, visit
        http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
or, via email, send a message with subject or body 'help' to
        lustre-devel-request at lists.lustre.org

You can reach the person managing the list at
        lustre-devel-owner at lists.lustre.org

When replying, please edit your Subject line so it is more specific
than "Re: Contents of lustre-devel digest..."


Today's Topics:

   1. Re: lctl conf_param vs set_param -P (Christopher J. Morrone)
   2. Re: lctl conf_param vs set_param -P (Dilger, Andreas)
   3. Re: lctl conf_param vs set_param -P (Christopher J. Morrone)


----------------------------------------------------------------------

Message: 1
Date: Fri, 14 Aug 2015 13:41:03 -0700
From: "Christopher J. Morrone" <morrone2@llnl.gov>
To: lustre-devel at lists.lustre.org
Subject: Re: [lustre-devel] lctl conf_param vs set_param -P
Message-ID: <55CE525F.3020505@llnl.gov>
Content-Type: text/plain; charset=windows-1252; format=flowed

I too am confused.  And a bit dismayed that there is so little in the
way of code comments to explain the intent.

Is it the intent of "set_param -P" that the specified changes only take
effect after components are restarted?  And if so, why?

How would a normal system administrator go about finding out what
settings are currently set permanently?

I read through LU-3155 and see the discussion about using a single llog
file for all nodes, so I will withhold comment about that for now.

 From a user-interface standpoint though, presenting a single namespace
for all nodes in the entire center seems like less than desirable
choice.  Might we not want to set settings differently on different
clusters (be they client or server clusters)?  Given that not all paths
under /proc have differentiating strings in their path, there are some
things that can only be set completely globally in this design.

And what about sites that use an MGS per filesystem, rather than a
single MGS for the entire site?  If one MGS says that the debug level
should be one value, and another says that the debug value should be
another value, is it entirely random which debug setting will appear on
any given node?

Chris

On 08/13/2015 03:43 PM, Di Natale, Giuseppe wrote:
> Greetings,
>
> In an effort to change test-framework.sh to not utilize the deprecated
> conf_param option in lctl, I stumbled upon what appears to be
> inconsistent behavior between lctl's conf_param and set_param -P
> options. The permanent option test-framework.sh is attempting to change
> is jobid_var. When using conf_param, any changes to the property are
> written to /proc/fs/lustre/jobid_var within a short period of time. This
> is not the case with set_param -P. The change is never reflected nor is
> it stored in some other file within /proc. I started digging into the
> MGS logs and found that the behavior for both are different (the
> relevant segments of the logs are attached to this email and are named
> accordingly). In short, it appears that conf_param attempts to apply the
> changes to all the targets while set_param does not (it does not
> recognize it as a global property). Can someone offer any insight on why
> the behavior appears to be different or provide insight on if this is
> incorrect behavior?
>
> Thanks,
> Giuseppe Di Natale
>
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>



------------------------------

Message: 2
Date: Sat, 15 Aug 2015 00:07:22 +0000
From: "Dilger, Andreas" <andreas.dilger@intel.com>
To: "Di Natale, Giuseppe" <dinatale2@llnl.gov>
Cc: "lustre-devel at lists.lustre.org" <lustre-devel@lists.lustre.org>
Subject: Re: [lustre-devel] lctl conf_param vs set_param -P
Message-ID: <D1F3DE3E.101528%andreas.dilger@intel.com>
Content-Type: text/plain; charset="us-ascii"

Coincidentally (or maybe that was what drove your investigations?), I'd just filed https://jira.hpdd.intel.com/browse/LU-7004 about this issue.  It looks like the "lctl set_param -P" feature needs more testing, and I've removed the deprecation warning for "lctl conf_param" for 2.8.

Cheers, Andreas
--
Andreas Dilger
Lustre Software Architect
Intel High Performance Data Division

On 2015/08/13, 4:43 PM, "lustre-devel on behalf of Di Natale, Giuseppe" <lustre-devel-bounces at lists.lustre.org<mailto:lustre-devel-bounces@lists.lustre.org> on behalf of dinatale2 at llnl.gov<mailto:dinatale2@llnl.gov>> wrote:

Greetings,

In an effort to change test-framework.sh to not utilize the deprecated conf_param option in lctl, I stumbled upon what appears to be inconsistent behavior between lctl's conf_param and set_param -P options. The permanent option test-framework.sh is attempting to change is jobid_var. When using conf_param, any changes to the property are written to /proc/fs/lustre/jobid_var within a short period of time. This is not the case with set_param -P. The change is never reflected nor is it stored in some other file within /proc. I started digging into the MGS logs and found that the behavior for both are different (the relevant segments of the logs are attached to this email and are named accordingly). In short, it appears that conf_param attempts to apply the changes to all the targets while set_param does not (it does not recognize it as a global property). Can someone offer any insight on why the behavior appears to be different or provide insight on if this is incorrect behavior?


Thanks,
Giuseppe Di Natale


------------------------------

Message: 3
Date: Fri, 14 Aug 2015 17:36:47 -0700
From: "Christopher J. Morrone" <morrone2@llnl.gov>
To: lustre-devel at lists.lustre.org
Subject: Re: [lustre-devel] lctl conf_param vs set_param -P
Message-ID: <55CE899F.5060403@llnl.gov>
Content-Type: text/plain; charset=windows-1252; format=flowed

It was coincidental this time.  We saw the deprecation message during
llmount.sh and figured that might be an easy first task for Giuseppe to
get familiarity with the patch submission process.  But it turned out to
be a little more difficult than I thought. :)

We might want to just remove the conf_param deprecation message
altogether.  I think there is more than just a simple bug in the
"set_param -P" implementation.  From what I am seeing, it looks to me
like we have some design issues.  Without anyone committed to working
out a better design and implementing it, set_param -P looks like
technical debt with no clear resolution in sight.  Maybe we should even
consider stripping it back back out of the tree.

Chris

On 08/14/2015 05:07 PM, Dilger, Andreas wrote:
> Coincidentally (or maybe that was what drove your investigations?), I'd just filed https://jira.hpdd.intel.com/browse/LU-7004 about this issue.  It looks like the "lctl set_param -P" feature needs more testing, and I've removed the deprecation warning for "lctl conf_param" for 2.8.
>
> Cheers, Andreas
> --
> Andreas Dilger
> Lustre Software Architect
> Intel High Performance Data Division
>
> On 2015/08/13, 4:43 PM, "lustre-devel on behalf of Di Natale, Giuseppe" <lustre-devel-bounces at lists.lustre.org<mailto:lustre-devel-bounces@lists.lustre.org> on behalf of dinatale2 at llnl.gov<mailto:dinatale2@llnl.gov>> wrote:
>
> Greetings,
>
> In an effort to change test-framework.sh to not utilize the deprecated conf_param option in lctl, I stumbled upon what appears to be inconsistent behavior between lctl's conf_param and set_param -P options. The permanent option test-framework.sh is attempting to change is jobid_var. When using conf_param, any changes to the property are written to /proc/fs/lustre/jobid_var within a short period of time. This is not the case with set_param -P. The change is never reflected nor is it stored in some other file within /proc. I started digging into the MGS logs and found that the behavior for both are different (the relevant segments of the logs are attached to this email and are named accordingly). In short, it appears that conf_param attempts to apply the changes to all the targets while set_param does not (it does not recognize it as a global property). Can someone offer any insight on why the behavior appears to be different or provide insight on if this is incorrect behavio

 r?
>
>
> Thanks,
> Giuseppe Di Natale
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>



------------------------------

Subject: Digest Footer

_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org


------------------------------

End of lustre-devel Digest, Vol 103, Issue 2
********************************************
