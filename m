From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Tue, 10 May 2011 16:24:53 -0700
Subject: [Lustre-devel] Technical debt in the lustre build system
In-Reply-To: <201105100253.p4A2rNeE013093@hedwig.cmf.nrl.navy.mil>
References: <201105100253.p4A2rNeE013093@hedwig.cmf.nrl.navy.mil>
Message-ID: <4DC9C945.7050705@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 05/09/2011 07:53 PM, Ken Hornstein wrote:
>> So I'd like to start a discussion about where we need to go with the
>> build system.  Here are some of the things off the top of my head that
>> are problems that need to be addressed, or improvements that I think we
>> should make.
>> [...]
>
> I agree with everything you've said, but I'd like to add one thing:
>
> 9) Portability
>
>     This drives me nuts on the Mac port; the build system has a fair amount
>     of cruft left over (see autoMakefile versus Makefile.am, for starters).
>     If we're thinking about long-term plans on the build system, thinking
>     about portability is important.
>
>     (On the Mac, and AFAIK all other operating systems other than
>     Linux, building a kernel module is relatively straightforward;
>     just compile everything with a few extra options).

Yeah, that would be nice.

It does seem odd at first glance that most directories have both 
autoMakefile.am files and Makefile.in files.

I think that what is going on there is are essentially two independent 
build system: normal user-space build stuff (liblustre) uses the 
autoMakefile, and the kernel build system uses Makefile.  But in the 
end, Makefile does an "include autoMakefile", making one wonder why they 
need to be separate in the first place.

It is certainly worth investigating to see if that can be improved to be 
both more understandable and more portable.

Chris
