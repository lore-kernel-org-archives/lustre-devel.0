From: Light&ColoR <eternalregion@163.com>
Date: Thu, 6 Dec 2012 10:24:19 +0800 (CST)
Subject: [Lustre-devel] Question of transplanting Lustre to a non-x86
 arch
In-Reply-To: <50BF9B03.5090402@llnl.gov>
References: <220a56d5.1c243.13b64b93c40.Coremail.eternalregion@163.com>
	<8CF388B6-4A59-4B17-A71E-D31B1AFD955A@whamcloud.com>
	<1a9c0f60.edf4.13b6a28a653.Coremail.eternalregion@163.com>
	<50BF9B03.5090402@llnl.gov>
Message-ID: <2188ef43.13dad.13b6e07218a.Coremail.eternalregion@163.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Wow! BTW, how did you make it?  Actually I wanna use Lustre on MIPS. Taking a quicklook at Lustre sources, I just find less than 100 lines  architecture-sepcific asm codes( maybe more).   It's should not be hard to transplant Lustre.......
At 2012-12-06 03:05:39,"Christopher J. Morrone" <morrone2@llnl.gov> wrote:
>Just FYI, we have been successfully using Lustre clients on PowerPC 
>architectures at LLNL for years, and PowerPC has a different default 
>page size and endianness than x86.
>
>On 12/05/2012 12:22 AM, Light&ColoR wrote:
>> Big thx to you Andreas!
>>
>> At 2012-12-05 11:20:17,"Andreas Dilger" <adilger@whamcloud.com> wrote:
>>
>>     On 2012-12-04, at 0:02, Light&ColoR <eternalregion@163.com
>>     <mailto:eternalregion@163.com>> wrote:
>>>     I am a newbie, I have a little bit of experience in linux kernel,
>>>     but not transplanting Lustre. How should I identify which part of
>>>     source code in Lustre is architecture specified?
>>
>>     There is not much architecture-specific code in Lustre, and the less
>>     the better...
>>
>>     Probably the easiest is to just try compiling it and seeing where
>>     the issues are. Some are in the build system -we don't have configs
>>     for server kernels. That isn't needed on the client though.
>>
>>     Big endian severs are not really supported as we have no ability to
>>     test or fix them.
>>
>>     Please keep the list updated with your progress, since this has been
>>     asked a couple of times here recently.
>>
>>     Cheers, Andreas
>>
>>
>>
>>
>>
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>
>
>_______________________________________________
>Lustre-devel mailing list
>Lustre-devel at lists.lustre.org
>http://lists.lustre.org/mailman/listinfo/lustre-devel
