From: Light&ColoR <eternalregion@163.com>
Date: Fri, 7 Dec 2012 10:26:36 +0800 (CST)
Subject: [Lustre-devel] Question of transplanting Lustre to a non-x86
 arch
In-Reply-To: <50C111B6.8060909@llnl.gov>
References: <220a56d5.1c243.13b64b93c40.Coremail.eternalregion@163.com>
	<8CF388B6-4A59-4B17-A71E-D31B1AFD955A@whamcloud.com>
	<1a9c0f60.edf4.13b6a28a653.Coremail.eternalregion@163.com>
	<50BF9B03.5090402@llnl.gov>
	<2188ef43.13dad.13b6e07218a.Coremail.eternalregion@163.com>
	<50C111B6.8060909@llnl.gov>
Message-ID: <2ab3c5f8.54be.13b732f95be.Coremail.eternalregion@163.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Thx, Chris, it's really helpful to me. Right, I use Linux, and I saw the architecture-specific code exactly in some of these kernel patches.  Although I need servers and clients, I think there is not too much work to do.....^ ^
At 2012-12-07 05:44:22,"Christopher J. Morrone" <morrone2@llnl.gov> wrote:
>I make it my doing something like this:
>
>sh autogen.sh && ./configure && make rpms
>
>:)
>
>I'll assume that you are running Linux, and only want to build the 
>Lustre client.
>
>Looking at Lustre's master branch, I'm not seeing 100+ lines of assembly 
>in the main code.  Most of the assembly seems to be in code for darwin 
>OS and windows, and you can just ignore that.
>
>It looks like commit 5a562259fce98b15f519fab7dd8cb921e8445d7b might be a 
>problem for you.  There is a sloppy architecture check in the automake file:
>
>   +AM_CONDITIONAL(ARCH_x86, test x$target_cpu != "xpowerpc")
>
>In my opinion, the files really should have been put in an 
>architecture-specific subdirectory too.
>
>The only other place I see assembly is in the a patch for the kernel, 
>and if you are only running Linux clients, you don't need the kernel 
>patches.
>
>To compile lustre without the server code, you'll want this configure 
>option:
>
>   ./configure --disable-server
>
>Chris
>
>On 12/05/2012 06:24 PM, Light&ColoR wrote:
>> Wow! BTW, how did you make it?  Actually I wanna use Lustre on MIPS. Taking a quicklook at Lustre sources, I just find less than 100 lines  architecture-sepcific asm codes( maybe more).   It's should not be hard to transplant Lustre.......
>> At 2012-12-06 03:05:39,"Christopher J. Morrone" <morrone2@llnl.gov> wrote:
>>> Just FYI, we have been successfully using Lustre clients on PowerPC
>>> architectures at LLNL for years, and PowerPC has a different default
>>> page size and endianness than x86.
>>>
>>> On 12/05/2012 12:22 AM, Light&ColoR wrote:
>>>> Big thx to you Andreas!
>>>>
>>>> At 2012-12-05 11:20:17,"Andreas Dilger" <adilger@whamcloud.com> wrote:
>>>>
>>>>      On 2012-12-04, at 0:02, Light&ColoR <eternalregion@163.com
>>>>      <mailto:eternalregion@163.com>> wrote:
>>>>>      I am a newbie, I have a little bit of experience in linux kernel,
>>>>>      but not transplanting Lustre. How should I identify which part of
>>>>>      source code in Lustre is architecture specified?
>>>>
>>>>      There is not much architecture-specific code in Lustre, and the less
>>>>      the better...
>>>>
>>>>      Probably the easiest is to just try compiling it and seeing where
>>>>      the issues are. Some are in the build system -we don't have configs
>>>>      for server kernels. That isn't needed on the client though.
>>>>
>>>>      Big endian severs are not really supported as we have no ability to
>>>>      test or fix them.
>>>>
>>>>      Please keep the list updated with your progress, since this has been
>>>>      asked a couple of times here recently.
>>>>
>>>>      Cheers, Andreas
>>>>
>>>>
>>>>
>>>>
>>>>
>>>> _______________________________________________
>>>> Lustre-devel mailing list
>>>> Lustre-devel at lists.lustre.org
>>>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>>>
>>>
>>> _______________________________________________
>>> Lustre-devel mailing list
>>> Lustre-devel at lists.lustre.org
>>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>
>> .
>>
>
