From: Fan Yong <yong.fan@whamcloud.com>
Date: Thu, 14 Oct 2010 00:32:54 +0800
Subject: [Lustre-devel] Large readdir RPCs project
In-Reply-To: <AANLkTikAwYzfEMbSzE5Yhpj5KrbwMhTjV7dqtWQNBwH6@mail.gmail.com>
References: <AANLkTin42fMZpZ-eRt6gF__Ftw6Oo5BBf58Mb-376erW@mail.gmail.com>	<4CA2EE55.7010209@whamcloud.com>	<AANLkTi=q2XwYnhWPRUJha-o8dxCV5DZ6_so_P5RbHzN4@mail.gmail.com>	<4CA3EE66.2040206@whamcloud.com>
	<AANLkTikAwYzfEMbSzE5Yhpj5KrbwMhTjV7dqtWQNBwH6@mail.gmail.com>
Message-ID: <4CB5DF36.3020508@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

  On 10/14/10 12:04 AM, Jeremy Filizetti wrote:
> I've put together a small patch to modify ll_dir_readpage and 
> mdc_readpage to read extra pages (if available) with each RPC.  It is 
> posted under the bug 
> (https://bugzilla.lustre.org/show_bug.cgi?id=17833).  I see you we're 
> the original assignee when you were at Sun/Oracle.
Thanks, I will study such patch. I added Lsy into such bug CC list who 
is interested in it also.

--
Nasf
> Jeremy
>
> 2010/9/29 Fan Yong <yong.fan@whamcloud.com 
> <mailto:yong.fan@whamcloud.com>>
>
>     On 9/30/10 3:01 AM, Jeremy Filizetti wrote:
>>
>>
>>         On the other hand, Large readdir RPCs is basic of another
>>         metadata read performance improvement features - "readdir+",
>>         which is quite useful for "ls -l" operation (for large
>>         directory), and reduce lookup/getattr RPC as much as
>>         possible. In such feature, MDS will pack more dir-item's
>>         attribute (not only name/ino as does currently by readdir,
>>         but also mode/owner, and etc) information back to client-side
>>         in "readdir+" RPC. That means the dir-item count in one
>>         "readdir+" page is less than in the traditional readdir page,
>>         then more pages to be sent back to client. If without "Large
>>         readdir RPCs", the advantage of "readdir+" will be discounted.
>>
>>     I'd be interested in working this as well but probably as a
>>     separate effort since SOM isn't in 1.8 and that's my main focus. 
>>     In our testing, SOM had significant benefits over the WAN and I'd
>>     expect even better from readdir+.  I have tried Oleg's patch for
>>     asynchronous ll_glimpse_size but oddly I've seen someone erradic
>>     performance where at times it was worse then statahead and
>>     synchronous ll_glimpse_size.
>>     Jeremy
>     Yes, SOM is another important feature for metadata reading
>     performance improvement by bypassing the glimpse RPC between
>     client and OSS. Engineers from Lustre Group worked for that for
>     some time, hope can be released soon.
>
>     As for the asynchronous ll_glimpse_size maybe cause bad
>     performance occasionally, one possible reason is that: glimpse RPC
>     maybe not obtain extent lock(s) if some others in using such
>     lock(s), so the file size information obtained by asynchronous
>     glimpse is invalid when it is really used later, means the caller
>     ("stat") has to send synchronous glimpse again. Anyway, I did not
>     study such patch, so it is just a guess.
>
>
>     Cheers,
>     Nasf
>
>     _______________________________________________
>     Lustre-devel mailing list
>     Lustre-devel at lists.lustre.org <mailto:Lustre-devel@lists.lustre.org>
>     http://lists.lustre.org/mailman/listinfo/lustre-devel
>
>

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20101014/b5c28ace/attachment.htm>
