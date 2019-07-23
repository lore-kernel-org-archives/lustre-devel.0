From: Oleg Drokin <green@whamcloud.com>
Date: Tue, 23 Jul 2019 01:40:48 +0000
Subject: [lustre-devel] sanity-hsm and libtool
In-Reply-To: <alpine.LFD.2.21.1907230114090.23817@casper.infradead.org>
References: <B0E37F29-E0D1-4432-A6DB-712D27E078CB@amazon.com>
 <alpine.LFD.2.21.1907191611160.17024@casper.infradead.org>
 <B264B956-FB39-46EF-A72D-0214B316833F@amazon.com>
 <CAFhUgOQ_bLGvPEkmjGYxGWwViTA4_rprAmPY+GBGmr8Ndicswg@mail.gmail.com>
 <alpine.LFD.2.21.1907230114090.23817@casper.infradead.org>
Message-ID: <3BEAD335-B8BA-42EE-940F-B482B3FB3B1C@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


>> I concur : I cannot run sanity-hsm on master. Works fine when checking out the commit right before the libtool patch , breaks if the patch
>> is applied.
>> 
>> With some testing it appears this is because "libtool execute" does does not use the PATH environment variable when it resolves paths :
>> 
>> $> pwd
>> /home/user/lustre-release
>> $> export PATH=lustre/utils:/usr/bin
>> $> which lhsmtool_posix
>> /home/user/lustre-release/lustre/utils/lhsmtool_posix
>> $> libtool execute echo lhsmtool_posix
>> lhsmtool_posix
>> $> libtool execute echo lustre/utils/lhsmtool_posix
>> /home/user/lustre-release/luster/utils/.libs/lhsmtool_posix
>> 
>> I suspect this works on Maloo because Maloo does not run tests from the git repo but rather from installed rpms (=> no libtool wrappers).
>> 
>> @James, I can see you asked me a follow-up review on the patch that introduces this regressions, and I did not answer, Sorry about that. I
>> will try to keep better track of patches I reviewed at least once... In this spirit, I will try to update my review of this change this
>> weekend. =)
> 
> This is strange since Oleg does his testing in the lustre source tree 
> directly. I would think he would have encounter this issue. I need 
> to looking how libtool does its path searches.

I build with configure --disable-shared to sidestep this issue.
