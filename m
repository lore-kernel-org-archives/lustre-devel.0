From: Yuriy Umanets <Yury.Umanets@Sun.COM>
Date: Tue, 19 Feb 2008 13:11:30 +0200
Subject: [Lustre-devel] storing SOM epoch in EA
In-Reply-To: <200802191359.47379.vitaly@sun.com>
References: <47BAA607.1000600@sun.com> <47BAAF3F.6030301@sun.com>
	<200802191359.47379.vitaly@sun.com>
Message-ID: <47BAB962.8010901@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Vitaly Fertman wrote:
>> hi!
>>
>> Can we use IAM for storing epoch? It is fast and does not have such 
>> strong size limitations. 
>>     
> there are no size limitations, EA can be stored in a separate
> block, we just want to minimize IO.
>
>   
EA is separate block is evil. It makes things slow.
>> We could make "epoch" index in mkfs time (like  
>> it is done for existing indexes now) and use object's fid as a key and 
>> epoch as value.
>>     
> this looks like it will double IO/seeks for each inode.
>
>   
Well, it did not in cmd3 :)


-- 
umka
