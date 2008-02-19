From: Yuriy Umanets <Yury.Umanets@Sun.COM>
Date: Tue, 19 Feb 2008 16:30:34 +0200
Subject: [Lustre-devel] storing SOM epoch in EA
In-Reply-To: <47BAC7D4.3010007@sun.com>
References: <47BAA607.1000600@sun.com> <47BAAF3F.6030301@sun.com>
	<200802191359.47379.vitaly@sun.com> <47BAB962.8010901@sun.com>
	<47BABB01.8060402@sun.com> <47BAC53A.2030106@sun.com>
	<47BAC7D4.3010007@sun.com>
Message-ID: <47BAE80A.8050702@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Alex Zhuravlev wrote:
> btw, are you proposing to store LOV in global IAM?
by "LOV" you mean LOV EA? If yes, well, this is too radical idea seems, 
but it may be worse to think on. Finally using IAM with it will cost 
almost nothing in meaning of additional development. IAM should be ready 
for that.

Nikita, is there any limitations for value size in IAM?

Thanks.
>
> thanks, Alex
>
> Yuriy Umanets wrote:
>> Seriously, IMHO what is bad about EAs:
>>
>> 1. You need to control their size, you need to bother;
>> 2. Large-fast inodes make create/lookup slow. You need to load this 
>> thing to memory after all. I think this is complement to additional 
>> seeks caused by IAM;
>> 3. Storing epoch in EA makes you use this chain to access epoch: 
>> fid->inode->epoch (in EA), IAM makes it shorter: fid->epoch (in IAM);
>> 4. Large inodes consume more RAM;
>> 5. There others...  but they are less related to technical 
>> downsides/advantages so I will omit them.
>>
>> Thanks.
>>
>


-- 
umka
