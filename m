From: Liang Zhen <Zhen.Liang@Sun.COM>
Date: Fri, 04 Dec 2009 11:30:13 +0800
Subject: [Lustre-devel] client-side reply handling
In-Reply-To: <4EDD2ECF-5FC1-4410-9F70-09D07EF1C4FF@sun.com>
References: <027901ca7429$60703d10$2150b730$@com>
	<5B2F74A3-0AA9-488B-BE30-312C68B70E60@sun.com>
	<4EDD2ECF-5FC1-4410-9F70-09D07EF1C4FF@sun.com>
Message-ID: <4B188245.7030503@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Robert Read wrote:
>>
>>     
>>> b) The request is re-sent and the same reply matchbits are used,
>>>  which is what I think happens currently for non-bulk reqs.
>>>       
>> In theory, the reply to the re-sent request should be identical due
>> to reply reconstruction, so it shouldn't matter if it happens to
>> overwrite the same buffer.
>>     
>
> That's fine as long as the buffer is unlinked from the net before it gets swabbed, but hopefully that's the case already. 
>   

I'm afraid it's not the case in ptlrpc_check_set(), we begin to swab 
reply when the request is marked as replied and unregister(unlink) reply 
buffer after that, it's the reason Eric brought the topic...

Liang

> robert
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>   
