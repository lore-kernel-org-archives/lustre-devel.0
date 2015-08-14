From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Fri, 14 Aug 2015 13:41:03 -0700
Subject: [lustre-devel] lctl conf_param vs set_param -P
In-Reply-To: <974262C966B9F640899A48EB96313E9A2B3C90@PRDEXMBX-08.the-lab.llnl.gov>
References: <974262C966B9F640899A48EB96313E9A2B3C90@PRDEXMBX-08.the-lab.llnl.gov>
Message-ID: <55CE525F.3020505@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

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
