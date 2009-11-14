From: Christopher J. Walker <C.J.Walker@qmul.ac.uk>
Date: Sat, 14 Nov 2009 09:38:19 +0000
Subject: [Lustre-devel] Lustre version number and rpm "Release"
In-Reply-To: <1cbd6f830911111720p1b6d9e54ibb5410709b38176f@mail.gmail.com>
References: <4AC56205.5060403@llnl.gov>	<1254491700.26203.251.camel@pc.interlinx.bc.ca>	<4AC69C7B.2020201@llnl.gov>	<1254750291.22120.12.camel@pc.interlinx.bc.ca>
	<1cbd6f830911111720p1b6d9e54ibb5410709b38176f@mail.gmail.com>
Message-ID: <4AFE7A8B.9070006@qmul.ac.uk>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Mag Gam wrote:
> Just curious, why do people build their own releases if everything is
> available in release RPMs. Do most people or organizations build their
> own version of Lustre or do they use the RPMs?
>

We need to keep up to date with the latest kernel security errata - so 
I've been building Lustre clients.

> I am asking because I would like to build my own version and wanted to
> see the benefits of it.

Knowing that you can, even if you don't currently need to, is an advantage.

> TIA
> 
> 2009/10/5 Brian J. Murrell <Brian.Murrell@sun.com>:
>> On Fri, 2009-10-02 at 17:36 -0700, Christopher J. Morrone wrote:
>>> Well, that is true, except that we just want to prefix the release, not
>>> replace it.  If we replace it with our own definition, we have to repeat
>>> the kernel detection, and timestamp part.
>> Yes, that's true.
>>
>>> So really, we'll want an
>>> additional "release_prefix" rpm variable.
>> That would be a trivial patch.  Feel free to open a bug and submit it.
>> I can't see any reason why we'd not land that.
>>
>>> There is an additional wrinkle that I didn't mention.  Our automated
>>> build system is designed to take source rpms and build the binary rpms
>>> from that.  If we just set "release" at source rpm build time, I don't
>>> think that it will be remember later when the binary rpms are built.
>> Yes, I think you are correct about that.
>>
>> FWIW, (I think[1]) I'd like us (Sun) to get out of the business of
>> putting anything meaningful in the Release tag and leave that for
>> distributors to use.  I'm not sure if or how that might help you though.
>>
>> b.
>>
>> [1] I've not really investigated the possibility yet, so it's really
>> just a seed of an idea.
>>
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>
>>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
