From: Mike Pershin <mpershin@whamcloud.com>
Date: Fri, 1 Mar 2019 06:45:33 +0000
Subject: [lustre-devel] [PATCH 27/37] lustre: discard lu_ref
In-Reply-To: <7025104E-6297-4312-8647-213D3671E6A4@whamcloud.com>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494627.24125.13508435808475179343.stgit@noble.brown>
 <alpine.LFD.2.21.1902242027340.1485@casper.infradead.org>
 <87h8cqt4ga.fsf@notabene.neil.brown.name>
 <7025104E-6297-4312-8647-213D3671E6A4@whamcloud.com>
Message-ID: <09338d7f-fc42-dee4-9ed9-07c391a5bc37@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2/27/19 8:35 AM, Andreas Dilger wrote:
>> On Feb 26, 2019, at 18:17, NeilBrown<neilb@suse.com>  wrote:
>>
>> On Sun, Feb 24 2019, James Simmons wrote:
>>
>>>> struct lu_ref is always an empty structure, and the functions
>>>> which manipulate it do nothing.
>>>> So this is not being tested and so cannot be trusted.
>>>> So remove all these calls and field declarations.
>>> Or we can make lu_ref really work and always test with it :-)
>> We could ... though a lot of the code has been removed already, I was
>> just finishing the job.
>>
>> How useful is this stuff?
>> Has it actually helped to find any bugs?
>> Does it do any run-time checks, or it is just
>> there to help you pull apart a crash-dump?
>>
>> I think there is a real cost in having these extra linkages.  I'd like
>> to be clear what the benefit is.
> I've never used it myself, though I know a few developers that did in the
> past.  That said, most of the time they needed to use it to debug some
> issue they had to push a patch to fix it first...
>
> Mike, Alex, you are most likely to use this code - do you think it is
> still useful?
>
> Cheers, Andreas
> ---
> Andreas Dilger
> Principal Lustre Architect
> Whamcloud
>
I've used that is past to track reference leaks, that can be useful but 
as you said each time I had to fix it first. I think it would be 
reasonable to keep that feature if it is enabled by default on developer 
systems, without that it is not so useful.

Mike
