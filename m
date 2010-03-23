From: Tom.Wang <Tom.Wang@Sun.COM>
Date: Tue, 23 Mar 2010 08:35:53 -0400
Subject: [Lustre-devel] readdir for striped dir
In-Reply-To: <8acda98c1003230915n3e75ac05pe8095bb910c5153b@mail.gmail.com>
References: <4BA7F8B3.8050104@sun.com>
	<A3F904D6-6838-426D-BA21-333281606AC8@sun.com>
	<4BA8A60C.4000504@sun.com>
	<8acda98c1003230915n3e75ac05pe8095bb910c5153b@mail.gmail.com>
Message-ID: <4BA8B5A9.3020107@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nikita Danilov wrote:
> On 23 March 2010 14:29, Tom.Wang <Tom.Wang@sun.com> wrote:
>   
>> Hello,
>>     
>
> Hello,
>
> [...]
>
>   
>> LMV will use new hash function to select stripe object (mdc), which could be
>> independent with the one
>> used in the storage.  In mdc level, it just need to map the entries of each
>> dir stripe object in the cache,
>> we can index the cache in anyway as we want, probably hash order (as the
>> server storage) is a good choice,
>> because client can easily find and cancel the pages by the hash in later
>> dir-extent lock. Note: Even in this case,
>> client does not need to know server hash scheme at all, since server will
>> set the hash-offset of these pages, client just
>> need to put these pages on the cache by hash-offset.
>> Currently, the cache will only be touched by readdir.  If the cache will be
>> used by readdir-plus later, i.e. we need locate
>> the entry by name, then client must use the same hash as the server storage,
>> but server will tell client which hash function
>> it use.  Yes, different hash per dirstripe should not be a problem here.
>>     
>
> If I understand correctly, the scheme has an advantage of cleaner
> solution for readdir scalability than "hash adjust" hack of CMD3 (see
> comment in lmv/lmv_obd.c:lmv_readpage()). The problem, to remind, is
> that if a number of clients readdir the same split directory, they all
> hammer the same servers one after another, negating the advantages of
> meta-data clustering. The solution is to cyclically shift hash space
> by an offset depending on the client, so that clients load servers
> uniformly. With 2-level hashing, this shifting can be done entirely
> within new LMV hash function.
>   
Yes, in this case, these clients should start from different 
stripe-offset in
readdir.

Thanks
Wangdi
>   
>> Thanks
>> WangDi
>>     
>
> Thank you,
> Nikita.
>   
