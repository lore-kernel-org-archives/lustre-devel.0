From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Mon, 16 Feb 2009 16:05:07 -0500
Subject: [Lustre-devel] Some investigations on  MDS creation rate
In-Reply-To: <499985A7.7000600@sun.com>
References: <DC147A4B-16CC-41B7-9C27-2F9BE64805FD@Sun.COM>
	<FE7ACA5E-C11C-41B7-BF1D-05F9A73C72DF@sun.com>
	<499985A7.7000600@sun.com>
Message-ID: <CB88ADF9-B0C6-41FA-AFCE-F9CA1E2416BD@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Feb 16, 2009, at 10:26 AM, Alex Zhuravlev wrote:

> Oleg Drokin wrote:
>>   I also performed tests on HEAD and it performs significantly  
>> worse  (5.8k at most). Even with all the same fixes ported from b1_6.
>>   The CPU remains the same and I used lock meter to verify that  
>> there  is no significant lock contention.
>>   Looking into the oprofile results, it looks like all code just   
>> became slower (judging by more hits in various areas for the same   
>> workload).
>>   Also some parts of the code are now more heavily loaded (ptlrpc  
>> +ldlm in HEAD draws more cpu time, llite portion of the code is  
>> 50%  more time
> notice HEAD takes two ldlm locks for each create, 1.6 takes one.

What is the other one? I am looking at mdt_md_create and I see it  
locks parent, but not child, just like b1_6.

Bye,
     Oleg
