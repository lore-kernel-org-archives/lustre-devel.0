From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Tue, 23 Nov 2010 14:59:23 -0800
Subject: [Lustre-devel] Stripe offset default
In-Reply-To: <AA2C4DA2-1607-4509-9BF2-7F05A352B269@oracle.com>
References: <016b01cb8b32$cc3a9c90$64afd5b0$@com> <4CEC1AB8.2040507@llnl.gov>
	<AA2C4DA2-1607-4509-9BF2-7F05A352B269@oracle.com>
Message-ID: <4CEC474B.1010609@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 11/23/2010 01:19 PM, Andreas Dilger wrote:
> On 2010-11-23, at 12:49, Christopher J. Morrone wrote:
>> On 11/23/2010 09:20 AM, Eric Barton wrote:
>>> I believe, now that lfs setstripe uses options rather than positional
>>> parameters, that the risk of unintentional errors is much less.  But
>>> that still leaves the filesystem vulnerable to na?ve or malicious
>>> users.  So I propose that we should continue to check permissions
>>> normally when setting the default stripe _count_, but restrict the
>>> ability to set a specific default stripe _offset_ to the superuser.
>>
>> At the very least bug 18547 MUST be completed before doing this.
>> Lustre's default layout mechanism is too uneven, and leads to too much
>> of a performance problem right now to take away users' only ability to
>> lay files out evenly on their own.
>
> I guess the subtle distinction in Eric's question is for "default striping parameters specified on a directory" and not "striping parameters set on a per-file basis".  In IRC I discussed with Eric that it is like that specifying the starting OST on a directory default layout is _probably_ not what a user wants to do.

Ah, ok, I did miss that.  I am less opposed to that, since I can't think 
of a particularly compelling use case for a fixed offset default on 
directories.
