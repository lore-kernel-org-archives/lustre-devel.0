From: Yuriy Umanets <Yury.Umanets@Sun.COM>
Date: Tue, 19 Feb 2008 12:38:39 +0200
Subject: [Lustre-devel] storing SOM epoch in EA
In-Reply-To: <47BAAFC3.90608@sun.com>
References: <47BAA607.1000600@sun.com> <47BAAF3F.6030301@sun.com>
	<47BAAFC3.90608@sun.com>
Message-ID: <47BAB1AF.2050405@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Alex Zhuravlev wrote:
> hmm. not sure I got it. epoch is per-inode. and we don't need >1 epoch 
> for
> any inode.
>
Yes, right. We will not have few epochs for the inode. I think we need 
Nikita here as he is author of IAM and may help us.

In HEAD we have got OI (Object Index) which purpose is to map object 
fids into object store cookies (inode + generation). Fid here is the key 
and inode store info is value. We have only one such mapping entry for 
any inode. I proposed to have similar mapping, but store SOM epoch for 
the inode same way. Use fid as key and epoch as value.

Nikita, is this correct using of IAM?

Thanks.
> thanks, Alex
>
> Yuriy Umanets wrote:
>> Can we use IAM for storing epoch? It is fast and does not have such 
>> strong size limitations. We could make "epoch" index in mkfs time 
>> (like it is done for existing indexes now) and use object's fid as a 
>> key and epoch as value.
>>
>> Thanks.
>>
>


-- 
umka
