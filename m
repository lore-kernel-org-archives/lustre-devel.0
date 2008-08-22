From: Tom.Wang <Tom.Wang@Sun.COM>
Date: Fri, 22 Aug 2008 14:54:14 -0400
Subject: [Lustre-devel] Readx issue
In-Reply-To: <0C7FCB06-03B0-4EEF-B919-2ED836D0586E@Sun.COM>
References: <C4D3A486.57CB%peter.braam@sun.com>
	<0C7FCB06-03B0-4EEF-B919-2ED836D0586E@Sun.COM>
Message-ID: <48AF0B56.3000702@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi, Peter

Sure, actually I added 1 in sanity, but did not compare it with normal 
read. I will do that. Thanks!
Thanks
WangDi
Peter Bojanic wrote:
> Wang Di,
>
> Can you produce some sample benchmarks that show IO performance with 
> and without readx? That would be very helpful to understand the 
> benefits of using the new API.
>
> Bojanic
>
> On 22-Aug-08, at 2:02 AM, Peter Braam wrote:
>
>> Very exciting.   I have cc'd lustre-devel, because this is exciting.
>>
>> Peter
>>
>>
>> On 8/21/08 10:56 PM, "Tom.Wang" <Tom.Wang@Sun.COM> wrote:
>>
>>> Hello,
>>>
>>> Readx/writex code has been done based on HEAD. (ACC-sm has been passed)
>>>
>>> Since the target here is to issue the vector read extents req parallel,
>>> so I chosed to implement that by read-ahead
>>> group io, which is async and parallel. And also by this way, it will 
>>> not
>>> touch other module of lustre.
>>>
>>> In vector read-ahead, each read request will control their 
>>> read-ahead by
>>> itself, instead of by the current read-ahead window, where multi
>>> read-threads(for the same file) use single read ahead window.
>>>
>>> Because current read-ahead
>>>  1)Use a single continuous RA window to control the read ahead.
>>>  2)The read-ahead moves forward according to the global RA window(for
>>> all the read threads of this file), so it tries to favour all the read
>>> threads of the file,
>>>
>>> This algorithm is not very nice for vector read-ahead. because
>>> 1) It is hard to manage the multi discontinuous read-ahead window, for
>>> example add/remove the extents from the window will be very subtle.
>>> 2) It is hard to favour all the vector read-threads(for the file) by 1
>>> single read-ahead window.
>>>
>>> So I let each vector read threads control their read-ahead themselves,
>>> which will make implementation very easy, and it will also not touch
>>> original read-ahead algorithm for non-vector read.  If you disagree
>>> about this, please tell me.
>>>
>>> So all the implementation(readx,writex) actually did not touch other
>>> module at all currently.  I will ask some senior ppl to inspect the
>>> patch. I do not know the further plan with CERN, will they try this
>>> current release or HEAD? If they want try it in current release. Is 
>>> that
>>> ok I could land it in b1_6 or b1_8 after it pass inspection? Please 
>>> advise.
>>>
>>> Thanks
>>> WangDi
>>
>>
>
