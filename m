From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Fri, 14 Aug 2015 17:36:47 -0700
Subject: [lustre-devel] lctl conf_param vs set_param -P
In-Reply-To: <D1F3DE3E.101528%andreas.dilger@intel.com>
References: <D1F3DE3E.101528%andreas.dilger@intel.com>
Message-ID: <55CE899F.5060403@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

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
> In an effort to change test-framework.sh to not utilize the deprecated conf_param option in lctl, I stumbled upon what appears to be inconsistent behavior between lctl's conf_param and set_param -P options. The permanent option test-framework.sh is attempting to change is jobid_var. When using conf_param, any changes to the property are written to /proc/fs/lustre/jobid_var within a short period of time. This is not the case with set_param -P. The change is never reflected nor is it stored in some other file within /proc. I started digging into the MGS logs and found that the behavior for both are different (the relevant segments of the logs are attached to this email and are named accordingly). In short, it appears that conf_param attempts to apply the changes to all the targets while set_param does not (it does not recognize it as a global property). Can someone offer any insight on why the behavior appears to be different or provide insight on if this is incorrect behavior?
>
>
> Thanks,
> Giuseppe Di Natale
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
