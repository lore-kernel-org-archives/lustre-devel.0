From: Maxim V. Patlasov <Maxim.Patlasov@Sun.COM>
Date: Fri, 16 Oct 2009 20:49:35 +0400
Subject: [Lustre-devel] lustre-to-LNET API: big non-aligned bulk
	transfers
In-Reply-To: <088e01ca4cf2$f5f9dcf0$e1ed96d0$@com>
References: <4AD5ECBC.20003@sun.com> <088e01ca4cf2$f5f9dcf0$e1ed96d0$@com>
Message-ID: <4AD8A41F.10403@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Eric,

To make things 100% clear - did you answer positively ('It should...') 
because there are some lustre use-cases for such transfers or just 
because it would be natural for LNET to support both aligned and 
not-aligned big bulk transfers?

Thanks in advance,
Maxim

On 10/14/2009 09:22 PM, Eric Barton wrote:
> Maxim,
>
> It should support such transfers, but you have to be careful about
> the number of fragments this can introduce.  This issue has already
> been observed in routers, which buffer LNET message payloads at
> the same page offset, irrespective of the sender's page offset (of
> which it has no knowledge).  For example, this can force the o2iblnd,
> if configured to pre-map all memory, to need double the number of RDMA
> fragments and therefore fail the transfer.  Chat with Liang - he knows
> all about this...
>
>      Cheers,
>                Eric
>
>    
>> -----Original Message-----
>> From: lustre-devel-bounces at lists.lustre.org [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of Maxim V.
>> Patlasov
>> Sent: 14 October 2009 8:23 AM
>> To: lustre-devel at lists.lustre.org
>> Subject: [Lustre-devel] lustre-to-LNET API: big non-aligned bulk transfers
>>
>> Hi lustre-devel,
>>
>> I'd like to gather some opinions about the following question:
>>
>> Is it allowed or possible for lustre to submit relatively big bulk
>> transfer request (e.g.>512K) to LNET layer when offset in the very
>> first page to fetch bulk data from (on sender side) is not equal to the
>> offset in the very first page to store data (on receiver side)? In the
>> other words - should LNET support such transfers?
>>
>> Thanks in advance,
>> Maxim
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>      
>
>    

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20091016/8219f0ff/attachment.htm>
