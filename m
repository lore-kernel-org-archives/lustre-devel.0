From: Robert Read <rread@sun.com>
Date: Thu, 03 Dec 2009 14:23:25 -0800
Subject: [Lustre-devel] client-side reply handling
In-Reply-To: <5B2F74A3-0AA9-488B-BE30-312C68B70E60@sun.com>
References: <027901ca7429$60703d10$2150b730$@com>
	<5B2F74A3-0AA9-488B-BE30-312C68B70E60@sun.com>
Message-ID: <4EDD2ECF-5FC1-4410-9F70-09D07EF1C4FF@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Dec 3, 2009, at 13:17 , Andreas Dilger wrote:

> On 2009-12-03, at 08:00, Eric Barton wrote:
>> Edited from IRC...
>>> 
>>> <Liang> eeb_: do you mean, we can be 100% sure it's safe to unpack
>>>       in-place only when the buffer is unlinked? so it is better
>>>       to unregister reply buffer before calling into
>>>       after_reply()->unpack_reply()?
>> 
>> Yes, I think so.  While the reply buffer remains attached, it's
>> possible to overwrite it at any time.  This could happen if...
>> 
>> a) The server is buggy or malign
> 
> Let's hope we never have to worry about malicious server nodes...
> 
>> b) The request is re-sent and the same reply matchbits are used,
>>  which is what I think happens currently for non-bulk reqs.
> 
> In theory, the reply to the re-sent request should be identical due
> to reply reconstruction, so it shouldn't matter if it happens to
> overwrite the same buffer.

That's fine as long as the buffer is unlinked from the net before it gets swabbed, but hopefully that's the case already. 

robert
