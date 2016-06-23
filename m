From: Oleg Drokin <oleg.drokin@intel.com>
Date: Thu, 23 Jun 2016 17:50:29 -0400
Subject: [lustre-devel] [lustre-discuss] more on lustre striping
In-Reply-To: <8a9e4e45-ea99-1147-5c58-94a73d9010a8@iodoctors.com>
References: <1ef5a267-334c-be0d-13f4-c0fab917d1bf@iodoctors.com>
	<38EA9F32-3869-43BA-B215-EB2E5BA62FD5@intel.com>
	<f4c0c992-1e1a-41d8-7a04-2fc5182c6b31@iodoctors.com>
	<01EE2B9D-2359-49B5-A50F-E7C2D97E6696@intel.com>
	<44e2353d-3bef-ddd7-f15e-ad4bfdda040f@iodoctors.com>
	<EB476743-98B4-49D3-B436-7F257E3284DD@intel.com>
	<9ebe9f4c-d5a2-4c93-4f00-49029850cbbe@iodoctors.com>
	<575AB28E.7090404@pittman.co.uk>
	<8a9e4e45-ea99-1147-5c58-94a73d9010a8@iodoctors.com>
Message-ID: <22ECFBA2-BD72-4751-8B92-E58D6FEAD9FF@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I think what you are missing is that __open that you need to intercept comes from libc,
so it does not need to be bound from your file because your binary does not call it,
glibc calls it AND if your LD_PRELOAD'ed library defines it you'll catch it.

The proper test would have been to write a LD_PRELOADable library that
defines __open and then run your test application with it.


On Jun 10, 2016, at 12:04 PM, John Bauer wrote:

> To confirm the point that you can not intercept the open called by fopen by using LD_PRELOAD, I have written a simple test case.  Note that the runtime linker never looks for open().  Only fopen()
> $ cat a.c
> #include <unistd.h>
> #include <stdlib.h>
> #include <fcntl.h>
> #include <stdio.h>
> 
> int
> main(int argc, char ** argv ){
>    FILE *f = fopen("a", "r" ) ;
>    fprintf(stderr,"f=%p\n",f);
>    fclose(f);
> }
> $ file a
> a: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.32, BuildID[sha1]=dfe043b4ec8cf19d5fd3fab524d7c72ed1453574, not stripped
> $ cat a.csh
> #!/bin/csh
> setenv LD_DEBUG all
> ./a >&! a.cpr
> $ ./a.csh
> $ grep -i open a.cpr
>     120584:     symbol=fopen;  lookup in file=./a [0]
>     120584:     symbol=fopen;  lookup in file=/lib64/libc.so.6 [0]
>     120584:     binding file ./a [0] to /lib64/libc.so.6 [0]: normal symbol `fopen' [GLIBC_2.2.5]
> $
> 
> On 6/10/2016 7:29 AM, Ashley Pittman wrote:
>> On 22/05/16 02:56, John Bauer wrote:
>>> Oleg
>>> 
>>> I can intercept the fopen(), but that does me no good as I can't set the O_LOV_DELAY_CREATE bit.  What I can not intercept is the open() downstream of fopen().  If one examines the symbols in libc you will see there are no unsatisfied externals relating to open, which means there is nothing for the runtime linker to find concerning open's.  I will have a look at the Lustre 1.8 source, but I seriously doubt that the open beneath fopen() was intercepted with LD_PRELOAD.  I would love to find a way to do that.  I could throw away a lot of code. Thanks,  John
>> 
>> Could you not intercept fopen() and implement it with calls to open() and fdopen() yourself which would give you full control over what you're looking for here?
>> 
>> Ashley.
> 
> -- 
> I/O Doctors, LLC
> 507-766-0378
> 
> bauerj at iodoctors.com
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
