From: Peter Braam <Peter.Braam@Sun.COM>
Date: Thu, 05 Jun 2008 04:10:45 -0700
Subject: [Lustre-devel] FW: Quotas for Lustre 2.0
In-Reply-To: <9CE57CB7-C0BA-463D-8F62-AEC4E2DC1335@Sun.COM>
Message-ID: <C46D17C5.5812%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



> From: Peter Braam <Peter.Braam@Sun.COM>
> Date: June 4, 2008 8:01:20 PM ADT
> To: Peter Bojanic <Peter.Bojanic@Sun.COM>, Nikita Danilov
<Nikita.Danilov@Sun.COM
> >, Johann Lombardi <johann@sun.com>
> Cc: Eric Barton <eeb@sun.com>, Nathaniel Rutman
> <Nathan.Rutman@Sun.COM>
> Subject: Re: Quotas for Lustre 2.0
>
> Customers need quota, so we need it with the DMU.
>
> There are two architectures being discussed simultaneously: one is
> quota for
> the DMU, that is new and Nikita has given a good approach.  The
> second is
> adjustments to the Lustre quota architecture, which has problems,
> but it
> seems it is not a case of a re-write. So the 120 hours may not be a
> total
> waste.
>
> Nathan should have been Johann for this thread?
>
> Peter
>
>
>
>
>
> On 6/4/08 3:47 PM, "Peter Bojanic" <Peter.Bojanic@Sun.COM> wrote:
>
>> Nikita, Peter (Braam),
>>
>> More thinking on quotas...
>>
>> Porting the existing flawed architecture from HEAD will take ~120
>> hours (be prepared to double that). It would be a shame to waste that
>> effort as a throw-away. Would the new approach that is being
>> discussed
>> on lustre-devel afford us an ldiskfs-based quotas feature on HEAD
>> before we get DMU servers? Another thought: could we have quotas
>> support for ldiskfs and disable quotas for DMU object stores if
>> necessary?
>>
>> The dependencies here are maddening.
>>
>> Thanks,
>> Bojanic
>
>


------ End of Forwarded Message
