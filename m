From: Jacek Anaszewski <j.anaszewski@samsung.com>
Date: Tue, 22 Sep 2015 11:46:58 +0200
Subject: [lustre-devel] [PATCH 00/38] Fixes related to incorrect usage
	of unsigned types
In-Reply-To: <56011BB9.5030004@samsung.com>
References: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
	<17571.1442842945@warthog.procyon.org.uk>
	<56011BB9.5030004@samsung.com>
Message-ID: <56012392.7020807@samsung.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 09/22/2015 11:13 AM, Andrzej Hajda wrote:
> On 09/21/2015 03:42 PM, David Howells wrote:
>> Andrzej Hajda <a.hajda-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org> wrote:
>>
>>> Semantic patch finds comparisons of types:
>>>      unsigned < 0
>>>      unsigned >= 0
>>> The former is always false, the latter is always true.
>>> Such comparisons are useless, so theoretically they could be
>>> safely removed, but their presence quite often indicates bugs.
>>
>> Or someone has left them in because they don't matter and there's the
>> possibility that the type being tested might be or become signed under some
>> circumstances.  If the comparison is useless, I'd expect the compiler to just
>> discard it - for such cases your patch is pointless.
>>
>> If I have, for example:
>>
>> 	unsigned x;
>>
>> 	if (x == 0 || x > 27)
>> 		give_a_range_error();
>>
>> I will write this as:
>>
>> 	unsigned x;
>>
>> 	if (x <= 0 || x > 27)
>> 		give_a_range_error();
>>
>> because it that gives a way to handle x being changed to signed at some point
>> in the future for no cost.  In which case, your changing the <= to an ==
>> "because the < part of the case is useless" is arguably wrong.
>
> This is why I have not checked for such cases - I have skipped checks of type
> 	unsigned <= 0
> exactly for the reasons above.
>
> However I have left two other checks as they seems to me more suspicious - they
> are always true or false. But as Dmitry and Andrew pointed out Linus have quite
> strong opinion against removing range checks in such cases as he finds it
> clearer. I think it applies to patches 29-36. I am not sure about patches 26-28,37.

Dropped 30/38 and 31/38 from LED tree then.

-- 
Best Regards,
Jacek Anaszewski
