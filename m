From: John Bauer <bauerj@iodoctors.com>
Date: Sun, 26 Jun 2016 14:17:15 -0500
Subject: [lustre-devel] [lustre-discuss] more on lustre striping
In-Reply-To: <22ECFBA2-BD72-4751-8B92-E58D6FEAD9FF@intel.com>
References: <1ef5a267-334c-be0d-13f4-c0fab917d1bf@iodoctors.com>
	<38EA9F32-3869-43BA-B215-EB2E5BA62FD5@intel.com>
	<f4c0c992-1e1a-41d8-7a04-2fc5182c6b31@iodoctors.com>
	<01EE2B9D-2359-49B5-A50F-E7C2D97E6696@intel.com>
	<44e2353d-3bef-ddd7-f15e-ad4bfdda040f@iodoctors.com>
	<EB476743-98B4-49D3-B436-7F257E3284DD@intel.com>
	<9ebe9f4c-d5a2-4c93-4f00-49029850cbbe@iodoctors.com>
	<575AB28E.7090404@pittman.co.uk>
	<8a9e4e45-ea99-1147-5c58-94a73d9010a8@iodoctors.com>
	<22ECFBA2-BD72-4751-8B92-E58D6FEAD9FF@intel.com>
Message-ID: <dc33401b-be85-72b1-0215-1fb666a352cd@iodoctors.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Oleg

I have written a simple test case that addresses your suggestions.  My 
simple test program now calls __open() and the LD_PRELOAD'd shared 
object, libopen.so, exports __open().  The attached tar file creates a 
directory stdio.  cd into it and *make clean all*. Then run 
*./stdio.csh*.  You will see that the program's call to __open() is 
intercepted, as evidenced by the fprintf() from the preloaded __open().  
But the open() call made by fopen() is still not reported by the 
preloaded function.  I am thoroughly convinced fopen()'s call to open(), 
by whatever name it is using for open(), can not be intercepted.  The 
most compelling evidence is the output from the run-time loader when 
LD_DEBUG=all is set. If I remove the call to __open() from the test 
program, the only function with open in its name that the run-time 
loader reports searching for is fopen().  The call that fopen() makes to 
open() is probably satisfied when libc is built.

Per Andreas's suggestion, I have tried to build a debug version of 
glibc, but I think this is a bit outside my wheelhouse.  It always turns 
into some type of struggle to get glibc to build correctly for the 
system I am on.  I am seeking assistance on that front from admins on 
the system I am using.  This URL is an interesting read, 
http://blog.hostilefork.com/where-printf-rubber-meets-road/  .  It 
covers the write() call from fprintf(), but I assume open() would have 
the same issues.  If I understand this correctly, the write() call from 
fprintf() boils down to a syscall at compile time.  It doesn't even 
bother will calling write().  glibc skips the step of calling write() 
and goes straight to syscall() when calling write() from inside of glibc.

Thanks again.

John


On 6/23/2016 4:50 PM, Oleg Drokin wrote:
> #include <unistd.h>
> >#include <stdlib.h>
> >#include <fcntl.h>
> >#include <stdio.h>
> >
> >int
> >main(int argc, char ** argv ){
> >    FILE *f = fopen("a", "r" ) ;
> >    fprintf(stderr,"f=%p\n",f);
> >    fclose(f);
> >}

-- 
I/O Doctors, LLC
507-766-0378
bauerj at iodoctors.com

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160626/41199577/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: stdio.tgz
Type: application/octet-stream
Size: 806 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160626/41199577/attachment.obj>
