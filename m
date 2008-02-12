From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Tue, 12 Feb 2008 14:09:40 +0300
Subject: [Lustre-devel] [RFC] parallel enqueue
In-Reply-To: <01b801c86d02$e7a520a0$0281a8c0@ebpc>
References: <47AC75E3.7010901@sun.com> <01b801c86d02$e7a520a0$0281a8c0@ebpc>
Message-ID: <47B17E74.7030300@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

well, the idea is to fallback to serialized enqueue once such
collision is detected: this allow to avoid livelock problem
and rpc storms.


thanks, Alex

Eric Barton wrote:
> This sounds great!
> 
> But are there any livelock issues? 
> 
>> -----Original Message-----
>> From: lustre-devel-bounces at lists.lustre.org 
>> [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of 
>> Alex Zhuravlev
>> Sent: 08 February 2008 3:32 PM
>> To: lustre-devel at lists.lustre.org
>> Subject: [Lustre-devel] [RFC] parallel enqueue
>>
>> Hi,
>>
>> in some cases (truncate, append) we still use serialized enqueue
>> when all locks have to be enqueued synchronously one by one.
>>
>> what if we could mark all locks issued by single client with some
>> unique tag (timestamp + nid?), then enqueue them all and then, in
>> case of conflict, in blocking ast handler compare tag of conflicting
>> lock with own tag, cancel our granted locks if our tag is greater
>> than tag of conflicting lock and enqueue them again?
>>
>> thanks, Alex
>>
>>
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
