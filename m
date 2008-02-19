From: Yuriy Umanets <Yury.Umanets@Sun.COM>
Date: Tue, 19 Feb 2008 17:14:26 +0200
Subject: [Lustre-devel] storing SOM epoch in EA
In-Reply-To: <op.t6r08rkfatmt0c@garden>
References: <47BAA607.1000600@sun.com> <47BAAF3F.6030301@sun.com>
	<200802191359.47379.vitaly@sun.com> <47BAB962.8010901@sun.com>
	<47BABB01.8060402@sun.com> <47BAC53A.2030106@sun.com>
	<op.t6r08rkfatmt0c@garden>
Message-ID: <47BAF252.9050409@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Mikhail Pershin wrote:
> On Tue, 19 Feb 2008 15:02:02 +0300, Yuriy Umanets <Yury.Umanets@Sun.COM>  
> wrote:
>
>   
>> Alex Zhuravlev wrote:
>>     
>>> Yuriy Umanets wrote:
>>>
>>>       
>>>> EA is separate block is evil. It makes things slow.
>>>>
>>>>         
>>> we have fast EAs (stored in inode, this is why we make them large) for  
>>> years.
>>>
>>>       
>> Well, people used horses for ages but this did not stop them from
>> building cars :) Guys, I gave you idea, not worse than using EAs. I will
>> not insist it is great. If you can't estimate its value yourself, well,
>> let it be. We have such a nice thing as IAM and you keep talking about
>> EAs...
>>
>> Seriously, IMHO what is bad about EAs:
>>
>> 1. You need to control their size, you need to bother;
>> 2. Large-fast inodes make create/lookup slow. You need to load this
>> thing to memory after all. I think this is complement to additional
>> seeks caused by IAM;
>>     
>
> but this is still better than extra block for EA or IAM. Btw IAM data is  
> also in memory and takes it no less than extra inode size possibly
>   
If it is in memory it will generate less seeks :-)
>   
>> 3. Storing epoch in EA makes you use this chain to access epoch:
>> fid->inode->epoch (in EA), IAM makes it shorter: fid->epoch (in IAM);
>>     
>
> not true actually. inode will be read anyway until you are proposing to  
> put whole inode body in IAM, so there is no benefits. Moreover inode->ea  
> is direct mapping while fid->epoch will need index lookup and may invoke  
> several blocks to read if IAM is large and it will be large in this case,  
> so IO will be not better than even EA in extra block.
>
>   
I did not mean to put whole inode in IAM. I meant only put there fid as 
key and epoch as value. So way to access epoch is shorter with IAM as no 
need to load inode. But these all need to be well thought as all your 
mention more seeks, new reads, etc.
>> 4. Large inodes consume more RAM;
>>     
>
> this is the same as 2.
>
> Guys, don't forget about DMU as well.
>
>   


-- 
umka
