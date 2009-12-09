From: Alexey Lyashkov <alexey.lyashkov@clusterstor.com>
Date: Wed, 09 Dec 2009 09:57:10 +0300
Subject: [Lustre-devel] loadgen improvements
In-Reply-To: <20C3E301-9A42-47D9-A1A7-BA06814D396F@sun.com>
References: <3ed212d00912050521l530cefc4oc6c44afce48faaa@mail.gmail.com>
	<5250C925-EDB4-48FA-AD3C-AC37B212BB2B@sun.com>
	<1260335244.9521.114.camel@berloga.shadowland>
	<20C3E301-9A42-47D9-A1A7-BA06814D396F@sun.com>
Message-ID: <1260341830.9521.132.camel@berloga.shadowland>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, 2009-12-08 at 23:35 -0700, Andreas Dilger wrote:
> On 2009-12-08, at 22:07, Alexey Lyashkov wrote:
> > This can be something similar as
> >>
> >     pattern $name $pool_name $operation [$stripe_size [$stripe_count]]
> >
> > where
> > name - is pattern name
> > pool_name - is name of OST pools assigned to this pattern
> > operation - is one of READ or WRITE.
> > stripe_size - if set, workload need to setup LOV and add linkage  
> > between
> > LOV and OSC targets, and separate single operation to stripes.
> > stripe_count - if set, workload should be use for only part of OST  
> > pool
> > to each echo object.
> 
> Please do not use positional parameters.  That makes it nearly  
> impossible to change the input format in the future, or to skip some  
> fields and leave them as defaults.  This needs to use getopt() and  
> named parameters:
> 
>   --pool=pool_name, --stripe_size=N,  --stripe_count=N
This possible, but unlikely. because need will be save current pool
name, instead have parsed as single command.

And I don't have plan to rewrite loadgen to use getopt, instead of
current Parser() function which is used in lctl, lfs, and other.
But i agree about avoid position depended parameters.

How about this style
>>> pool $name { targets:"OST1, OST2" }
and
>>> pattern $pat { stripe_count:X stripe_size:Y block_size:Z };
and 
>>> clients $pattern { count:XX pattern: pat shared }
?


-- 
Alexey Lyashkov <alexey.lyashkov@clusterstor.com>
ClusterStor
