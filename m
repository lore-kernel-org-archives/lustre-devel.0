From: Light&ColoR <eternalregion@163.com>
Date: Wed, 5 Dec 2012 16:22:27 +0800 (CST)
Subject: [Lustre-devel] Question of transplanting Lustre to a non-x86
 arch
In-Reply-To: <8CF388B6-4A59-4B17-A71E-D31B1AFD955A@whamcloud.com>
References: <220a56d5.1c243.13b64b93c40.Coremail.eternalregion@163.com>
	<8CF388B6-4A59-4B17-A71E-D31B1AFD955A@whamcloud.com>
Message-ID: <1a9c0f60.edf4.13b6a28a653.Coremail.eternalregion@163.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Big thx to you Andreas!

At 2012-12-05 11:20:17,"Andreas Dilger" <adilger@whamcloud.com> wrote:

On 2012-12-04, at 0:02, Light&ColoR <eternalregion@163.com> wrote:
I am a newbie, I have a little bit of experience in linux kernel, but not transplanting Lustre. How should I identify which part of source code in Lustre is architecture specified? 


There is not much architecture-specific code in Lustre, and the less the better...


Probably the easiest is to just try compiling it and seeing where the issues are. Some are in the build system -we don't have configs for server kernels. That isn't needed on the client though. 


Big endian severs are not really supported as we have no ability to test or fix them.


Please keep the list updated with your progress, since this has been asked a couple of times here recently. 


Cheers, Andreas
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20121205/8f66c441/attachment.htm>
