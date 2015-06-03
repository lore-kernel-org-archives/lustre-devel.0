From: Colin Faber <colin.faber@seagate.com>
Date: Wed, 3 Jun 2015 14:03:10 -0600
Subject: [lustre-devel] OpenID 2.0 and Gerrit 2.11
In-Reply-To: <556F5BA7.1020301@llnl.gov>
References: <CAPALmn=6cNyRPhCQe_4A+hqJueP0yKh4vP13JE3KiucCk3SE4w@mail.gmail.com>
	<556F5BA7.1020301@llnl.gov>
Message-ID: <CAPALmnmXbE_VLSvrUBA-NgLz1XDsr3Lz2m886KVNU8KYvwgbgg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Chris,

From what I can tell, the OAuth2 and OpenID 2.0 combo does work for google
account authentication against gerrit:

http://gerrit.cloudlinux.com:8080/login/%23%2Fq%2Fstatus%3Aopen


-cf



On Wed, Jun 3, 2015 at 1:55 PM, Christopher J. Morrone <morrone2@llnl.gov>
wrote:

> I think you might have that backwards.  Google has _stopped_ supporting
> OpenID 2.0.  To the best of my knowledge no version of gerrit yet supports
> Google's new OpenID Connect system.
>
> Chris
>
>
> On 06/03/2015 12:52 PM, Colin Faber wrote:
>
>> Hi,
>>
>> This is probably more a question for the folks at Intel.. Is there an
>> ETA or plan in place to upgrade to Gerrit 2.11 and OpenID 2.0? Such
>> changes would allow for google logins to function correctly.
>>
>> -cf
>>
>>
>>
>> _______________________________________________
>> lustre-devel mailing list
>> lustre-devel at lists.lustre.org
>> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>>
>>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150603/85461eda/attachment-0001.htm>
